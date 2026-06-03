import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";

initializeApp();
const db = getFirestore();

/** Returns today's date string "YYYY-MM-DD" in Asia/Riyadh (UTC+3). */
function todayInRiyadh(): string {
  return new Date(Date.now() + 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

const GEMINI_KEY = process.env.GEMINI_API_KEY || "";
const CLASSIFY_MODEL = process.env.GEMINI_MODEL || "gemini-2.0-flash";
const EMBED_MODEL = "gemini-embedding-001";

interface TaxonomyEntry {
  id: string;
  labelAr: string;
  labelEn: string;
  synonyms: string[];
  appliesTo: string[];
}

interface HeroCopyResult {
  titleAr: string;
  subtitleAr: string;
  titleEn: string;
  subtitleEn: string;
}

let taxonomyCache: TaxonomyEntry[] | null = null;
let taxonomyCachedAt = 0;
const TAXONOMY_TTL_MS = 5 * 60 * 1000;

async function loadTaxonomy(): Promise<TaxonomyEntry[]> {
  const now = Date.now();
  if (taxonomyCache && now - taxonomyCachedAt < TAXONOMY_TTL_MS) {
    return taxonomyCache;
  }

  const snap = await db.collection("taxonomy").where("isActive", "==", true).get();

  taxonomyCache = snap.docs.map((doc) => {
    const data = doc.data();
    const label = data.label || {};
    return {
      id: data.id || doc.id,
      labelAr: label.ar || "",
      labelEn: label.en || "",
      synonyms: Array.isArray(data.synonyms) ? data.synonyms : [],
      appliesTo: Array.isArray(data.appliesTo) ? data.appliesTo : [],
    };
  });
  taxonomyCachedAt = now;
  return taxonomyCache;
}

function extractContentText(
  collection: string,
  data: FirebaseFirestore.DocumentData
): { title: string; description: string; extra: string } {
  switch (collection) {
    case "attractions": {
      const name = data.name || {};
      const desc = data.description || {};
      return {
        title: `${name.ar || ""} | ${name.en || ""}`.trim(),
        description: `${desc.ar || ""} | ${desc.en || ""}`.trim(),
        extra: `Category: ${data.category || ""}`,
      };
    }
    case "events": {
      return {
        title: `${data.titleAr || ""} | ${data.titleEn || ""}`.trim(),
        description: `${data.descriptionAr || ""} | ${data.descriptionEn || ""}`.trim(),
        extra: `Type: ${data.eventType || ""}`,
      };
    }
    case "cultural_items": {
      return {
        title: `${data.titleAr || ""} | ${data.titleEn || ""}`.trim(),
        description: `${data.descriptionAr || ""} | ${data.descriptionEn || ""}`.trim(),
        extra: `Category: ${data.categoryId || ""}`,
      };
    }
    case "trips": {
      return {
        title: `${data.titleAr || ""} | ${data.titleEn || ""}`.trim(),
        description: `${data.descriptionAr || data.shortDescriptionAr || ""} | ${data.descriptionEn || data.shortDescriptionEn || ""}`.trim(),
        extra: `Type: ${data.tripType || ""}`,
      };
    }
    default:
      return { title: "", description: "", extra: "" };
  }
}

async function classifyInterests(
  collection: string,
  contentText: { title: string; description: string; extra: string }
): Promise<string[]> {
  const taxonomy = await loadTaxonomy();
  const eligibleInterests = taxonomy.filter((t) => t.appliesTo.includes(collection));

  if (eligibleInterests.length === 0) return [];

  const interestsList = eligibleInterests
    .map((t) => `- ${t.id}: ${t.labelAr} (${t.labelEn}). Keywords: ${t.synonyms.slice(0, 8).join(", ")}`)
    .join("\n");

  const prompt = [
    "You are classifying a Saudi cultural tourism item.",
    "Pick 1-4 interest IDs from the list below that BEST match the item.",
    "Available interests:",
    interestsList,
    `Item Title: ${contentText.title}`,
    `Item Description: ${contentText.description}`,
    'Return ONLY valid JSON in this exact shape: {"interestIds": ["id1", "id2"]}',
  ].join("\n");

  try {
    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    const model = genAI.getGenerativeModel({ model: CLASSIFY_MODEL });
    const result = await model.generateContent(prompt);
    const rawText = result.response.text().trim();
    const validIds = new Set(eligibleInterests.map((t) => t.id));
    return parseInterestIds(rawText, validIds);
  } catch (error) {
    logger.error("Gemini classification failed", { collection, error });
    return [];
  }
}

function parseInterestIds(rawText: string, validIds: Set<string>): string[] {
  const cleaned = rawText.replace(/```json|```/g, "").trim();
  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed.interestIds)) return sanitizeIds(parsed.interestIds, validIds);
  } catch (_) {}
  const match = cleaned.match(/\{[\s\S]*\}/);
  if (match) {
    try {
      const parsed = JSON.parse(match[0]);
      if (Array.isArray(parsed.interestIds)) return sanitizeIds(parsed.interestIds, validIds);
    } catch (_) {}
  }
  return [];
}

function sanitizeIds(values: unknown[], validIds: Set<string>): string[] {
  return values
    .map((v) => String(v).trim())
    .filter((v) => v.length > 0)
    .filter((v, i, arr) => arr.indexOf(v) === i)
    .filter((v) => validIds.has(v))
    .slice(0, 4);
}

async function generateEmbedding(text: string): Promise<number[]> {
  if (!text.trim()) return [];
  try {
    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    const model = genAI.getGenerativeModel({ model: EMBED_MODEL });
    const result = await model.embedContent(text);
    return result.embedding?.values || [];
  } catch (error) {
    logger.error("Gemini embedding failed", { error });
    return [];
  }
}

async function classifyDocument(
  collection: string,
  docId: string,
  data: FirebaseFirestore.DocumentData
): Promise<void> {
  if (!GEMINI_KEY) return;
  const contentText = extractContentText(collection, data);
  if (!contentText.title && !contentText.description) return;

  const combinedText = `${contentText.title}\n${contentText.description}\n${contentText.extra}`;
  const interestIds = await classifyInterests(collection, contentText);
  const embedding = await generateEmbedding(combinedText);

  if (interestIds.length === 0 && embedding.length === 0) return;

  await db.collection(collection).doc(docId).update({
    interestIds,
    embedding,
    classifiedAt: FieldValue.serverTimestamp(),
  });
}

async function generateHeroCopyForDoc(
  collection: string,
  data: FirebaseFirestore.DocumentData
): Promise<HeroCopyResult> {
  const content = extractContentText(collection, data);
  if (!content.title && !content.description) {
    throw new Error(`generateHeroCopyForDoc: no text content for ${collection}`);
  }

  const prompt = [
    "You are a premium cultural content writer for Athar, a Saudi heritage tourism app aligned with Vision 2030.",
    "Write SHORT, cinematic, emotionally resonant promotional hero banner copy for the following item.",
    "The Arabic must be Modern Standard Arabic (فصحى), elegant and culturally authentic.",
    "The English must be polished, evocative, and premium — like a luxury travel campaign.",
    "",
    `Item title: ${content.title}`,
    `Item description: ${content.description}`,
    "",
    "Rules:",
    "- Arabic title: max 6 words, cinematic and evocative",
    "- Arabic subtitle: max 12 words, poetic but clear",
    "- English title: max 6 words, premium and punchy",
    "- English subtitle: max 12 words, inspiring and specific",
    "- Do NOT mention AI, apps, or technology",
    "- Do NOT use generic phrases like 'discover the beauty'",
    "- Sound like a world-class tourism campaign",
    "",
    'Return ONLY this JSON object — no markdown fences, no extra text:',
    '{"titleAr":"...","subtitleAr":"...","titleEn":"...","subtitleEn":"..."}',
  ].join("\n");

  const genAI = new GoogleGenerativeAI(GEMINI_KEY);
  const model = genAI.getGenerativeModel({ model: CLASSIFY_MODEL });
  const result = await model.generateContent(prompt);
  const rawText = result.response.text().trim();

  // Strip markdown fences defensively before parsing
  const cleaned = rawText
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();

  let parsed: unknown;
  try {
    parsed = JSON.parse(cleaned);
  } catch (_) {
    const match = cleaned.match(/\{[\s\S]*\}/);
    if (!match) {
      throw new Error(`generateHeroCopyForDoc: no JSON found in response: ${rawText.slice(0, 200)}`);
    }
    try {
      parsed = JSON.parse(match[0]);
    } catch {
      throw new Error(`generateHeroCopyForDoc: JSON parse failed: ${rawText.slice(0, 200)}`);
    }
  }

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("generateHeroCopyForDoc: parsed value is not an object");
  }

  const obj = parsed as Record<string, unknown>;
  const titleAr   = String(obj.titleAr   ?? "").trim();
  const subtitleAr = String(obj.subtitleAr ?? "").trim();
  const titleEn   = String(obj.titleEn   ?? "").trim();
  const subtitleEn = String(obj.subtitleEn ?? "").trim();

  if (!titleAr || !subtitleAr || !titleEn || !subtitleEn) {
    throw new Error(
      `generateHeroCopyForDoc: one or more fields empty — ` +
      `titleAr=${!!titleAr} subtitleAr=${!!subtitleAr} titleEn=${!!titleEn} subtitleEn=${!!subtitleEn}`
    );
  }

  return { titleAr, subtitleAr, titleEn, subtitleEn };
}

async function writeHeroCopy(
  collection: string,
  docId: string,
  data: FirebaseFirestore.DocumentData
): Promise<void> {
  const copy = await generateHeroCopyForDoc(collection, data);
  await db.collection(collection).doc(docId).update({
    heroCopy: {
      ...copy,
      generatedAt: FieldValue.serverTimestamp(),
    },
  });
}

// Triggers
export const classifyNewAttraction = onDocumentCreated({ document: "attractions/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (!event.data) return;
  const data = event.data.data();
  await classifyDocument("attractions", event.params.docId, data);
  try {
    await writeHeroCopy("attractions", event.params.docId, data);
  } catch (err) {
    console.error("[heroCopy] onCreate attractions", event.params.docId, err);
  }
});

export const classifyNewTrip = onDocumentCreated({ document: "trips/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (!event.data) return;
  const data = event.data.data();
  await classifyDocument("trips", event.params.docId, data);
  try {
    await writeHeroCopy("trips", event.params.docId, data);
  } catch (err) {
    console.error("[heroCopy] onCreate trips", event.params.docId, err);
  }
});

export const classifyNewEvent = onDocumentCreated({ document: "events/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (!event.data) return;
  const data = event.data.data();
  await classifyDocument("events", event.params.docId, data);
  try {
    await writeHeroCopy("events", event.params.docId, data);
  } catch (err) {
    console.error("[heroCopy] onCreate events", event.params.docId, err);
  }
});

export const classifyNewCulturalItem = onDocumentCreated({ document: "cultural_items/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (!event.data) return;
  const data = event.data.data();
  await classifyDocument("cultural_items", event.params.docId, data);
  try {
    await writeHeroCopy("cultural_items", event.params.docId, data);
  } catch (err) {
    console.error("[heroCopy] onCreate cultural_items", event.params.docId, err);
  }
});

function textFieldsChanged(before: FirebaseFirestore.DocumentData, after: FirebaseFirestore.DocumentData, fields: string[]): boolean {
  return fields.some((f) => JSON.stringify(before[f]) !== JSON.stringify(after[f]));
}

export const reclassifyUpdatedAttraction = onDocumentUpdated({ document: "attractions/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  // classify fires on text OR category change; heroCopy only on text change
  if (textFieldsChanged(before, after, ["name", "description", "category"])) {
    await classifyDocument("attractions", event.params.docId, after);
  }
  if (textFieldsChanged(before, after, ["name", "description"])) {
    try {
      await writeHeroCopy("attractions", event.params.docId, after);
    } catch (err) {
      console.error("[heroCopy] onUpdate attractions", event.params.docId, err);
    }
  }
});

export const reclassifyUpdatedTrip = onDocumentUpdated({ document: "trips/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  if (textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn", "shortDescriptionAr", "shortDescriptionEn", "tripType"])) {
    await classifyDocument("trips", event.params.docId, after);
    try {
      await writeHeroCopy("trips", event.params.docId, after);
    } catch (err) {
      console.error("[heroCopy] onUpdate trips", event.params.docId, err);
    }
  }
});

