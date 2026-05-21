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

const GEMINI_KEY = process.env.GEMINI_API_KEY || "";
const CLASSIFY_MODEL = process.env.GEMINI_MODEL || "gemini-2.5-flash";
const EMBED_MODEL = "gemini-embedding-001";
 // الموديل الصحيح اللي بيفك أزمة الـ 404

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
      const title = data.title;
      const desc = data.description;
      const titleStr = typeof title === "object" ? `${title.ar || ""} | ${title.en || ""}` : String(title || "");
      const descStr = typeof desc === "object" ? `${desc.ar || ""} | ${desc.en || ""}` : String(desc || "");
      return {
        title: titleStr.trim(),
        description: descStr.trim(),
        extra: "",
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
  if (textFieldsChanged(before, after, ["title", "description"])) {
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
// EMBED MISSING DOCUMENTS (متوافقة مع مكتبتك الحالية)
// =====================================================
export const embedMissingDocuments = onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 540,
    memory: "512MiB",
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    if (!GEMINI_KEY) {
      throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not set");
    }

    const collections = ["attractions", "trips", "events", "cultural_items"];
    const stats: Record<string, { processed: number; failed: number; skipped: number }> = {};
    
    // استخدام طريقة الاستدعاء القديمة لإنهاء الأيرور
    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    const embeddingModel = genAI.getGenerativeModel({ model: EMBED_MODEL });

    for (const collectionName of collections) {
      stats[collectionName] = { processed: 0, failed: 0, skipped: 0 };
      const snapshot = await db.collection(collectionName).get();
      
      logger.info(`[embedMissing] Scanning ${collectionName}: ${snapshot.size} docs`);

      for (const doc of snapshot.docs) {
        const data = doc.data();
        
        if (data.embedding && Array.isArray(data.embedding) && data.embedding.length > 0) {
          stats[collectionName].skipped++;
          continue;
        }

        try {
          const content = extractContentText(collectionName, data);
          const textParts: string[] = [];
          
          if (content.title) textParts.push(content.title);
          if (content.description) textParts.push(content.description);
          
          if (textParts.length === 0) {
            const backupText = data.nameAr || data.titleAr || data.name || data.title || data.text || "";
            if (backupText) textParts.push(String(backupText));
          }

          const text = textParts.join(" | ").trim();

          if (!text || text.length < 2) {
            logger.warn(`[embedMissing] Skipping ${collectionName}/${doc.id} - Real Empty Text`);
            stats[collectionName].failed++;
            continue;
          }

          // استخدام دالة الاستدعاء المعتمدة في مكتبتك
          const result = await embeddingModel.embedContent(text);

          if (result?.embedding?.values) {
            await doc.ref.update({
              embedding: result.embedding.values,
              embeddedAt: FieldValue.serverTimestamp(),
            });
            stats[collectionName].processed++;
            logger.info(`[embedMissing] ✓ Fixed ${collectionName}/${doc.id}`);
            
            // ديليه 8 ثوانٍ لحماية الحساب المجاني
            await new Promise((resolve) => setTimeout(resolve, 8000));
          } else {
            stats[collectionName].failed++;
          }
        } catch (err: any) {
          logger.error(`[embedMissing] ✗ ${collectionName}/${doc.id}:`, err.message || err);
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

const SIMILARITY_THRESHOLD = 0.6;
const TOP_K = 5;
const MAX_SUGGESTED_ITEMS = 3;
const RAWI_CHAT_MODEL = "gemini-3.1-flash-lite-preview";
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
      const t = data.title || {};
      const d = data.description || {};
      titleAr = typeof t === "object" ? (t.ar || "") : String(t || "");
      titleEn = typeof t === "object" ? (t.en || "") : "";
      description = (typeof d === "object" ? (d.ar || d.en || "") : String(d || "")).slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
      region = normalizeRegion(data.regionId || data.region);
      break;
    }
    case "events": {
      titleAr = data.titleAr || "";
      titleEn = data.titleEn || "";
      description = (data.descriptionAr || data.descriptionEn || "").slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
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
    const snap = await db.collection(col).select("embedding", "name", "title", "titleAr", "titleEn", "descriptionAr", "descriptionEn", "description", "imageUrl", "mainImage", "mainImageUrl", "region", "regionId", "location", "category", "eventType").get();
    for (const doc of snap.docs) {
      const meta = extractDocMeta(col, doc.id, doc.data());
      if (meta) cache.set(`${col}/${doc.id}`, meta);
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
  };
  return aliases[s] ?? s;
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

    const { conversationId, userMessage, recentMessages, locale, regionId } = request.data as {
      conversationId: string;
      userMessage: string;
      recentMessages: Array<{ role: "user" | "assistant"; content: string }>;
      locale: "ar" | "en";
      regionId?: string;
    };

    if (!userMessage?.trim()) throw new HttpsError("invalid-argument", "userMessage is required");

    const genAI = new GoogleGenerativeAI(GEMINI_KEY);
    const isAr = locale === "ar";

    // ✦ FIX: normalize the incoming regionId the same way stored values are normalized
    const wantedRegion = normalizeRegion(regionId);

    // 1. Embed the user query
    const queryEmbedding = await generateEmbedding(userMessage);

    // 2. Load cached embeddings and strictly filter by region when provided
    const cache = await loadEmbeddingCache();

    // ✦ FIX: compare two normalized values so format differences don't break filtering
    const filteredCache = wantedRegion
      ? new Map([...cache.entries()].filter(([, meta]) => meta.region === wantedRegion))
      : cache;

    logger.info(`[askRawi] wantedRegion="${wantedRegion}" totalCache=${cache.size} filtered=${filteredCache.size}`);

    // 3. Cosine similarity → top-K (region-filtered)
    const scored: Array<{ key: string; score: number; meta: CachedEmbedding }> = [];
    for (const [key, meta] of filteredCache.entries()) {
      const score = cosineSimilarity(queryEmbedding, meta.embedding);
      if (score >= SIMILARITY_THRESHOLD) {
        scored.push({ key, score, meta });
      }
    }
    scored.sort((a, b) => b.score - a.score);
    const topDocs = scored.slice(0, TOP_K);

    // 4. Build retrieved context (top-K semantic matches)
    const contextLines = topDocs.map((d) => {
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
        .map((e) => {
          // Surface only the locale-matching name so the model wraps bold text
          // in the correct script and never mixes languages in entity names.
          const name = isAr ? (e.titleAr || e.titleEn) : (e.titleEn || e.titleAr);
          return `${name} (id:${e.id})`;
        })
        .join(", ");
      archiveLines.push(`[${type}]: ${names}`);
    }
    const archiveSummary = archiveLines.join("\n");

    // Locale-gated allowedNames: only the locale-appropriate title is permitted
    // inside ** markers. This prevents the model from bolding Arabic names in an
    // English response (and vice-versa). Falls back to the other language when a
    // locale-appropriate title is absent so rare untranslated items still link.
    const allowedNames = new Set<string>();
    for (const meta of filteredCache.values()) {
      const preferred = isAr
        ? (meta.titleAr?.trim() || meta.titleEn?.trim())
        : (meta.titleEn?.trim() || meta.titleAr?.trim());
      if (preferred) allowedNames.add(preferred);
    }
    const validIdSet = new Set([...filteredCache.values()].map((m) => m.docId));

    // 5. System prompt
    const langInstruction = isAr
      ? "You MUST respond entirely in Arabic (العربية). Do not mix languages."
      : "You MUST respond entirely in English. Do not mix languages.";

    const hasArchive = filteredCache.size > 0;

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
- NEVER invent, assume, or mention any place, food, craft, dress, or item that is NOT in the archive list.
- NEVER add qualifiers like "Beta", "Classic", "Old", or version numbers to item names — use the exact name from the list.
- When you name a SPECIFIC item that EXISTS in the archive list, wrap ONLY that exact name in double asterisks: **Item Name**.
- NEVER wrap a word in asterisks unless the exact name (or a very close form) appears in the archive list. Descriptive, generic, or contextual words must stay in plain text.
- Do NOT use hashtags (#).
- NEVER mention "database", "archive", "Athar", "the platform", "Vision 2030", or that you are an AI.
- BANNED phrases: (للأسف، أعتذر، قاعدة بياناتي، لا تتوفر لدي معلومات).
- REGION LOCK: You may ONLY reference items from the archive list below. If the user asks about heritage from a DIFFERENT region, acknowledge their curiosity politely then redirect: "My expertise is this region — let me tell you about..."

--- Available Archive Items (this region only) ---
${hasArchive ? archiveSummary : (isAr
    ? "لا توجد عناصر مسجّلة لهذه المنطقة حالياً."
    : "No items registered for this region yet.")}

--- Closest Matches to the User's Question ---
${contextLines || (isAr ? "لا تطابق دقيق — استخدم قائمة الأرشيف أعلاه." : "No close match — use the archive list above.")}

${!hasArchive ? (isAr
    ? "بما أنه لا توجد عناصر لهذه المنطقة، تحدّث بدفء عن طابع المنطقة العام دون ذكر أي اسم محدد بين النجمتين، ودون اختلاق عناصر."
    : "Since there are no items for this region, speak warmly about the region's general character WITHOUT naming specific items in asterisks and WITHOUT inventing anything.") : ""}

--- OUTPUT TAIL (REQUIRED) ---
At the END of every response append EXACTLY one of the following JSON blocks:

Append items ONLY when the user asked about a specific place, tradition, food, event, or craft — OR when you mentioned a specific archive item in your reply:
<<<RECOMMENDED>>>{"itemIds":["docId1","docId2"]}<<<END>>>

For greetings, clarifying questions, general chitchat, out-of-scope redirections, or any reply where you did NOT reference a specific archive item, append:
<<<RECOMMENDED>>>{"itemIds":[]}<<<END>>>

Maximum ${MAX_SUGGESTED_ITEMS} item IDs. Use only real id values from the archive list above.`;

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

    // 8. Parse recommended IDs from JSON block
    let itemIds: string[] = [];
    const blockMatch = rawText.match(/<<<RECOMMENDED>>>([\s\S]*?)<<<END>>>/);
    let visibleText = rawText;

    if (blockMatch) {
      try {
        const parsed = JSON.parse(blockMatch[1].trim());
        if (Array.isArray(parsed.itemIds)) {
          itemIds = parsed.itemIds.slice(0, MAX_SUGGESTED_ITEMS).map(String);
        }
      } catch (_) {}
      visibleText = rawText.replace(/<<<RECOMMENDED>>>[\s\S]*?<<<END>>>/, "").trim();
    }

    // ✦ FIX: strip ** from any name not in the archive (prevents invented items being highlighted)
    visibleText = visibleText.replace(/\*\*(.+?)\*\*/g, (full, inner) => {
      const name = String(inner).trim();
      return allowedNames.has(name) ? full : name;
    });

    // 9. Look up metadata for suggested items
    const suggestedItems: Array<{
      id: string;
      type: string;
      titleAr: string;
      titleEn: string;
      imageUrl: string | null;
    }> = [];

    for (const id of itemIds) {
      // ✦ FIX: reject any id not belonging to this region
      if (!validIdSet.has(id)) {
        logger.warn(`[askRawi] dropped invented/out-of-region itemId="${id}"`);
        continue;
      }
      const meta = filteredCache.get([...filteredCache.entries()].find(([, m]) => m.docId === id)?.[0] ?? "");
      if (meta) {
        suggestedItems.push({
          id,
          type: meta.type,
          titleAr: meta.titleAr,
          titleEn: meta.titleEn,
          imageUrl: meta.imageUrl,
        });
      }
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
    body:  { ar: "لم يرد المرشد خلال 24 ساعة، تم تأكيد حجزك تلقائيًا.", en: "The guide did not respond within 24 hours, your booking has been auto-confirmed." },
  },
  booking_completed: {
    type: "booking_completed",
    title: { ar: "اكتملت رحلتك", en: "Trip Completed" },
    body:  { ar: "نأمل أن تكون رحلتك رائعة! شاركنا تقييمك للمرشد.", en: "We hope you had a great trip! Share your rating for the guide." },
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
 * users/{userId}/notifications/{auto-id}.
 */
async function createInAppNotification(
  userId: string,
  notif: NotificationPayload,
  bodyOverride?: BilingualText
): Promise<void> {
  await db
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .add({
      type: notif.type,
      title: notif.title,
      body: bodyOverride ?? notif.body,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
    });
}

/**
 * Reads the FCM tokens for a user and sends a multicast push message.
 * Silently ignores users with no tokens (guests, web-only users, etc.).
 * Removes any tokens reported as invalid by FCM to keep the list clean.
 */
async function sendPushToUser(
  userId: string,
  notif: NotificationPayload,
  bodyOverride?: BilingualText
): Promise<void> {
  const userSnap = await db.collection("users").doc(userId).get();
  if (!userSnap.exists) return;

  const tokens: string[] = userSnap.data()?.fcmTokens ?? [];
  if (tokens.length === 0) return;

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
  bodyOverride?: BilingualText
): Promise<void> {
  const notif = NOTIFICATION_COPY[type];
  if (!notif) {
    logger.warn(`[notify] Unknown notification type: ${type}`);
    return;
  }
  await Promise.all([
    createInAppNotification(userId, notif, bodyOverride),
    sendPushToUser(userId, notif, bodyOverride),
  ]);
}

/**
 * Notifies every admin user. Used when a tourist/guide submits content.
 */
async function notifyAllAdmins(type: string): Promise<void> {
  const notif = NOTIFICATION_COPY[type];
  if (!notif) return;

  const adminSnap = await db
    .collection("users")
    .where("role", "==", "admin")
    .get();

  await Promise.all(
    adminSnap.docs.map((doc) => notify(doc.id, type))
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
    await notifyAllAdmins("contribution_submitted");
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
      await notify(touristId, "contribution_approved");
    } else if (after.status === "rejected") {
      const reason: string = after.rejectionReason ?? "";
      const bodyOverride: BilingualText | undefined = reason
        ? { ar: reason, en: reason }
        : undefined;
      await notify(touristId, "contribution_rejected", bodyOverride);
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
    await notifyAllAdmins("trip_submitted");
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
      await notify(tutorId, "trip_approved");
    } else if (after.status === "rejected") {
      await notify(tutorId, "trip_rejected");
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

    // adultsCount + ceil(childrenCount / 2) = adult-equivalent slot consumption
    const adultsCount: number = data.adultsCount ?? 1;
    const childrenCount: number = data.childrenCount ?? 0;
    const slotsNeeded = adultsCount + Math.ceil(childrenCount / 2);

    let capacityExceeded = false;

    try {
      await db.runTransaction(async (tx) => {
        const tripSnap = await tx.get(tripRef);
        if (!tripSnap.exists) return;

        const tripData = tripSnap.data()!;
        const availableSeats: number | null = tripData.availableSeats ?? null;

        // Only enforce capacity when the trip has a seat limit configured.
        if (availableSeats !== null && availableSeats < slotsNeeded) {
          capacityExceeded = true;
          tx.update(bookingRef, {
            status: "rejected",
            rejectionReason: "capacity_exceeded",
          });
        } else if (availableSeats !== null) {
          tx.update(tripRef, {
            availableSeats: FieldValue.increment(-slotsNeeded),
          });
        }
      });
    } catch (err) {
      logger.error(`[capacity] Transaction failed for booking ${event.params.bookingId}`, err);
    }

    if (capacityExceeded) {
      logger.info(`[capacity] Booking ${event.params.bookingId} rejected — trip fully booked`);
      if (touristId) await notify(touristId, "booking_rejected");
      return;
    }

    logger.info(`[notif] New booking ${event.params.bookingId} → guide ${tutorId}`);
    await notify(tutorId, "booking_new");
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
      try {
        await db.collection("trips").doc(tripId).update({
          availableSeats: FieldValue.increment(slotsToRestore),
        });
        logger.info(`[seats] Restored ${slotsToRestore} seat(s) to trip ${tripId}`);
      } catch (err) {
        logger.error(`[seats] Failed to restore seats for trip ${tripId}`, err);
      }
    }

    // ── Tourist notification ───────────────────────────────────────────────
    if (!touristId) return;

    if (after.status === "approved") {
      await notify(touristId, "booking_approved");
    } else if (after.status === "cancelled") {
      await notify(touristId, "booking_cancelled");
    } else if (after.status === "rejected" && after.rejectionReason !== "capacity_exceeded") {
      await notify(touristId, "booking_cancelled");
    } else if (after.status === "completed") {
      await notify(touristId, "booking_completed");
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
      await notify(event.params.userId, "guide_verified");
    } else if (after.verificationStatus === "rejected") {
      logger.info(`[notif] Guide rejected: ${event.params.userId}`);
      const reason = after.rejectionReason as string | undefined;
      const bodyOverride = reason
        ? { ar: `تم رفض طلب توثيقك. السبب: ${reason}`, en: `Your verification was rejected. Reason: ${reason}` }
        : undefined;
      await notify(event.params.userId, "guide_rejected", bodyOverride);
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
    await notify(event.params.userId, "points_awarded");
  }
);

// ── Scheduled 1: Auto-approve bookings pending for > 24 hours ─────────────
//
// Runs every hour. Any booking still in 'pending' with createdAt older than
// 24 hours is auto-approved so tourists are never left waiting indefinitely.

export const autoApproveBookings = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Riyadh" },
  async () => {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const snap = await db
      .collection("bookings")
      .where("status", "==", "pending")
      .where("createdAt", "<=", cutoff)
      .get();

    if (snap.empty) {
      logger.info("[autoApprove] No pending bookings to auto-approve.");
      return;
    }

    const batch = db.batch();
    const notifications: Array<() => Promise<void>> = [];

    for (const doc of snap.docs) {
      batch.update(doc.ref, { status: "approved", autoApproved: true });
      const touristId: string = doc.data().touristId ?? "";
      if (touristId) {
        notifications.push(() => notify(touristId, "booking_auto_approved"));
      }
    }

    await batch.commit();
    await Promise.all(notifications.map((fn) => fn()));
    logger.info(`[autoApprove] Auto-approved ${snap.size} booking(s).`);
  }
);

// ── Scheduled 2: Mark approved bookings as completed when date has passed ──
//
// Runs daily at 01:00 Riyadh time. Finds all approved bookings whose date
// string (YYYY-MM-DD) is strictly before today and transitions them to
// 'completed'. The tourist receives a completion notification with a prompt
// to rate their guide.

export const markCompletedBookings = onSchedule(
  { schedule: "0 1 * * *", timeZone: "Asia/Riyadh" },
  async () => {
    // Today's date in YYYY-MM-DD, used for lexicographic comparison with the
    // stored date string which uses the same format (from Dart's DateTime.toString()).
    const today = new Date().toISOString().split("T")[0];

    const snap = await db
      .collection("bookings")
      .where("status", "==", "approved")
      .get();

    const toComplete = snap.docs.filter((doc) => {
      const date: string = doc.data().date ?? "";
      return date < today; // YYYY-MM-DD lexicographic comparison is correct
    });

    if (toComplete.length === 0) {
      logger.info("[markCompleted] No bookings to complete.");
      return;
    }

    const batch = db.batch();
    const notifications: Array<() => Promise<void>> = [];

    for (const doc of toComplete) {
      batch.update(doc.ref, { status: "completed" });
      const touristId: string = doc.data().touristId ?? "";
      if (touristId) {
        notifications.push(() => notify(touristId, "booking_completed"));
      }
    }

    await batch.commit();
    await Promise.all(notifications.map((fn) => fn()));
    logger.info(`[markCompleted] Marked ${toComplete.length} booking(s) as completed.`);
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