export const reclassifyUpdatedEvent = onDocumentUpdated({ document: "events/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  // classify fires on text OR eventType change; heroCopy only on text change
  if (textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn", "eventType"])) {
    await classifyDocument("events", event.params.docId, after);
  }
  if (textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn"])) {
    try {
      await writeHeroCopy("events", event.params.docId, after);
    } catch (err) {
      console.error("[heroCopy] onUpdate events", event.params.docId, err);
    }
  }
});

export const reclassifyUpdatedCulturalItem = onDocumentUpdated({ document: "cultural_items/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  // classify fires on text OR categoryId change; heroCopy only on text change
  if (textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn", "categoryId"])) {
    await classifyDocument("cultural_items", event.params.docId, after);
  }
  if (textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn"])) {
    try {
      await writeHeroCopy("cultural_items", event.params.docId, after);
    } catch (err) {
      console.error("[heroCopy] onUpdate cultural_items", event.params.docId, err);
    }
  }
});

export const migrateAllContent = onCall({ enforceAppCheck: false, timeoutSeconds: 540, memory: "512MiB", secrets: ["GEMINI_API_KEY"] }, async (request) => {
  if (!GEMINI_KEY) throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not set");
  const requested = (request.data?.collection as string) || "all";
  const targets = requested === "all" ? ["attractions", "trips", "events", "cultural_items"] : [requested];
  const results: Record<string, number> = {};
  let total = 0;

  for (const collection of targets) {
    const snap = await db.collection(collection).get();
    const unclassified = snap.docs.filter((d) => {
      const ids = d.data().interestIds;
      return !Array.isArray(ids) || ids.length === 0;
    });

    let count = 0;
    for (const doc of unclassified) {
      try {
        await classifyDocument(collection, doc.id, doc.data());
        count++;
        await new Promise((r) => setTimeout(r, 15000)); 
      } catch (err) {
        logger.error("Failed to classify in batch", { collection, docId: doc.id, err });
      }
    }
    results[collection] = count;
    total += count;
  }
  return { ...results, total };
});

// =====================================================
// EMBED + CLASSIFY MISSING DOCUMENTS
// Backfills BOTH `embedding` AND `interestIds` for any document missing them,
// by delegating to classifyDocument() — the same path used for new documents.
// This is what revives trips in Rawi's text, semantic matching, AND the
// interest-based trip suggestion path (which depends on interestIds).
// =====================================================
export const embedMissingDocuments = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "512MiB",
    secrets: ["GEMINI_API_KEY"],
  },
  async (_request) => {
    if (!GEMINI_KEY) {
      throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not set");
    }

    const collections = ["attractions", "trips", "events", "cultural_items"];
    const stats: Record<string, { processed: number; failed: number; skipped: number }> = {};

    for (const collectionName of collections) {
      stats[collectionName] = { processed: 0, failed: 0, skipped: 0 };
      const snapshot = await db.collection(collectionName).get();

      logger.info(`[embedMissing] Scanning ${collectionName}: ${snapshot.size} docs`);

      for (const doc of snapshot.docs) {
        const data = doc.data();

        // Skip docs already processed by the CURRENT pipeline. `classifiedAt`
        // is written by classifyDocument() on every run (even when no interest
        // matched), so it marks the doc as fully processed. Docs left by the OLD
        // backfill have `embedding` + `embeddedAt` but NO `classifiedAt`, so
        // they get reprocessed here to gain interestIds.
        if (data.classifiedAt) {
          stats[collectionName].skipped++;
          continue;
        }

        try {
          // classifyDocument writes BOTH embedding AND interestIds in a single
          // update — so the interest-based suggestion path works for trips too.
          await classifyDocument(collectionName, doc.id, data);
          stats[collectionName].processed++;
          logger.info(`[embedMissing] ✓ Fixed ${collectionName}/${doc.id}`);

          // 8s delay protects the free-tier rate limit.
          await new Promise((resolve) => setTimeout(resolve, 8000));
        } catch (err: any) {
          logger.error(`[embedMissing] ✗ ${collectionName}/${doc.id}:`, err?.message || err);
          stats[collectionName].failed++;

          if (String(err).includes("429") || String(err).includes("quota")) {
            logger.warn("[embedMissing] Rate limit hit, waiting 30s");
            await new Promise((resolve) => setTimeout(resolve, 30000));
          }
        }
      }
    }

    logger.info("[embedMissing] Batch Process Complete:", stats);
    return { success: true, stats };
  }
);

// =====================================================
// DIAGNOSTIC — Inspect actual document shapes
// =====================================================
// =====================================================
// ASK RAWI — RAG-powered cultural AI assistant
// =====================================================

const AR_STOPWORDS = new Set([
  "عن","من","إلى","الى","في","على","هل","ما","هذا","هذه","ذلك","تلك",
  "حابه","حابة","أريد","اريد","ابي","أبي","ودي","اعرف","أعرف",
  "وش","ايش","كم","كيف","متى","وين","أين","اين","كل","بعض","تحديدا","تحديداً",
  "هي","هو","أنا","انا","نحن","أنت","انت","أكثر","اكثر","يا","أيها","ايها",
]);

const EN_STOPWORDS = new Set([
  "about","from","to","in","on","the","a","an","of","for","and","or",
  "what","where","when","how","is","are","i","you","we","want","know",
  "tell","me","more","all","some","specifically","exactly",
]);

function extractKeywords(text: string, isArLang: boolean): string[] {
  const stop = isArLang ? AR_STOPWORDS : EN_STOPWORDS;
  return text
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .filter((w) => w.length >= 3 && !stop.has(w));
}

const SIMILARITY_THRESHOLD = 0.6;
const HIGH_CONFIDENCE_THRESHOLD = 0.7;
const TOP_K = 5;
const MAX_SUGGESTED_ITEMS = 3;
const RAWI_CHAT_MODEL = "gemini-2.5-flash";
const EMBEDDING_CACHE_TTL_MS = 5 * 60 * 1000;

interface CachedEmbedding {
  embedding: number[];
  titleAr: string;
  titleEn: string;
  imageUrl: string | null;
  description: string;
  region: string;
  type: "attraction" | "trip" | "event" | "cultural_item";
  docId: string;
  interestIds: string[];
}

let embeddingCache: Map<string, CachedEmbedding> | null = null;
let embeddingCachedAt = 0;

function cosineSimilarity(a: number[], b: number[]): number {
  if (!a.length || !b.length || a.length !== b.length) return 0;
  let dot = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  const denom = Math.sqrt(normA) * Math.sqrt(normB);
  return denom === 0 ? 0 : dot / denom;
}

function extractDocMeta(
  collection: string,
  docId: string,
  data: FirebaseFirestore.DocumentData
): CachedEmbedding | null {
  const emb = data.embedding;
  if (!Array.isArray(emb) || emb.length === 0) return null;

  const typeMap: Record<string, CachedEmbedding["type"]> = {
    attractions: "attraction",
    trips: "trip",
    events: "event",
    cultural_items: "cultural_item",
  };
  const type = typeMap[collection];
  if (!type) return null;

  let titleAr = "";
  let titleEn = "";
  let description = "";
  let imageUrl: string | null = null;
  let region = "";

  switch (collection) {
    case "attractions": {
      const name = data.name || {};
      const desc = data.description || {};
      titleAr = name.ar || "";
      titleEn = name.en || "";
      description = (desc.ar || desc.en || "").slice(0, 200);
      imageUrl = data.mainImage || data.mainImageUrl || data.imageUrl || null;
      region = normalizeRegion(data.regionId || data.region || data.location);
      break;
    }
    case "trips": {
      // TripModel stores flat titleAr/titleEn fields (NOT a nested `title` map).
      // Fall back to a nested `title` map only if the flat fields are missing.
      const t = data.title || {};
      titleAr = data.titleAr || (typeof t === "object" ? (t.ar || "") : String(t || ""));
      titleEn = data.titleEn || (typeof t === "object" ? (t.en || "") : "");
      description = (
        data.descriptionAr || data.descriptionEn ||
        data.shortDescriptionAr || data.shortDescriptionEn || ""
      ).slice(0, 200);
      imageUrl = data.imageUrl || data.mainImage || data.mainImageUrl || data.coverImage || data.image || null;
      region = normalizeRegion(data.regionId || data.region);
      break;
    }
    case "events": {
      titleAr = data.titleAr || "";
      titleEn = data.titleEn || "";
      description = (data.descriptionAr || data.descriptionEn || "").slice(0, 200);
      imageUrl = data.imageUrl || data.mainImage || data.mainImageUrl || data.coverImage || data.image || null;
      region = normalizeRegion(data.regionId || data.region || data.location);
      break;
    }
    case "cultural_items": {
      titleAr = data.titleAr || "";
      titleEn = data.titleEn || "";
      description = (data.descriptionAr || data.descriptionEn || "").slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
      region = normalizeRegion(data.regionId || data.region);
      break;
    }
  }

  return {
    embedding: emb,
    titleAr,
    titleEn,
    description,
    imageUrl,
    region,
    type,
    docId,
    interestIds: Array.isArray(data.interestIds) ? data.interestIds : [],
  };
}

async function loadEmbeddingCache(): Promise<Map<string, CachedEmbedding>> {
  const now = Date.now();
  if (embeddingCache && now - embeddingCachedAt < EMBEDDING_CACHE_TTL_MS) {
    return embeddingCache;
  }
  
  const collections = ["attractions", "trips", "events", "cultural_items"];
  const cache = new Map<string, CachedEmbedding>();

  for (const col of collections) {
    const snap = await db.collection(col).select("embedding", "interestIds", "name", "title", "titleAr", "titleEn", "descriptionAr", "descriptionEn", "shortDescriptionAr", "shortDescriptionEn", "description", "imageUrl", "mainImage", "mainImageUrl", "coverImage", "image", "region", "regionId", "location", "category", "eventType").get();
    for (const doc of snap.docs) {
      const data = doc.data();
      const meta = extractDocMeta(col, doc.id, data);
      if (meta) {
        cache.set(`${col}/${doc.id}`, meta);
        // TEMP DIAGNOSTIC: log every cached doc that has no imageUrl
        if (!meta.imageUrl) {
          logger.warn(`[cache] no imageUrl for ${col}/${doc.id}`, {
            keys: Object.keys(data),
          });
        }
      }
    }
  }

  embeddingCache = cache;
  embeddingCachedAt = now;
  return cache;
}

function normalizeRegion(raw: string | undefined | null): string {
  if (!raw) return "";
  const s = String(raw).trim().toLowerCase().replace(/\s+/g, "_");
  const aliases: Record<string, string> = {
    "central_region": "central_region",
    "central": "central_region",
    "najd": "central_region",
    "المنطقة_الوسطى": "central_region",
    "الوسطى": "central_region",

    "western_region": "western_region",
    "western": "western_region",
    "hejaz": "western_region",
    "al-hejaz": "western_region",
    "المنطقة_الغربية": "western_region",
    "الغربية": "western_region",

    "eastern_region": "eastern_region",
    "eastern": "eastern_region",
    "المنطقة_الشرقية": "eastern_region",
    "الشرقية": "eastern_region",

    "northern_region": "northern_region",
    "northern": "northern_region",
    "المنطقة_الشمالية": "northern_region",
    "الشمالية": "northern_region",

    "southern_region": "southern_region",
    "southern": "southern_region",
    "asir": "southern_region",
    "المنطقة_الجنوبية": "southern_region",
    "الجنوبية": "southern_region",

    // ✦ City → region (mirrors region_city_constants.dart in the app).
    // Lets trips/events stored by city still match the conversation region.
    "riyadh": "central_region", "الرياض": "central_region",
    "qassim": "central_region", "القصيم": "central_region",
    "hail": "central_region", "حائل": "central_region",

    "jeddah": "western_region", "جدة": "western_region",
    "makkah": "western_region", "مكة": "western_region",
    "madinah": "western_region", "المدينة": "western_region",
    "taif": "western_region", "الطائف": "western_region",

    "tabuk": "northern_region", "تبوك": "northern_region",
    "arar": "northern_region", "عرعر": "northern_region",
    "sakaka": "northern_region", "سكاكا": "northern_region",

    "dammam": "eastern_region", "الدمام": "eastern_region",
    "khobar": "eastern_region", "الخبر": "eastern_region",
    "al_ahsa": "eastern_region", "الأحساء": "eastern_region",
    "jubail": "eastern_region", "الجبيل": "eastern_region",

    "abha": "southern_region", "أبها": "southern_region",
    "khamis_mushait": "southern_region", "خميس_مشيط": "southern_region",
    "jazan": "southern_region", "جازان": "southern_region",
    "najran": "southern_region", "نجران": "southern_region",
    "al_baha": "southern_region", "الباحة": "southern_region",
  };
  return aliases[s] ?? s;
}

/**
 * Detects a Saudi region in free-form text (the tourist's chat message) so
 * the general chat ("Rawi General Council") can still be region-locked when
 * the tourist names a region or a city. Returns "" when nothing is detected.
 *
 * Word-boundary safe: matches whole words only, so "ar" inside "art" won't
 * trigger Arar. Arabic is matched with simple substring (no word boundaries
 * in Arabic regex) since the city/region names are distinctive enough.
 */
function detectRegionInText(text: string): string {
  if (!text) return "";
  const lower = text.toLowerCase();

  // Ordered by priority: longer/more specific names first to avoid partial
  // matches (e.g. check "khamis mushait" before "khamis").
  const patterns: Array<[RegExp | string, string]> = [
    // Region names — English
    [/\bcentral\s*region\b/i, "central_region"],
    [/\bwestern\s*region\b/i, "western_region"],
    [/\bnorthern\s*region\b/i, "northern_region"],
    [/\beastern\s*region\b/i, "eastern_region"],
    [/\bsouthern\s*region\b/i, "southern_region"],
    [/\bnajd\b/i, "central_region"],
    [/\bhejaz\b/i, "western_region"],
    [/\basir\b/i, "southern_region"],

    // Region names — Arabic
    ["الوسطى", "central_region"],
    ["الغربية", "western_region"],
    ["الشمالية", "northern_region"],
    ["الشرقية", "eastern_region"],
    ["الجنوبية", "southern_region"],
    ["نجد", "central_region"],
    ["الحجاز", "western_region"],
    ["عسير", "southern_region"],

    // Cities — English (longer compounds first)
    [/\bkhamis\s*mushait\b/i, "southern_region"],
    [/\bal[\s-]*ahsa\b/i, "eastern_region"],
    [/\bal[\s-]*baha\b/i, "southern_region"],
    [/\briyadh\b/i, "central_region"],
    [/\bqassim\b/i, "central_region"],
    [/\bhail\b/i, "central_region"],
    [/\bjeddah\b/i, "western_region"],
    [/\bmakkah\b/i, "western_region"],
    [/\bmecca\b/i, "western_region"],
    [/\bmadinah\b/i, "western_region"],
    [/\bmedina\b/i, "western_region"],
    [/\btaif\b/i, "western_region"],
    [/\btabuk\b/i, "northern_region"],
    [/\barar\b/i, "northern_region"],
    [/\bsakaka\b/i, "northern_region"],
    [/\bdammam\b/i, "eastern_region"],
    [/\bkhobar\b/i, "eastern_region"],
    [/\bjubail\b/i, "eastern_region"],
    [/\babha\b/i, "southern_region"],
    [/\bjazan\b/i, "southern_region"],
    [/\bnajran\b/i, "southern_region"],

    // Cities — Arabic
    ["خميس مشيط", "southern_region"],
    ["الرياض", "central_region"],
    ["القصيم", "central_region"],
    ["حائل", "central_region"],
    ["جدة", "western_region"],
    ["مكة", "western_region"],
    ["المدينة", "western_region"],
    ["الطائف", "western_region"],
    ["تبوك", "northern_region"],
    ["عرعر", "northern_region"],
    ["سكاكا", "northern_region"],
    ["الدمام", "eastern_region"],
    ["الخبر", "eastern_region"],
    ["الأحساء", "eastern_region"],
    ["الاحساء", "eastern_region"],
    ["الجبيل", "eastern_region"],
    ["أبها", "southern_region"],
    ["ابها", "southern_region"],
    ["جازان", "southern_region"],
    ["نجران", "southern_region"],
    ["الباحة", "southern_region"],
    ["الباحه", "southern_region"],
  ];

  for (const [pattern, region] of patterns) {
    if (typeof pattern === "string") {
      if (text.includes(pattern)) return region;
    } else {
      if (pattern.test(lower)) return region;
    }
  }
  return "";
}

export const askRawi = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 60,
    memory: "512MiB",
    region: "us-central1",
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!GEMINI_KEY) throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not set");

    const { conversationId, userMessage, recentMessages, locale, regionId, userInterests } = request.data as {
      conversationId: string;
      userMessage: string;
      recentMessages: Array<{ role: "user" | "assistant"; content: string }>;
      locale: "ar" | "en";
      regionId?: string;
      userInterests?: string[];
    };
    const interestSet = new Set<string>(Array.isArray(userInterests) ? userInterests : []);

    if (!userMessage?.trim()) throw new HttpsError("invalid-argument", "userMessage is required");

    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    const isAr = locale === "ar";

    // ✦ FIX: normalize the incoming regionId the same way stored values are normalized
    let wantedRegion = normalizeRegion(regionId);

    // ✦ REGION DETECTION FROM MESSAGE: when the chat is general (no regionId
    // passed from Flutter, e.g. "Rawi General Council"), try to infer the
    // region from the user's message itself. So when the tourist writes
    // "Najd" or "central region" or even a city like "Riyadh"/"Jeddah",
    // suggestions stay locked to that region instead of leaking across all.
    if (!wantedRegion && userMessage) {
      wantedRegion = detectRegionInText(userMessage);
    }

    // كشف نيّة طلب رحلة — في رسالة المستخدم الحالية فقط، لا في السياق التاريخي
    const tripIntentAr = /(اقترح|رحلة|رحلات|سفرة|زيارة|سياحة|نشاط سياحي|(?:أبغى|ابغى|أبي|ودي|بدي|أبا) ?أ?(?:روح|زور|سافر|طلع)|وين أ?روح|كيف أ?روح|نروح|نزور)/i;
    const tripIntentEn = /\b(suggest|recommend|propose|plan).{0,20}(trip|tour|itinerary|visit)|\b(trip|tour|itinerary)\b|\bi (want|wanna|would like|'d like) to (visit|go|explore|tour)|where (can|should|do) i (go|visit)/i;

    const userWantsTrip = isAr
      ? tripIntentAr.test(userMessage)
      : tripIntentEn.test(userMessage);

    logger.info(`[askRawi] userWantsTrip=${userWantsTrip} msg="${userMessage.slice(0, 80)}"`);

    // 1. Embed the user query
    const queryEmbedding = await generateEmbedding(userMessage);

    // 2. Load cached embeddings and strictly filter by region when provided
    const cache = await loadEmbeddingCache();

    // ✦ FIX: compare two normalized values so format differences don't break filtering
    const regionFiltered = wantedRegion
      ? new Map([...cache.entries()].filter(([, meta]) => meta.region === wantedRegion))
      : cache;

    // إسقاط الرحلات من أرشيف العرض عند غياب نيّة الذهاب — تختفي من السياق والأرشيف معاً
    const filteredCache = userWantsTrip
      ? regionFiltered
      : new Map([...regionFiltered.entries()].filter(([, meta]) => meta.type !== "trip"));

    // نطاق البحث الهجين — كلّ المناطق، بلا رحلات إن لم يطلب (للاسترجاع عبر الحدود الثقافية)
    const searchSpace = userWantsTrip
      ? cache
      : new Map([...cache.entries()].filter(([, meta]) => meta.type !== "trip"));

    logger.info(`[askRawi] wantedRegion="${wantedRegion}" totalCache=${cache.size} filtered=${filteredCache.size} searchSpace=${searchSpace.size}`);

    // 3. Hybrid retrieval: semantic + lexical + rare-word + region boost
    const INTEREST_BOOST = 1.2;
    const REGION_BOOST = 1.08;
    const LEXICAL_HIT_BONUS = 0.1;
    const MAX_LEXICAL_BONUS = 0.3;
    const RARE_WORD_BONUS = 0.18;
    const RARE_THRESHOLD = 0.10;

    const queryKeywords = extractKeywords(userMessage, isAr);

    // احسب docFreq مرّة واحدة — O(n) لا O(n²)
    const docFreq = new Map<string, number>();
    for (const kw of queryKeywords) {
      let count = 0;
      for (const m of searchSpace.values()) {
        const h = `${m.titleAr ?? ""} ${m.titleEn ?? ""} ${m.description ?? ""}`.toLowerCase();
        if (h.includes(kw)) count++;
      }
      docFreq.set(kw, count);
    }

    const rareKeywords = new Set<string>();
    for (const [kw, freq] of docFreq.entries()) {
      if (freq / searchSpace.size < RARE_THRESHOLD) rareKeywords.add(kw);
    }

    logger.info(`[retrieval] kw=[${queryKeywords.join(",")}] rare=[${[...rareKeywords].join(",")}]`);

    const scored: Array<{ key: string; score: number; meta: CachedEmbedding }> = [];
    for (const [key, meta] of searchSpace.entries()) {
      let score = cosineSimilarity(queryEmbedding, meta.embedding);

      if (interestSet.size > 0 && meta.interestIds.some((id) => interestSet.has(id))) {
        score *= INTEREST_BOOST;
      }
      if (wantedRegion && meta.region === wantedRegion) {
        score *= REGION_BOOST;
      }

      if (queryKeywords.length > 0) {
        const haystack = `${meta.titleAr ?? ""} ${meta.titleEn ?? ""} ${meta.description ?? ""}`.toLowerCase();
        let hits = 0;
        let rareHits = 0;
        for (const kw of queryKeywords) {
          if (haystack.includes(kw)) {
            hits++;
            if (rareKeywords.has(kw)) rareHits++;
          }
        }
        score += Math.min(hits * LEXICAL_HIT_BONUS, MAX_LEXICAL_BONUS);
        score += rareHits * RARE_WORD_BONUS;
      }

      if (score >= SIMILARITY_THRESHOLD) {
        scored.push({ key, score, meta });
      }
    }
    scored.sort((a, b) => b.score - a.score);
    const topDocs = scored.slice(0, TOP_K);

    logger.info(`[retrieval] top3=${
      scored.slice(0, 3).map((s) => `${s.meta.titleAr}(${s.meta.region}):${s.score.toFixed(3)}`).join(" | ")
    }`);

    const hasHighConfidenceMatch = topDocs.some(
      (d) => d.score >= HIGH_CONFIDENCE_THRESHOLD
    );

    logger.info(`[askRawi] highConfidence=${hasHighConfidenceMatch} topScore=${topDocs[0]?.score?.toFixed(3) ?? "none"}`);

    // 4. Build retrieved context (top-K semantic matches)
    // Skip entries with no resolvable title — they would appear as blank text in the model's response.
    const contextLines = topDocs
      .filter((d) => {
        const title = isAr ? (d.meta.titleAr || d.meta.titleEn) : (d.meta.titleEn || d.meta.titleAr);
        return title.trim().length > 0;
      })
      .map((d) => {
        const m = d.meta;
        const title = isAr ? (m.titleAr || m.titleEn) : (m.titleEn || m.titleAr);
        return `• [${m.type}] ${title} (id:${m.docId}) — ${m.description.slice(0, 200)}`;
      }).join("\n");

    // 4b. Build full archive inventory from the region-filtered cache.
    // Only the locale-appropriate name is shown to prevent the model from
    // mixing Arabic names into an English response (and vice-versa).
    const archiveByType = new Map<string, Array<{ id: string; titleAr: string; titleEn: string }>>();
    for (const meta of filteredCache.values()) {
      if (!archiveByType.has(meta.type)) archiveByType.set(meta.type, []);
      archiveByType.get(meta.type)!.push({ id: meta.docId, titleAr: meta.titleAr, titleEn: meta.titleEn });
    }
    const archiveLines: string[] = [];
    for (const [type, entries] of archiveByType.entries()) {
      const names = entries
        .filter((e) => {
          // Drop items with no resolvable name — a blank entry causes the model
          // to generate **[empty]** which renders as invisible blank text.
          const name = isAr ? (e.titleAr || e.titleEn) : (e.titleEn || e.titleAr);
          return name.trim().length > 0;
        })
        .map((e) => {
          // Surface only the locale-matching name so the model wraps bold text
          // in the correct script and never mixes languages in entity names.
          const name = isAr ? (e.titleAr || e.titleEn) : (e.titleEn || e.titleAr);
          return `${name} (id:${e.id})`;
        })
        .join(", ");
      if (names.length > 0) archiveLines.push(`[${type}]: ${names}`);
    }
    const archiveSummary = archiveLines.join("\n");

    // allowedNames includes BOTH language variants. Primary purpose: preserve **
    // markers when the model bolds the locale-appropriate name. Secondary safety
    // net: if the model bolds the wrong-language name despite the langInstruction,
    // ** markers are still kept so Flutter can match it via its bilingual
    // validEntityNames set and render it as a clickable entity.
    const allowedNames = new Set<string>();
    for (const meta of filteredCache.values()) {
      if (meta.titleAr?.trim()) allowedNames.add(meta.titleAr.trim());
      if (meta.titleEn?.trim()) allowedNames.add(meta.titleEn.trim());
    }
    // عناصر مسترجَعة من خارج المنطقة عبر البحث الهجين
    for (const d of topDocs) {
      if (d.meta.titleAr?.trim()) allowedNames.add(d.meta.titleAr.trim());
      if (d.meta.titleEn?.trim()) allowedNames.add(d.meta.titleEn.trim());
    }

    const hasArchive = filteredCache.size > 0;

    // 5. Build conditional archive block
    const archiveBlock = (hasHighConfidenceMatch && hasArchive)
      ? `--- Available Archive Items (this region only) ---\n${archiveSummary}`
      : (isAr
          ? `--- ملاحظة دقيقة ---
سؤال المستخدم محدّد ولا يوجد عنصر مطابق له في الأرشيف. أجِب بدفء وبمعرفة ثقافية عامة عن هذا الموضوع تحديداً، دون ذكر أي اسم بين نجمتين، ودون اختلاق عناصر، ودون اقتراح عناصر بديلة لا علاقة لها بالسؤال.`
          : `--- IMPORTANT NOTE ---
The user's question is specific and the archive has no precise match. Answer warmly with general cultural knowledge on THIS specific topic, WITHOUT naming any item in asterisks, WITHOUT inventing, and WITHOUT redirecting to unrelated archive items.`);

    const closestMatchesBlock = hasHighConfidenceMatch
      ? `--- Closest Matches to the User's Question ---\n${contextLines || (isAr ? "لا تطابق دقيق — استخدم قائمة الأرشيف أعلاه." : "No close match — use the archive list above.")}`
      : "";

    // 6. System prompt
    const langInstruction = isAr
      ? "LANGUAGE LAW: Every single word in your response MUST be in Arabic (العربية). Zero tolerance for English words, phrases, or item names. This applies to bolded entity names too — always bold the Arabic name."
      : "LANGUAGE LAW: Every single word in your response MUST be in English. Zero tolerance for Arabic characters or words — this includes bolded entity names. You MUST bold the English name from the archive list, never the Arabic name. If an archive item has no English name, describe it generically in English without printing any Arabic characters.";

    const systemPrompt = `You are "Rawi" (راوي), a passionate and knowledgeable Cultural Expert and Storyteller for Saudi heritage.

${langInstruction}

--- PERSONA & TONE ---
- You are an "Expert Companion" (رفيق خبير), warm but never casual.
- NEVER use patronizing language like "my son", "يا ولدي", or "my child". Address the user as a respected Explorer (مستكشف) or Guest (ضيف).
- Use measured, historically grounded language. NEVER use melodramatic words like "devastated", "heartbroken", "shattered", "مدمّر", or "محطّم" for minor matters.
- For out-of-scope topics: respond with calm, welcoming redirection. Example: "That falls outside my area of expertise, but I'd love to tell you about..." — never apologise dramatically.

--- CONVERSATION FLOW (CRITICAL) ---
- This is an ONGOING dialogue. The 'Conversation context' below shows previous turns.
- If the context is NOT empty, you have ALREADY greeted the user. Do NOT greet again.
- NEVER say "أهلاً بك مجدداً", "أهلاً بك", "مرحباً", "Welcome back", or any greeting after the first turn.
- Start answering the user's message immediately. No openers, no re-introductions.
- If the user says "نعم" / "أكمل" / "Tell me more", look at the context to see WHICH item you were discussing and continue THAT specific topic.

--- STRICT GROUNDING (NO INVENTION) ---
- The "Available Archive Items" below are the ONLY real items. They are your single source of truth.
- YOUR TRAINING DATA KNOWLEDGE IS OVERRIDDEN: Everything you know from training about Saudi landmarks, foods, crafts, or cultural items is irrelevant. The archive list below is the ONLY reality.
- NEVER mention any specific place, food, craft, dress, or item by name — in bold, in plain text, in passing, or as an example — unless that EXACT name appears in the archive list below.
- This applies to world-famous landmarks too. If "قصر المصمك", "الجريش", "السليق", or ANY other name is not in the archive list, it does not exist. Do not say it. Do not hint at it.
- NEVER add qualifiers, suffixes, version numbers, or parenthetical notes to item names (e.g. "Beta", "Classic", "Old", "- Version 2"). Use the exact name from the list, character for character.
- When you name a SPECIFIC item that EXISTS in the archive list, wrap ONLY that exact name in double asterisks: **Item Name**.
- The name inside ** MUST match the current response language: English name for English responses, Arabic name for Arabic responses. NEVER put an Arabic name inside ** in an English response, and NEVER put an English name inside ** in an Arabic response.
- NEVER wrap a word in asterisks unless the exact name (or a very close form) appears in the archive list. Descriptive, generic, or contextual words must stay in plain text.
- If the archive list is empty or has no relevant match: speak warmly about the region's general character and heritage WITHOUT naming any specific item.
- Do NOT use hashtags (#).
- NEVER mention "database", "archive", "Athar", "the platform", "Vision 2030", or that you are an AI.
- BANNED phrases: (للأسف، أعتذر، قاعدة بياناتي، لا تتوفر لدي معلومات).
- REGION LOCK: You may ONLY reference items from the archive list below. If the user asks about heritage from a DIFFERENT region, acknowledge their curiosity politely then redirect: "My expertise is this region — let me tell you about..."

--- TRIP MENTION RULE (STRICT) ---
- NEVER mention, recommend, or hint at items of type [trip] unless the user's CURRENT message explicitly asks for a trip suggestion or expresses a clear intent to visit/go somewhere.
- Questions about food, clothing, landmarks, or history are intellectual curiosity — NOT trip requests.
- Trip intent examples: "suggest a trip", "I want to visit X", "where should I go", "اقترح رحلة", "أبغى أروح".

--- CROSS-REGION CULTURAL OVERLAP ---
- The "Closest Matches" may occasionally include items from a NEIGHBORING region when the user asks about something that spans regional borders (tribes, dishes, customs).
- If such an item directly and specifically answers the user's question, you MAY reference it by its exact name in **bold**.
- When you do, briefly acknowledge its primary cultural home (e.g. "This tradition is more closely tied to the tribes of southern Hejaz…").
- This is an EXCEPTION. For general questions about the region, stay within the local archive.

--- MULTI-ITEM ANSWERS ---
- When the user's question names a SPECIFIC entity (tribe, family, sub-region) and the "Closest Matches" contain MORE THAN ONE item that directly references that entity, you MUST mention them ALL in your answer.
- Each mentioned archive item must be wrapped in **bold** exactly once.
- Do not pick one and ignore the rest — the user explicitly asked about that entity, and they deserve every relevant item.

${archiveBlock}

${closestMatchesBlock}

--- OUTPUT TAIL (REQUIRED) ---
At the END of EVERY response, append EXACTLY one of these JSON blocks.

DEFAULT — use this in ALL cases unless ALL THREE conditions below are simultaneously true:
<<<RECOMMENDED>>>{"itemIds":[]}<<<END>>>

Only switch to the non-empty block when ALL THREE conditions are met:
  1. The user's message explicitly asked about a SPECIFIC named item (not a general topic, follow-up, or continuation).
  2. You referenced that specific item by its exact archive name (wrapped in **) in your reply.
  3. The item's id appears verbatim in the archive list above.

If ANY condition is not met, use the empty block.
Always-empty situations (non-exhaustive): greetings, "tell me more" / "continue", general cultural overviews, clarifying questions, out-of-scope redirections, follow-up questions on a topic already mentioned.

Maximum ${MAX_SUGGESTED_ITEMS} item IDs. Never invent or guess an id.`;

    // 6. Build conversation turns
    const historyText = (recentMessages || [])
      .slice(-6)
      .map((m) => `${m.role === "user" ? (isAr ? "المستخدم" : "User") : "Rawi"}: ${m.content}`)
      .join("\n");

    const userPrompt = historyText
      ? `${isAr ? "سياق المحادثة:" : "Conversation context:"}\n${historyText}\n\n${isAr ? "المستخدم" : "User"}: ${userMessage}`
      : `${isAr ? "المستخدم" : "User"}: ${userMessage}`;

    // 7. Generate response
    const chatModel = genAI.getGenerativeModel({
      model: RAWI_CHAT_MODEL,
      systemInstruction: systemPrompt,
    });
    let rawText: string;
    try {
      const result = await chatModel.generateContent(userPrompt);
      rawText = result.response.text()?.trim() ?? "";

      // An empty string means the model returned a blocked/empty response.
      // Treat it the same as a caught exception and use the persona fallback.
      if (!rawText) {
        logger.warn("[askRawi] Empty response from model", { conversationId });
        rawText = isAr
          ? "موضوعي التراث والثقافة السعودية. هل تودّ أن أحدّثك عن هذه المنطقة؟"
          : "My focus is Saudi heritage and culture. Shall we explore this region together?";
      }
    } catch (err: any) {
      // Graceful fallback instead of crashing the app. The model can reject
      // out-of-scope or policy-violating prompts — return a persona-consistent
      // redirect so the user sees Rawi's voice, not a system error.
      logger.warn("[askRawi] Gemini generation issue — returning persona fallback", {
        conversationId,
        error: err?.message ?? String(err),
      });
      rawText = isAr
        ? "أنا راوي، رفيقك في استكشاف التراث السعودي. هل لديك سؤال عن هذه المنطقة؟"
        : "I'm Rawi, your guide to Saudi heritage. Is there something about this region you'd like to explore?";
    }

    // 8. Strip the (now-unused) recommendation block if the model still emits
    //    it, then clean ** from any name not in the archive.
    let visibleText = rawText.replace(/<<<RECOMMENDED>>>[\s\S]*?<<<END>>>/, "").trim();

    // ✦ FIX: strip ** from any name not in the archive (prevents invented items being highlighted)
    visibleText = visibleText.replace(/\*\*(.+?)\*\*/g, (full, inner) => {
      const name = String(inner).trim();
      return allowedNames.has(name) ? full : name;
    });

    // 9. Build a name → meta lookup (both languages) so a bolded name in the
    //    reply can be resolved to its real document.
    const metaByName = new Map<string, CachedEmbedding>();
    for (const m of filteredCache.values()) {
      if (m.titleAr?.trim()) metaByName.set(m.titleAr.trim(), m);
      if (m.titleEn?.trim()) metaByName.set(m.titleEn.trim(), m);
    }
    // عناصر مسترجَعة عبر البحث الهجين من مناطق مجاورة
    for (const d of topDocs) {
      if (d.meta.titleAr?.trim()) metaByName.set(d.meta.titleAr.trim(), d.meta);
      if (d.meta.titleEn?.trim()) metaByName.set(d.meta.titleEn.trim(), d.meta);
    }

    // 10. SOURCE OF TRUTH = the reply itself. Suggestion cards mirror exactly
    //     the entities Rawi named (wrapped in **) — nothing invented, no blind
    //     fill. Order follows appearance order in the text for visual coherence.
    const suggestedItems: Array<{
      id: string;
      type: string;
      titleAr: string;
      titleEn: string;
      imageUrl: string | null;
    }> = [];
    const seenIds = new Set<string>();

    const boldMatches = visibleText.matchAll(/\*\*(.+?)\*\*/g);
    for (const match of boldMatches) {
      if (suggestedItems.length >= MAX_SUGGESTED_ITEMS) break;
      const name = String(match[1]).trim();
      const meta = metaByName.get(name);
      if (!meta || seenIds.has(meta.docId)) continue;
      seenIds.add(meta.docId);
      suggestedItems.push({
        id: meta.docId,
        type: meta.type,
        titleAr: meta.titleAr,
        titleEn: meta.titleEn,
        imageUrl: meta.imageUrl,
      });
    }

    // NOTE: Suggestion cards mirror ONLY the entities Rawi actually named in
    // the reply (wrapped in **). There is no automatic interest-based trip
    // fill and no blind fallback. Trips appear exactly like landmarks and
    // archive items — only when Rawi mentions them in the text. Because trips
    // now carry embeddings, Rawi naturally surfaces a relevant trip in its
    // reply when the tourist expresses intent (e.g. asks about a trip, tour,
    // or experience), and that named trip then becomes a card. If Rawi names
    // nothing (greetings, general topics, out-of-scope redirects), no cards
    // show — the correct, consistent behaviour.

    // TEMP DIAGNOSTIC: confirm exactly what reaches each card
    for (const s of suggestedItems) {
      logger.info(`[suggest] id=${s.id} type=${s.type} titleEn="${s.titleEn}" img=${s.imageUrl ? "yes" : "NULL"}`);
    }

    logger.info(`[askRawi] session=${conversationId} locale=${locale} region=${wantedRegion} topDocs=${topDocs.length} suggested=${suggestedItems.length}`);

    return { reply: visibleText, suggestedItems };
  }
);

export const inspectDocumentShapes = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async () => {
    const collections = ["attractions", "trips", "events", "cultural_items"];
    const samples: Record<string, any> = {};

    for (const collectionName of collections) {
      const snapshot = await db.collection(collectionName).limit(2).get();
      samples[collectionName] = snapshot.docs.map((doc) => {
        const data = doc.data();
        // Print only field names + types + first 50 chars of values
        const shape: Record<string, string> = {};
        for (const [key, value] of Object.entries(data)) {
          if (key === "embedding") {
            shape[key] = `array(${Array.isArray(value) ? value.length : 0})`;
          } else if (typeof value === "object" && value !== null) {
            shape[key] = `object: ${JSON.stringify(value).slice(0, 100)}`;
          } else {
            shape[key] = `${typeof value}: ${String(value).slice(0, 50)}`;
          }
        }
        return { docId: doc.id, fields: shape };
      });
    }

    logger.info("[inspect] Document shapes:", JSON.stringify(samples, null, 2));
    return { samples };
  }
);

// =====================================================
// NOTIFICATIONS — FCM Push + Firestore In-App (dual-layer)
// =====================================================

interface BilingualText {
  ar: string;
  en: string;
}

interface NotificationPayload {
  type: string;
  title: BilingualText;
  body: BilingualText;
}

const NOTIFICATION_COPY: Record<string, NotificationPayload> = {
  contribution_submitted: {
    type: "contribution_submitted",
    title: { ar: "مساهمة جديدة بانتظار المراجعة", en: "New Contribution Awaiting Review" },
    body:  { ar: "قدّم سائح مساهمة جديدة تحتاج للمراجعة.", en: "A tourist submitted a contribution for review." },
  },
  contribution_approved: {
    type: "contribution_approved",
    title: { ar: "تم قبول المساهمة", en: "Contribution Approved" },
    body:  { ar: "تم قبول مساهمتك بنجاح وإضافة النقاط لحسابك.", en: "Your contribution was approved and points have been added." },
  },
  contribution_rejected: {
    type: "contribution_rejected",
    title: { ar: "تم رفض المساهمة", en: "Contribution Rejected" },
    body:  { ar: "تم رفض مساهمتك. يرجى مراجعة السبب.", en: "Your contribution was rejected. Please review the reason." },
  },
  trip_submitted: {
    type: "trip_submitted",
    title: { ar: "رحلة جديدة بانتظار المراجعة", en: "New Trip Awaiting Review" },
    body:  { ar: "قام مرشد بتقديم رحلة جديدة تحتاج للمراجعة.", en: "A guide submitted a new trip for review." },
  },
  trip_approved: {
    type: "trip_approved",
    title: { ar: "تم قبول رحلتك", en: "Trip Approved" },
    body:  { ar: "تهانينا! رحلتك متاحة الآن للحجز.", en: "Congratulations! Your trip is now open for bookings." },
  },
  trip_rejected: {
    type: "trip_rejected",
    title: { ar: "تم رفض رحلتك", en: "Trip Rejected" },
    body:  { ar: "تم رفض رحلتك. يرجى مراجعة التفاصيل.", en: "Your trip was rejected. Please review the details." },
  },
  booking_new: {
    type: "booking_new",
    title: { ar: "حجز جديد", en: "New Booking" },
    body:  { ar: "لديك حجز جديد من سائح. تحقق من التفاصيل.", en: "A tourist booked your trip. Review the details." },
  },
  booking_approved: {
    type: "booking_approved",
    title: { ar: "تم قبول الحجز", en: "Booking Approved" },
    body:  { ar: "تم قبول حجزك بنجاح. استعد لرحلتك!", en: "Your booking is confirmed. Get ready for your trip!" },
  },
  booking_cancelled: {
    type: "booking_cancelled",
    title: { ar: "تم إلغاء الحجز", en: "Booking Cancelled" },
    body:  { ar: "تم إلغاء حجزك.", en: "Your booking has been cancelled." },
  },
  booking_rejected: {
    type: "booking_rejected",
    title: { ar: "تعذّر تأكيد الحجز", en: "Booking Could Not Be Confirmed" },
    body:  { ar: "نأسف، الرحلة وصلت حدها الأقصى من الحجوزات.", en: "Sorry, this trip is fully booked." },
  },
  booking_auto_approved: {
    type: "booking_auto_approved",
    title: { ar: "تم تأكيد حجزك تلقائيًا", en: "Booking Auto-Confirmed" },
    body:  { ar: "لم يرد المرشد خلال 48 ساعة، تم تأكيد حجزك تلقائيًا.", en: "The guide did not respond within 48 hours, your booking has been auto-confirmed." },
  },
  booking_guide_auto_approved: {
    type: "booking_guide_auto_approved",
    title: { ar: "تم تأكيد الحجز تلقائيًا", en: "Booking Auto-Confirmed" },
    body:  { ar: "لم ترد على الحجز خلال 48 ساعة، تم تأكيده تلقائيًا.", en: "You did not respond within 48 hours, the booking was auto-confirmed." },
  },
  booking_expired: {
    type: "booking_expired",
    title: { ar: "انتهت صلاحية الحجز", en: "Booking Expired" },
    body:  { ar: "انتهت صلاحية حجزك لأن الرحلة مرت دون تأكيد.", en: "Your booking expired because the trip passed without confirmation." },
  },
  booking_pending_reminder: {
    type: "booking_pending_reminder",
    title: { ar: "لديك حجز بانتظار ردك", en: "Booking Awaiting Your Response" },
    body:  { ar: "لديك حجز لم تؤكده بعد. سيتم تأكيده تلقائيًا خلال 24 ساعة إن لم ترد.", en: "You have a pending booking. It will be auto-confirmed in 24 hours if you don't respond." },
  },
  booking_completed: {
    type: "booking_completed",
    title: { ar: "اكتملت رحلتك", en: "Trip Completed" },
    body:  { ar: "نأمل أن تكون رحلتك رائعة! شاركنا تقييمك للمرشد.", en: "We hope you had a great trip! Share your rating for the guide." },
  },
  booking_auto_completed: {
    type: "booking_auto_completed",
    title: { ar: "اكتملت الرحلة تلقائيًا", en: "Trip Auto-Completed" },
    body:  { ar: "تم إكمال الرحلة تلقائيًا بعد 24 ساعة من وقت الانتهاء. إذا كان هناك إشكال، تواصل معنا عبر البريد.", en: "The trip was auto-completed 24 hours after the scheduled end time. Contact support if there is an issue." },
  },
  booking_reminder: {
    type: "booking_reminder",
    title: { ar: "تذكير بالرحلة", en: "Trip Reminder" },
    body:  { ar: "لديك رحلة اليوم. يرجى تذكر وضعها كمكتملة بعد انتهائها.", en: "You have a trip today. Please remember to mark it completed after it ends." },
  },
  guide_verified: {
    type: "guide_verified",
    title: { ar: "تم توثيق حسابك", en: "Account Verified" },
    body:  { ar: "تهانينا! تم توثيق حسابك كمرشد سياحي معتمد.", en: "Congratulations! Your guide account has been verified." },
  },
  guide_rejected: {
    type: "guide_rejected",
    title: { ar: "تم رفض طلب التوثيق", en: "Verification Rejected" },
    body:  { ar: "تم رفض طلب توثيقك كمرشد سياحي.", en: "Your guide verification request has been rejected." },
  },
  points_awarded: {
    type: "points_awarded",
    title: { ar: "نقاط إضافية", en: "Bonus Points Awarded" },
    body:  { ar: "تم منحك نقاطاً إضافية من الإدارة.", en: "The admin has awarded you bonus points." },
  },
};

/**
 * Writes one Firestore in-app notification document under
 * users/{userId}/notifications/{notificationId or auto-id}.
 */
async function createInAppNotification(
  userId: string,
  notif: NotificationPayload,
  bodyOverride?: BilingualText,
  notificationId?: string
): Promise<void> {
  const collection = db
    .collection("users")
    .doc(userId)
    .collection("notifications");

  const docRef = notificationId ? collection.doc(notificationId) : collection.doc();

  await docRef.set({
      type: notif.type,
      title: notif.title,
      body: bodyOverride ?? notif.body,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
    });
}

// Notification types that map to each user preference key.
const BOOKING_NOTIF_TYPES = new Set([
  "booking_new", "booking_approved", "booking_cancelled", "booking_rejected",
  "booking_auto_approved", "booking_guide_auto_approved", "booking_expired",
  "booking_completed", "booking_auto_completed", "booking_reminder", "booking_pending_reminder",
]);
const EVENT_REMINDER_TYPES = new Set([
  "contribution_approved", "contribution_rejected", "contribution_submitted",
  "trip_submitted", "trip_approved", "trip_rejected",
  "guide_verified", "guide_rejected", "points_awarded",
]);

/**
 * Reads the FCM tokens for a user and sends a multicast push message.
 * Silently ignores users with no tokens (guests, web-only users, etc.).
 * Respects the user's notification preferences stored under notificationPrefs.
 * Removes any tokens reported as invalid by FCM to keep the list clean.
 */
async function sendPushToUser(
  userId: string,
  notif: NotificationPayload,
  bodyOverride?: BilingualText
): Promise<void> {
  const userSnap = await db.collection("users").doc(userId).get();
  if (!userSnap.exists) return;

  const userData = userSnap.data()!;
  const tokens: string[] = userData.fcmTokens ?? [];
  if (tokens.length === 0) return;

  // Gate on the user's notification preferences (default ON if not set).
  const prefs = userData.notificationPrefs ?? {};
  if (BOOKING_NOTIF_TYPES.has(notif.type) && prefs.bookingNotifications === false) {
    logger.info(`[FCM] Skipping ${notif.type} for ${userId} — bookingNotifications disabled`);
    return;
  }
  if (EVENT_REMINDER_TYPES.has(notif.type) && prefs.eventReminders === false) {
    logger.info(`[FCM] Skipping ${notif.type} for ${userId} — eventReminders disabled`);
    return;
  }

  const title = notif.title; // bilingual; FCM will show one string — we use Arabic as primary
  const body  = bodyOverride ?? notif.body;

  const message: Parameters<ReturnType<typeof getMessaging>["sendEachForMulticast"]>[0] = {
    tokens,
    notification: {
      title: title.ar,   // device system notification text (Arabic primary)
      body:  body.ar,
    },
    data: {
      type:    notif.type,
      titleAr: title.ar,
      titleEn: title.en,
      bodyAr:  body.ar,
      bodyEn:  body.en,
    },
    android: {
      notification: {
        channelId: "athar_high_importance",
        priority: "high",
      },
    },
    apns: {
      payload: {
        aps: { sound: "default", badge: 1 },
      },
    },
  };

  const response = await getMessaging().sendEachForMulticast(message);
  logger.info(`[FCM] ${notif.type} → ${userId}: ${response.successCount} ok, ${response.failureCount} failed`);

  // Prune stale tokens reported by FCM.
  const invalidTokens: string[] = [];
  response.responses.forEach((res, idx) => {
    if (!res.success && (
      res.error?.code === "messaging/registration-token-not-registered" ||
      res.error?.code === "messaging/invalid-registration-token"
    )) {
      invalidTokens.push(tokens[idx]);
    }
  });
  if (invalidTokens.length > 0) {
    await db.collection("users").doc(userId).update({
      fcmTokens: FieldValue.arrayRemove(...invalidTokens),
    });
    logger.info(`[FCM] Pruned ${invalidTokens.length} stale token(s) for ${userId}`);
  }
}

/**
 * Convenience wrapper: writes Firestore doc AND sends FCM push for one user.
 */
async function notify(
  userId: string,
  type: string,
  bodyOverride?: BilingualText,
  notificationId?: string
): Promise<void> {
  const notif = NOTIFICATION_COPY[type];
  if (!notif) {
    logger.warn(`[notify] Unknown notification type: ${type}`);
    return;
  }
  await Promise.all([
    createInAppNotification(userId, notif, bodyOverride, notificationId),
    sendPushToUser(userId, notif, bodyOverride),
  ]);
}

/**
 * Notifies every admin user. Used when a tourist/guide submits content.
 */
async function notifyAllAdmins(type: string, eventId: string): Promise<void> {
  const notif = NOTIFICATION_COPY[type];
  if (!notif) return;

  const adminSnap = await db
    .collection("users")
    .where("role", "==", "admin")
    .get();

  await Promise.all(
    adminSnap.docs.map((doc) =>
      notify(doc.id, type, undefined, `${eventId}_${type}_${doc.id}`)
    )
  );
}

// ── Trigger 1: Tourist submits a contribution → notify all admins ──────────

export const onContributionSubmitted = onDocumentCreated(
  "contributions/{contributionId}",
  async (event) => {
    if (!event.data) return;
    const data = event.data.data();
    if (data.status !== "pending") return; // only fire for new submissions
    logger.info(`[notif] New contribution ${event.params.contributionId}`);
    await notifyAllAdmins(
      "contribution_submitted",
      event.params.contributionId
    );
  }
);

// ── Trigger 2: Admin approves or rejects a contribution → notify tourist ───

export const onContributionReviewed = onDocumentUpdated(
  "contributions/{contributionId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return; // no status change

    const touristId: string = after.touristId;
    if (!touristId) return;

    if (after.status === "approved") {
      await notify(
        touristId,
        "contribution_approved",
        undefined,
        `${event.params.contributionId}_contribution_approved`
      );
    } else if (after.status === "rejected") {
      const reason: string = after.rejectionReason ?? "";
      const bodyOverride: BilingualText | undefined = reason
        ? { ar: reason, en: reason }
        : undefined;
      await notify(
        touristId,
        "contribution_rejected",
        bodyOverride,
        `${event.params.contributionId}_contribution_rejected`
      );
    }
  }
);

// ── Trigger 3: Guide submits a trip → notify all admins ───────────────────

export const onTripSubmitted = onDocumentCreated(
  "trips/{tripId}",
  async (event) => {
    if (!event.data) return;
    const data = event.data.data();
    if (data.status !== "pending") return;
    logger.info(`[notif] New trip submitted ${event.params.tripId}`);
    await notifyAllAdmins("trip_submitted", event.params.tripId);
  }
);

// ── Trigger 4: Admin approves or rejects a trip → notify guide ────────────

export const onTripReviewed = onDocumentUpdated(
  "trips/{tripId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const tutorId: string = after.tutorId ?? "";
    if (!tutorId) return;

    if (after.status === "approved") {
      await notify(
        tutorId,
        "trip_approved",
        undefined,
        `${event.params.tripId}_trip_approved`
      );
    } else if (after.status === "rejected") {
      await notify(
        tutorId,
        "trip_rejected",
        undefined,
        `${event.params.tripId}_trip_rejected`
      );
    }
  }
);

// ── Trigger 5: Tourist books a trip → capacity guard + notify guide ──────────
//
// Uses a Firestore transaction to atomically check and decrement availableSeats.
// If the trip is fully booked the booking document is immediately rejected and
// the tourist is notified; the guide is NOT notified in that case.

export const onBookingCreated = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    if (!event.data) return;
    const data = event.data.data();
    const tutorId: string = data.tutorId ?? "";
    const tripId: string = data.tripId ?? "";
    const touristId: string = data.touristId ?? "";
    if (!tutorId || !tripId) return;

    const bookingRef = db.collection("bookings").doc(event.params.bookingId);
    const tripRef = db.collection("trips").doc(tripId);

    // Idempotency guard: if this function already ran (retry scenario), the
    // booking status will no longer be "pending". Skip to avoid double-decrement.
    const currentSnap = await bookingRef.get();
    const currentStatus = (currentSnap.data() as any)?.status as string | undefined;
    if (currentStatus && currentStatus !== "pending") {
      logger.info(`[capacity] Skipping already-processed booking ${event.params.bookingId} (status=${currentStatus})`);
      return;
    }

    // adultsCount + ceil(childrenCount / 2) = adult-equivalent slot consumption
    const adultsCount: number = data.adultsCount ?? 1;
    const childrenCount: number = data.childrenCount ?? 0;
    const slotsNeeded = adultsCount + Math.ceil(childrenCount / 2);

    // Build the list of dates this booking spans (multi-day support)
    const startDateStr: string = data.date ?? "";
    const durationDays: number = data.tripDurationDays ?? 1;
    const bookedDates: string[] = [];
    if (startDateStr) {
      for (let i = 0; i < durationDays; i++) {
        const d = new Date(startDateStr + "T00:00:00Z");
        d.setUTCDate(d.getUTCDate() + i);
        bookedDates.push(d.toISOString().slice(0, 10));
      }
    }

    let capacityExceeded = false;

    try {
      await db.runTransaction(async (tx) => {
        const tripSnap = await tx.get(tripRef);
        if (!tripSnap.exists) return;

        const maxCapacity: number | null =
          (tripSnap.data()!.maxCapacity as number | undefined) ?? null;

        // No capacity limit or no date info — allow booking
        if (maxCapacity === null || bookedDates.length === 0) return;

        // Read all per-date capacity docs upfront (all reads must precede writes)
        const capacityRefs = bookedDates.map((date) =>
          db.collection("trip_capacity").doc(`${tripId}_${date}`)
        );
        const capacitySnaps = await Promise.all(
          capacityRefs.map((ref) => tx.get(ref))
        );

        // Resolve current available seats (lazy-init to maxCapacity if doc missing)
        const currentAvailables = capacitySnaps.map((snap) =>
          snap.exists
            ? ((snap.data() as any).availableSeats as number ?? maxCapacity)
            : maxCapacity
        );

        // Reject if any date in the span lacks enough seats
        for (const avail of currentAvailables) {
          if (avail < slotsNeeded) {
            capacityExceeded = true;
            tx.update(bookingRef, {
              status: "rejected",
              rejectionReason: "capacity_exceeded",
            });
            return;
          }
        }

        // Decrement each date's capacity
        for (let i = 0; i < bookedDates.length; i++) {
          tx.set(capacityRefs[i], {
            tripId,
            date: bookedDates[i],
            availableSeats: currentAvailables[i] - slotsNeeded,
          });
        }
      });
    } catch (err) {
      logger.error(`[capacity] Transaction failed for booking ${event.params.bookingId}`, err);
    }

    if (capacityExceeded) {
      logger.info(`[capacity] Booking ${event.params.bookingId} rejected — trip fully booked`);
      if (touristId) {
        await notify(
          touristId,
          "booking_rejected",
          undefined,
          `${event.params.bookingId}_booking_rejected`
        );
      }
      return;
    }

    logger.info(`[notif] New booking ${event.params.bookingId} → guide ${tutorId}`);
    await notify(
      tutorId,
      "booking_new",
      undefined,
      `${event.params.bookingId}_booking_new`
    );
  }
);

// ── Trigger 6: Booking status changed → notify tourist + restore seats ────────
//
// Seat restoration: if a booking moves to rejected or cancelled we increment
// availableSeats back. Exception: rejectionReason === 'capacity_exceeded' means
// the booking was never confirmed (seats were never decremented), so skip.

export const onBookingStatusChanged = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const touristId: string = after.touristId ?? "";
    const tripId: string = after.tripId ?? "";

    // ── Seat restoration ───────────────────────────────────────────────────
    const shouldRestore =
      (after.status === "rejected" || after.status === "cancelled") &&
      after.rejectionReason !== "capacity_exceeded" &&
      tripId;

    if (shouldRestore) {
      const adultsCount: number = after.adultsCount ?? 1;
      const childrenCount: number = after.childrenCount ?? 0;
      const slotsToRestore = adultsCount + Math.ceil(childrenCount / 2);
      const bookingDate: string = after.date ?? "";
      const bookingDuration: number = after.tripDurationDays ?? 1;

      if (bookingDate) {
        try {
          const tripSnap = await db.collection("trips").doc(tripId).get();
          const maxCapacity: number | null =
            (tripSnap.data()?.maxCapacity as number | undefined) ?? null;

          if (maxCapacity !== null) {
            const batch = db.batch();
            for (let i = 0; i < bookingDuration; i++) {
              const d = new Date(bookingDate + "T00:00:00Z");
              d.setUTCDate(d.getUTCDate() + i);
              const dateStr = d.toISOString().slice(0, 10);
              const capacityRef = db
                .collection("trip_capacity")
                .doc(`${tripId}_${dateStr}`);
              const capacitySnap = await capacityRef.get();
              if (capacitySnap.exists) {
                const current =
                  (capacitySnap.data() as any).availableSeats as number ?? 0;
                batch.update(capacityRef, {
                  availableSeats: Math.min(current + slotsToRestore, maxCapacity),
                });
              }
            }
            await batch.commit();
            logger.info(
              `[seats] Restored ${slotsToRestore} seat(s) to trip ${tripId} ` +
              `across ${bookingDuration} date(s) from ${bookingDate}`
            );
          }
        } catch (err) {
          logger.error(`[seats] Failed to restore seats for trip ${tripId}`, err);
        }
      }
    }

    // ── Reward restoration ─────────────────────────────────────────────────
    const rewardId = after.rewardId as string | undefined;
    if (
      rewardId &&
      touristId &&
      (after.status === "rejected" || after.status === "cancelled")
    ) {
      try {
        await db
          .collection("users").doc(touristId)
          .collection("rewards").doc(rewardId)
          .update({ isUsed: false, usedAt: null, bookingId: null });
        logger.info(`[reward] Restored reward ${rewardId} for tourist ${touristId}`);
      } catch (err) {
        logger.error(`[reward] Failed to restore reward ${rewardId}`, err);
      }
    }

    // ── Tourist notification ───────────────────────────────────────────────
    if (!touristId) return;

    if (after.status === "approved") {
      await notify(
        touristId,
        "booking_approved",
        undefined,
        `${event.params.bookingId}_booking_approved`
      );
    } else if (after.status === "cancelled") {
      await notify(
        touristId,
        "booking_cancelled",
        undefined,
        `${event.params.bookingId}_booking_cancelled`
      );
    } else if (after.status === "rejected" && after.rejectionReason !== "capacity_exceeded") {
      await notify(
        touristId,
        "booking_rejected",
        undefined,
        `${event.params.bookingId}_booking_rejected`
      );
    } else if (after.status === "completed") {
      await notify(
        touristId,
        "booking_completed",
        undefined,
        `${event.params.bookingId}_booking_completed`
      );
    }
  }
);

function parseBookingDate(date: string): Date | null {
  if (!date) return null;
  const parsed = new Date(`${date}T00:00:00`);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function extractTimeParts(timeSlot: string): Array<[number, number]> {
  const matches = [...timeSlot.matchAll(/(\d{1,2}):(\d{2})/g)];
  return matches.map((match) => [Number(match[1]), Number(match[2])]);
}

function scheduledBookingStart(date: string, timeSlot: string): Date | null {
  const bookingDate = parseBookingDate(date);
  const timeParts = extractTimeParts(timeSlot);
  if (!bookingDate || timeParts.length === 0) return null;
  const [hours, minutes] = timeParts[0];
  return new Date(
    bookingDate.getFullYear(),
    bookingDate.getMonth(),
    bookingDate.getDate(),
    hours,
    minutes,
  );
}

function scheduledBookingEnd(date: string, timeSlot: string, durationDays?: number): Date | null {
  const bookingDate = parseBookingDate(date);
  const timeParts = extractTimeParts(timeSlot);
  if (!bookingDate || timeParts.length === 0) return null;
  const [hours, minutes] = timeParts[timeParts.length - 1];
  const lastDay = new Date(bookingDate);
  lastDay.setDate(lastDay.getDate() + ((durationDays ?? 1) - 1));
  return new Date(
    lastDay.getFullYear(),
    lastDay.getMonth(),
    lastDay.getDate(),
    hours,
    minutes,
  );
}

function toRiyadhYmd(date: Date): string {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Riyadh",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  const parts = formatter.formatToParts(date);
  const year = parts.find((part) => part.type === "year")?.value ?? "";
  const month = parts.find((part) => part.type === "month")?.value ?? "";
  const day = parts.find((part) => part.type === "day")?.value ?? "";
  return `${year}-${month}-${day}`;
}

function isRiyadhDay(date: Date, other: Date): boolean {
  return toRiyadhYmd(date) === toRiyadhYmd(other);
}

export const remindGuidesToCompleteBookings = onSchedule(
  { schedule: "0 8 * * *", timeZone: "Asia/Riyadh" },
  async () => {
    const today = new Date();
    const snap = await db
      .collection("bookings")
      .where("status", "==", "approved")
      .get();

    const reminders = snap.docs.filter((doc) => {
      const data = doc.data();
      const start = scheduledBookingStart(String(data.date ?? ""), String(data.timeSlot ?? ""));
      return start != null && isRiyadhDay(today, start);
    });

    if (reminders.length === 0) {
      logger.info("[bookingReminder] No guide reminders to send.");
      return;
    }

    const notificationPromises = reminders.flatMap((doc) => {
      const data = doc.data();
      const tutorId: string = data.tutorId ?? "";
      const date: string = data.date ?? "";
      const timeSlot: string = data.timeSlot ?? "";

      if (!tutorId) return [];

      return [notify(
        tutorId,
        "booking_reminder",
        {
          ar: `تذكير: لديك رحلة اليوم ${date} ${timeSlot}. يرجى وضعها كمكتملة بعد انتهاء الرحلة.`,
          en: `Reminder: you have a trip today on ${date} ${timeSlot}. Please mark it completed after the trip ends.`,
        },
        `${doc.id}_booking_reminder`,
      )];
    });

    await Promise.all(notificationPromises);
    logger.info(`[bookingReminder] Sent ${notificationPromises.length} reminder(s).`);
  }
);

export const autoCompleteBookings = onSchedule(
  { schedule: "0 * * * *", timeZone: "Asia/Riyadh" },
  async () => {
    const snap = await db
      .collection("bookings")
      .where("status", "==", "approved")
      .get();

    const now = Date.now();
    const batch = db.batch();
    let count = 0;
    const notifications: Array<Promise<void>> = [];

    for (const doc of snap.docs) {
      const data = doc.data();
      const scheduledEnd = scheduledBookingEnd(
        String(data.date ?? ""),
        String(data.timeSlot ?? ""),
        data.tripDurationDays as number | undefined,
      );

      if (!scheduledEnd) continue;

      const deadline = scheduledEnd.getTime() + (24 * 60 * 60 * 1000);
      if (now >= deadline) {
        batch.update(doc.ref, {
          status: "completed",
          completedAt: FieldValue.serverTimestamp(),
          completedBy: "system_auto",
        });
        const tutorId: string = data.tutorId ?? "";
        if (tutorId) {
          notifications.push(
            notify(
              tutorId,
              "booking_auto_completed",
              undefined,
              `${doc.id}_booking_auto_completed`,
            ),
          );
        }
        count += 1;
      }
    }

    if (count > 0) {
      await batch.commit();
      await Promise.all(notifications);
      logger.info(`[autoCompleteBookings] Auto-completed ${count} booking(s) after 24h fallback.`);
    }
  }
);

export const markBookingCompleted = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 30,
    region: "us-central1",
  },
  async (request) => {
    const authUid = request.auth?.uid;
    if (!authUid) {
      throw new HttpsError("unauthenticated", "You must be signed in to complete a booking.");
    }

    const { bookingId } = request.data as { bookingId?: string };
    if (!bookingId?.trim()) {
      throw new HttpsError("invalid-argument", "bookingId is required.");
    }

    const bookingRef = db.collection("bookings").doc(bookingId);
    const userRef = db.collection("users").doc(authUid);

    await db.runTransaction(async (tx) => {
      const [bookingSnap, userSnap] = await Promise.all([tx.get(bookingRef), tx.get(userRef)]);

      if (!bookingSnap.exists) {
        throw new HttpsError("not-found", "Booking not found.");
      }

      const userData = userSnap.data() as FirebaseFirestore.DocumentData | undefined;
      if (!userData || userData.role !== "tutor") {
        throw new HttpsError("permission-denied", "Only the assigned guide can complete this booking.");
      }

      const bookingData = bookingSnap.data() as FirebaseFirestore.DocumentData;
      if (bookingData.tutorId !== authUid) {
        throw new HttpsError("permission-denied", "This booking does not belong to the signed-in guide.");
      }

      if (bookingData.status === "completed") {
        return;
      }

      if (bookingData.status !== "approved") {
        throw new HttpsError("failed-precondition", "Only approved bookings can be completed.");
      }

      const scheduledEnd = scheduledBookingEnd(String(bookingData.date ?? ""), String(bookingData.timeSlot ?? ""), bookingData.tripDurationDays as number | undefined);
      if (!scheduledEnd) {
        throw new HttpsError("failed-precondition", "Booking schedule is invalid.");
      }

      if (Date.now() < scheduledEnd.getTime()) {
        throw new HttpsError("failed-precondition", "This booking can only be completed after the scheduled trip time has passed.");
      }

      tx.update(bookingRef, {
        status: "completed",
        completedAt: FieldValue.serverTimestamp(),
        completedBy: authUid,
      });
    });

    // Slot cleanup: remove guide_slots for this booking's dates if no other
    // active bookings (pending/approved) remain for the same trip+date.
    const completedData = (await bookingRef.get()).data();
    if (completedData && (completedData.tutorType === "individual" || completedData.tripType === "private")) {
      const tutorId  = completedData.tutorId  as string | undefined;
      const tripId   = completedData.tripId   as string | undefined;
      const dateStr  = completedData.date     as string | undefined;
      const dur      = (completedData.tripDurationDays as number | undefined) ?? 1;

      if (tutorId && tripId && dateStr) {
        const remaining = await db.collection("bookings")
          .where("tutorId", "==", tutorId)
          .where("tripId",  "==", tripId)
          .where("status",  "in", ["pending", "approved"])
          .get();

        // Build set of dates still covered by active bookings
        const stillActive = new Set<string>();
        remaining.docs.forEach((doc) => {
          const d  = doc.data();
          const ds = d.date as string | undefined;
          const dd = (d.tripDurationDays as number | undefined) ?? 1;
          if (!ds) return;
          for (let i = 0; i < dd; i++) {
            const day = new Date(ds + "T00:00:00Z");
            day.setUTCDate(day.getUTCDate() + i);
            stillActive.add(day.toISOString().slice(0, 10));
          }
        });

        const slotBatch = db.batch();
        for (let i = 0; i < dur; i++) {
          const day = new Date(dateStr + "T00:00:00Z");
          day.setUTCDate(day.getUTCDate() + i);
          const slotDate = day.toISOString().slice(0, 10);
          if (!stillActive.has(slotDate)) {
            slotBatch.delete(db.collection("guide_slots").doc(`${tutorId}_${slotDate}`));
          }
        }
        await slotBatch.commit();
      }
    }
  }
);

// ── Trigger 7: Admin verifies a guide account → notify the guide ───────────

export const onGuideVerified = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;

    if (
      before.verificationStatus === after.verificationStatus ||
      after.role !== "tutor"
    ) return;

    if (after.verificationStatus === "verified") {
      logger.info(`[notif] Guide verified: ${event.params.userId}`);
      await notify(
        event.params.userId,
        "guide_verified",
        undefined,
        `${event.params.userId}_guide_verified`
      );
    } else if (after.verificationStatus === "rejected") {
      logger.info(`[notif] Guide rejected: ${event.params.userId}`);
      const reason = after.rejectionReason as string | undefined;
      const bodyOverride = reason
        ? { ar: `تم رفض طلب توثيقك. السبب: ${reason}`, en: `Your verification was rejected. Reason: ${reason}` }
        : undefined;
      await notify(
        event.params.userId,
        "guide_rejected",
        bodyOverride,
        `${event.params.userId}_guide_rejected`
      );
    }
  }
);

// ── Trigger 8: Admin awards bonus points → notify the tourist ─────────────
//
// The admin writes a `bonusPointsAwardedAt` timestamp field when awarding
// points. Watching for that field appearing (null → timestamp) is the
// cleanest signal because the `points` field also increments on every
// contribution approval.

export const onBonusPointsAwarded = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;

    // Fire only when bonusPointsAwardedAt is newly set by an admin action.
    if (
      before.bonusPointsAwardedAt === after.bonusPointsAwardedAt ||
      !after.bonusPointsAwardedAt ||
      after.role !== "tourist"
    ) return;

    logger.info(`[notif] Bonus points awarded to tourist: ${event.params.userId}`);
    await notify(
      event.params.userId,
      "points_awarded",
      undefined,
      `${event.params.userId}_points_awarded`
    );
  }
);

// ── Scheduled 1: Auto-approve bookings pending for > 48 hours ─────────────
//
// Runs every hour. Any booking still 'pending' after 48 h is auto-approved,
// provided the trip date hasn't already passed.

export const autoApproveBookings = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Riyadh", timeoutSeconds: 120, memory: "256MiB" },
  async () => {
    const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000);
    const todayStr = todayInRiyadh();

    const snap = await db
      .collection("bookings")
      .where("status", "==", "pending")
      .where("createdAt", "<=", cutoff)
      .get();

    if (snap.empty) {
      logger.info("[autoApprove] No pending bookings to process.");
      return;
    }

    const batch = db.batch();
    const notifications: Array<() => Promise<void>> = [];
    let approved = 0;
    let expired = 0;

    for (const doc of snap.docs) {
      const data = doc.data();
      const bookingDate = data.date as string | undefined;
      const touristId: string = data.touristId ?? "";
      const tutorId: string = data.tutorId ?? "";

      if (!bookingDate || bookingDate <= todayStr) {
        // Trip date already passed — expire the booking instead of leaving it stuck as pending
        batch.update(doc.ref, { status: "expired" });
        expired++;
        if (touristId) {
          notifications.push(() =>
            notify(touristId, "booking_expired", undefined, `${doc.id}_expired`)
          );
        }
        continue;
      }

      batch.update(doc.ref, { status: "approved", autoApproved: true });
      approved++;
      if (touristId) {
        notifications.push(() =>
          notify(
            touristId,
            "booking_auto_approved",
            undefined,
            `${doc.id}_booking_auto_approved`
          )
        );
      }

      if (tutorId) {
        notifications.push(() =>
          notify(
            tutorId,
            "booking_guide_auto_approved",
            undefined,
            `${doc.id}_booking_guide_auto_approved`
          )
        );
      }
    }

    try {
      await batch.commit();
      await Promise.all(notifications.map((fn) => fn()));
      logger.info(`[autoApprove] approved=${approved}, expired=${expired}, total_queried=${snap.size}`);
    } catch (err) {
      logger.error("[autoApprove] batch commit failed:", err);
    }
  }
);

// Remind guides once while a booking is close to auto-approval.

export const remindGuidesPendingBookings = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Riyadh", timeoutSeconds: 60, memory: "256MiB" },
  async () => {
    const lowerCutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const upperCutoff = new Date(Date.now() - 36 * 60 * 60 * 1000);
    const todayStr = todayInRiyadh();

    const snap = await db
      .collection("bookings")
      .where("status", "==", "pending")
      .where("createdAt", "<=", lowerCutoff)
      .where("createdAt", ">=", upperCutoff)
      .get();

    if (snap.empty) return;

    const notified = new Set<string>();
    let sent = 0;
    for (const doc of snap.docs) {
      const data = doc.data();
      const bookingId: string = data.bookingId ?? doc.id;
      const bookingDate = data.date as string | undefined;
      if (!bookingDate || bookingDate <= todayStr) continue;
      const tutorId: string = data.tutorId ?? "";
      if (tutorId && !notified.has(tutorId)) {
        notified.add(tutorId);
        const notificationId = `${bookingId}_booking_pending_reminder_${tutorId}`;
        const notifRef = db
          .collection("users").doc(tutorId)
          .collection("notifications").doc(notificationId);
        const existing = await notifRef.get();
        if (!existing.exists) {
          // Use a stable ID so the same reminder is not created twice.
          await notify(tutorId, "booking_pending_reminder", undefined, notificationId);
          sent++;
        }
      }
    }
    logger.info(`[guideReminder] Sent ${sent} guide reminder(s).`);
  }
);

// ── Trigger 9: New rating created → update Guide's aggregate ──────────────
//
// When a tourist submits a rating for a completed booking:
// 1. Atomically recomputes the guide's weighted-average rating and reviewsCount
//    on the user document.
// 2. Batch-updates the guideRating snapshot on all the guide's trip documents
//    so trip cards reflect the latest aggregate without N+1 reads.

export const onRatingCreated = onDocumentCreated(
  "ratings/{ratingId}",
  async (event) => {
    if (!event.data) return;
    const { tutorId, stars } = event.data.data() as {
      tutorId: string;
      stars: number;
    };
    if (!tutorId || typeof stars !== "number") return;

    const tutorRef = db.collection("users").doc(tutorId);

    // 1. Update aggregate on user document using a transaction.
    let newRating = stars;
    let newCount = 1;
    await db.runTransaction(async (tx) => {
      const tutorSnap = await tx.get(tutorRef);
      if (!tutorSnap.exists) return;
      const data = tutorSnap.data()!;
      const oldCount: number = data.reviewsCount ?? 0;
      const oldRating: number = data.rating ?? 0;
      newCount = oldCount + 1;
      newRating = ((oldRating * oldCount) + stars) / newCount;
      tx.update(tutorRef, { rating: newRating, reviewsCount: newCount });
    });

    // 2. Propagate guideRating snapshot to this guide's trip documents.
    const tripsSnap = await db
      .collection("trips")
      .where("tutorId", "==", tutorId)
      .get();

    if (!tripsSnap.empty) {
      const batch = db.batch();
      for (const doc of tripsSnap.docs) {
        batch.update(doc.ref, { guideRating: newRating, guideReviewsCount: newCount });
      }
      await batch.commit();
    }

    logger.info(`[rating] Guide ${tutorId}: new avg=${newRating.toFixed(2)}, count=${newCount}`);
  }
);

// ── Scheduled 3: Backfill heroCopy for existing items that predate the triggers ──
//
// Runs every 60 minutes. Scans all four content collections for documents that
// have no heroCopy field yet, picks up to 15 total across all collections, and
// generates copy sequentially with a 1 s gap to stay within Gemini rate limits.
// Once all items are backfilled this becomes a cheap no-op (empty query result).

const BACKFILL_BATCH_SIZE = 15;
const BACKFILL_COLLECTIONS = ["attractions", "cultural_items", "events", "trips"] as const;

export const backfillHeroCopy = onSchedule(
  {
    schedule: "every 60 minutes",
    timeZone: "Asia/Riyadh",
    timeoutSeconds: 300,
    memory: "256MiB",
    secrets: ["GEMINI_API_KEY"],
  },
  async () => {
    if (!GEMINI_KEY) {
      logger.warn("[backfillHeroCopy] GEMINI_API_KEY not set — skipping");
      return;
    }

    // Collect up to BACKFILL_BATCH_SIZE items missing heroCopy across all collections.
    type PendingItem = { collection: string; docId: string; data: FirebaseFirestore.DocumentData };
    const pending: PendingItem[] = [];

    for (const col of BACKFILL_COLLECTIONS) {
      if (pending.length >= BACKFILL_BATCH_SIZE) break;
      const remaining = BACKFILL_BATCH_SIZE - pending.length;
      const snap = await db
        .collection(col)
        .where("heroCopy", "==", null)
        .limit(remaining)
        .get();
      for (const doc of snap.docs) {
        pending.push({ collection: col, docId: doc.id, data: doc.data() });
      }
    }

    // Firestore stores absent fields as undefined, not null — re-query for missing field.
    // The above catches explicitly null-set docs; run a second pass for truly absent docs.
    if (pending.length < BACKFILL_BATCH_SIZE) {
      for (const col of BACKFILL_COLLECTIONS) {
        if (pending.length >= BACKFILL_BATCH_SIZE) break;
        const alreadyQueued = new Set(
          pending.filter((p) => p.collection === col).map((p) => p.docId)
        );
        const remaining = BACKFILL_BATCH_SIZE - pending.length;
        const snap = await db.collection(col).limit(remaining + alreadyQueued.size).get();
        for (const doc of snap.docs) {
          if (alreadyQueued.has(doc.id)) continue;
          const data = doc.data();
          if (!data.heroCopy) {
            pending.push({ collection: col, docId: doc.id, data });
            if (pending.length >= BACKFILL_BATCH_SIZE) break;
          }
        }
      }
    }

    if (pending.length === 0) {
      logger.info("[backfillHeroCopy] All items have heroCopy — nothing to do.");
      return;
    }

    logger.info(`[backfillHeroCopy] Found ${pending.length} item(s) missing heroCopy — processing sequentially.`);

    let succeeded = 0;
    let failed = 0;

    for (const item of pending) {
      try {
        await writeHeroCopy(item.collection, item.docId, item.data);
        succeeded++;
        logger.info(`[backfillHeroCopy] ✓ ${item.collection}/${item.docId}`);
      } catch (err) {
        failed++;
        console.error(`[backfillHeroCopy] ✗ ${item.collection}/${item.docId}`, err);
      }
      // 1 s gap between calls to respect Gemini rate limits.
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    logger.info(`[backfillHeroCopy] Done — succeeded: ${succeeded}, failed: ${failed}.`);
  }
);

// ── Scheduled 4: Delete expired events ────────────────────────────────────────
//
// Runs daily at midnight (Asia/Riyadh). Queries the events collection for all
// documents where endDate is strictly before now and batch-deletes them.
// Events with no endDate set are not affected — set endDate when creating an
// event if you want automatic cleanup.

export const deleteExpiredEvents = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Asia/Riyadh",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const now = new Date();

    let expiredSnap;
    try {
      expiredSnap = await db
        .collection("events")
        .where("endDate", "<", now)
        .get();
    } catch (err) {
      logger.error("[deleteExpiredEvents] Failed to query expired events:", err);
      return;
    }

    if (expiredSnap.empty) {
      logger.info("[deleteExpiredEvents] No expired events found.");
      return;
    }

    logger.info(
      `[deleteExpiredEvents] Found ${expiredSnap.size} expired event(s) — deleting.`
    );

    // Firestore WriteBatch is capped at 500 operations.
    const BATCH_LIMIT = 500;
    let deleted = 0;

    try {
      for (let i = 0; i < expiredSnap.docs.length; i += BATCH_LIMIT) {
        const batch = db.batch();
        expiredSnap.docs.slice(i, i + BATCH_LIMIT).forEach((doc) =>
          batch.delete(doc.ref)
        );
        await batch.commit();
        deleted += Math.min(BATCH_LIMIT, expiredSnap.docs.length - i);
      }
    } catch (err) {
      logger.error(
        `[deleteExpiredEvents] Batch delete failed after removing ${deleted} doc(s):`,
        err
      );
      return;
    }

    logger.info(`[deleteExpiredEvents] Done — deleted ${deleted} event(s).`);
  }
);

// ── Scheduled 3: Cleanup expired bookings + remind tourists ───────────────
//
// Runs every hour.
// 1. Auto-rejects pending bookings whose trip date has passed → status: expired.
//    Also removes the guide_slot doc(s) for those dates.
// 2. Sends a one-time pending reminder to tourists whose trip is tomorrow.

export const cleanupExpiredBookings = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Riyadh", memory: "256MiB" },
  async () => {
    const todayStr    = todayInRiyadh();
    // tomorrow in Riyadh = UTC+3, add 27h (24h + 3h offset) then slice
    const tomorrowStr = new Date(Date.now() + 27 * 60 * 60 * 1000)
      .toISOString().slice(0, 10);

    // ── 1. Expire bookings whose trip date has passed ───────────────────────
    const expiredSnap = await db
      .collection("bookings")
      .where("status", "==", "pending")
      .where("date", "<", todayStr)
      .get();

    if (!expiredSnap.empty) {
      // Collect all write ops: expire booking + delete slot for each date
      const ops: { ref: FirebaseFirestore.DocumentReference; op: "update" | "delete"; data?: object }[] = [];

      for (const doc of expiredSnap.docs) {
        const data = doc.data();
        ops.push({ ref: doc.ref, op: "update", data: { status: "expired", expiredAt: FieldValue.serverTimestamp() } });

        if ((data.tutorType as string | undefined) === "individual") {
          const dur = (data.tripDurationDays as number | undefined) ?? 1;
          const dateStr = data.date as string | undefined;
          if (dateStr) {
            for (let i = 0; i < dur; i++) {
              const d = new Date(dateStr + "T00:00:00Z");
              d.setUTCDate(d.getUTCDate() + i);
              const slotDate = d.toISOString().slice(0, 10);
              ops.push({
                ref: db.collection("guide_slots").doc(`${data.tutorId}_${slotDate}`),
                op: "delete",
              });
            }
          }
        }
      }

      // Write in chunks of 400 (Firestore batch limit is 500)
      const CHUNK = 400;
      for (let i = 0; i < ops.length; i += CHUNK) {
        const batch = db.batch();
        ops.slice(i, i + CHUNK).forEach(({ ref, op, data }) => {
          op === "delete" ? batch.delete(ref) : batch.update(ref, data!);
        });
        await batch.commit();
      }
      logger.info(`[cleanupExpired] Expired ${expiredSnap.size} booking(s).`);
    }

    // Remind tourists with a pending booking due tomorrow.
    const tomorrowPendingSnap = await db
      .collection("bookings")
      .where("status", "==", "pending")
      .where("date", "==", tomorrowStr)
      .get();

    if (!tomorrowPendingSnap.empty) {
      await Promise.all(tomorrowPendingSnap.docs.map(async (doc) => {
        const data = doc.data() as { touristId?: string; bookingId?: string };
        const touristId = data.touristId ?? "";
        const bookingId = data.bookingId ?? doc.id;
        if (!touristId || !bookingId) return;
        const notificationId = `${bookingId}_pending_reminder`;
        const notifRef = db
          .collection("users").doc(touristId)
          .collection("notifications").doc(notificationId);
        const existing = await notifRef.get();
        if (!existing.exists) {
          // Use notify() so reminders create both in-app and push notifications.
          await notify(touristId, "booking_pending_reminder", undefined, notificationId);
        }
      }));
      logger.info(`[cleanupExpired] Sent reminders for ${tomorrowPendingSnap.size} booking(s).`);
    }
  }
);

// ── One-time migration: create guide_slots for existing active bookings ────
//
// Call once after deploying. Creates slot docs for all pending/approved
// bookings by individual guides that don't have slots yet.

export const migrateGuideSlots = onCall(
  { enforceAppCheck: false, timeoutSeconds: 300, memory: "256MiB" },
  async () => {
    const snap = await db
      .collection("bookings")
      .where("status", "in", ["pending", "approved"])
      .get();

    const CHUNK = 400;
    const ops: { id: string; data: object }[] = [];

    for (const doc of snap.docs) {
      const data = doc.data();
      if ((data.tutorType as string | undefined) !== "individual") continue;
      const dateStr = data.date as string | undefined;
      if (!dateStr || !data.tutorId || !data.tripId) continue;
      const dur = (data.tripDurationDays as number | undefined) ?? 1;
      for (let i = 0; i < dur; i++) {
        const d = new Date(dateStr + "T00:00:00Z");
        d.setUTCDate(d.getUTCDate() + i);
        const slotDate = d.toISOString().slice(0, 10);
        ops.push({
          id: `${data.tutorId}_${slotDate}`,
          data: { tutorId: data.tutorId, date: slotDate, tripId: data.tripId },
        });
      }
    }

    for (let i = 0; i < ops.length; i += CHUNK) {
      const batch = db.batch();
      ops.slice(i, i + CHUNK).forEach(({ id, data }) => {
        batch.set(db.collection("guide_slots").doc(id), data, { merge: true });
      });
      await batch.commit();
    }

    logger.info(`[migrateGuideSlots] Created/updated ${ops.length} slot(s).`);
    return { migrated: ops.length };
  }
);
