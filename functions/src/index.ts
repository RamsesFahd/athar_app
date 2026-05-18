import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";

initializeApp();
const db = getFirestore();

const GEMINI_KEY = process.env.GEMINI_API_KEY || "";
const CLASSIFY_MODEL = process.env.GEMINI_MODEL || "gemini-1.5-flash"; 
const EMBED_MODEL = "gemini-embedding-001";
 // الموديل الصحيح اللي بيفك أزمة الـ 404

interface TaxonomyEntry {
  id: string;
  labelAr: string;
  labelEn: string;
  synonyms: string[];
  appliesTo: string[];
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

// Triggers
export const classifyNewAttraction = onDocumentCreated({ document: "attractions/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (event.data) await classifyDocument("attractions", event.params.docId, event.data.data());
});
export const classifyNewTrip = onDocumentCreated({ document: "trips/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (event.data) await classifyDocument("trips", event.params.docId, event.data.data());
});
export const classifyNewEvent = onDocumentCreated({ document: "events/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (event.data) await classifyDocument("events", event.params.docId, event.data.data());
});
export const classifyNewCulturalItem = onDocumentCreated({ document: "cultural_items/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  if (event.data) await classifyDocument("cultural_items", event.params.docId, event.data.data());
});

function textFieldsChanged(before: FirebaseFirestore.DocumentData, after: FirebaseFirestore.DocumentData, fields: string[]): boolean {
  return fields.some((f) => JSON.stringify(before[f]) !== JSON.stringify(after[f]));
}

export const reclassifyUpdatedAttraction = onDocumentUpdated({ document: "attractions/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data(); const after = event.data?.after.data();
  if (before && after && textFieldsChanged(before, after, ["name", "description", "category"])) await classifyDocument("attractions", event.params.docId, after);
});
export const reclassifyUpdatedTrip = onDocumentUpdated({ document: "trips/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data(); const after = event.data?.after.data();
  if (before && after && textFieldsChanged(before, after, ["title", "description"])) await classifyDocument("trips", event.params.docId, after);
});
export const reclassifyUpdatedEvent = onDocumentUpdated({ document: "events/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data(); const after = event.data?.after.data();
  if (before && after && textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn", "eventType"])) await classifyDocument("events", event.params.docId, after);
});
export const reclassifyUpdatedCulturalItem = onDocumentUpdated({ document: "cultural_items/{docId}", secrets: ["GEMINI_API_KEY"] }, async (event) => {
  const before = event.data?.before.data(); const after = event.data?.after.data();
  if (before && after && textFieldsChanged(before, after, ["titleAr", "titleEn", "descriptionAr", "descriptionEn", "categoryId"])) await classifyDocument("cultural_items", event.params.docId, after);
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
const RAWI_CHAT_MODEL = "gemini-2.0-flash";
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
  let dot = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

function extractDocMeta(
  collection: string,
  docId: string,
  data: FirebaseFirestore.DocumentData
): CachedEmbedding | null {
  const emb = data.embedding;
  if (!Array.isArray(emb) || emb.length === 0) return null;

  const type = collection as "attraction" | "trip" | "event" | "cultural_item";

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
      imageUrl = data.mainImageUrl || data.imageUrl || null;
      region = data.region || data.regionId || "";
      break;
    }
    case "trips": {
      const t = data.title || {};
      const d = data.description || {};
      titleAr = typeof t === "object" ? (t.ar || "") : String(t || "");
      titleEn = typeof t === "object" ? (t.en || "") : "";
      description = (typeof d === "object" ? (d.ar || d.en || "") : String(d || "")).slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
      region = data.region || data.regionId || "";
      break;
    }
    case "events": {
      titleAr = data.titleAr || "";
      titleEn = data.titleEn || "";
      description = (data.descriptionAr || data.descriptionEn || "").slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
      region = data.region || data.regionId || data.location || "";
      break;
    }
    case "cultural_items": {
      titleAr = data.titleAr || "";
      titleEn = data.titleEn || "";
      description = (data.descriptionAr || data.descriptionEn || "").slice(0, 200);
      imageUrl = data.imageUrl || data.mainImageUrl || null;
      region = data.region || data.regionId || "";
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
    const snap = await db.collection(col).select("embedding", "name", "title", "titleAr", "titleEn", "descriptionAr", "descriptionEn", "description", "imageUrl", "mainImageUrl", "region", "regionId", "location", "category", "eventType").get();
    for (const doc of snap.docs) {
      const meta = extractDocMeta(col, doc.id, doc.data());
      if (meta) cache.set(`${col}/${doc.id}`, meta);
    }
  }

  embeddingCache = cache;
  embeddingCachedAt = now;
  return cache;
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

    const { conversationId, userMessage, recentMessages, locale } = request.data as {
      conversationId: string;
      userMessage: string;
      recentMessages: Array<{ role: "user" | "assistant"; content: string }>;
      locale: "ar" | "en";
    };

    if (!userMessage?.trim()) throw new HttpsError("invalid-argument", "userMessage is required");

    const genAI = new GoogleGenerativeAI(GEMINI_KEY);

    // 1. Embed the user query
    const queryEmbedding = await generateEmbedding(userMessage);

    // 2. Load cached embeddings
    const cache = await loadEmbeddingCache();

    // 3. Cosine similarity → top-K
    const scored: Array<{ key: string; score: number; meta: CachedEmbedding }> = [];
    for (const [key, meta] of cache.entries()) {
      const score = cosineSimilarity(queryEmbedding, meta.embedding);
      if (score >= SIMILARITY_THRESHOLD) {
        scored.push({ key, score, meta });
      }
    }
    scored.sort((a, b) => b.score - a.score);
    const topDocs = scored.slice(0, TOP_K);

    // 4. Build retrieved context
    const contextLines = topDocs.map((d) => {
      const m = d.meta;
      const title = locale === "ar" ? (m.titleAr || m.titleEn) : (m.titleEn || m.titleAr);
      const desc = locale === "ar" ? m.description : m.description;
      return `• [${m.type}] ${title} — ${desc.slice(0, 200)}${m.region ? ` (${m.region})` : ""}`;
    }).join("\n");

    // 5. System prompt
    const langInstruction = locale === "ar"
      ? "You MUST respond entirely in Arabic (العربية). Do not mix languages."
      : "You MUST respond entirely in English. Do not mix languages.";

    const systemPrompt = `You are Rawi (راوي), a warm and knowledgeable cultural narrator for Saudi Arabian heritage and tourism. You are aligned with Vision 2030's goal of promoting authentic Saudi cultural experiences.

${langInstruction}

Your knowledge is grounded in the following real content from the Athar platform. ONLY recommend items listed here — do not invent places, events, or cultural items:

${contextLines || (locale === "ar" ? "لم يتم العثور على محتوى مطابق." : "No matching content found.")}

Rules:
- Respond warmly but not casually.
- If the user's question matches items above, mention them specifically.
- At the END of your response, append a JSON block with up to ${MAX_SUGGESTED_ITEMS} item IDs of the most relevant items from the context. Use exactly this format (no other text after it):
<<<RECOMMENDED>>>{"itemIds":["docId1","docId2"]}<<<END>>>
- If no items are relevant, append: <<<RECOMMENDED>>>{"itemIds":[]}<<<END>>>`;

    // 6. Build conversation turns
    const isAr = locale === "ar";
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
    const result = await chatModel.generateContent(userPrompt);
    const rawText = result.response.text()?.trim() ?? "";

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

    // 9. Look up metadata for suggested items
    const suggestedItems: Array<{
      id: string;
      type: string;
      titleAr: string;
      titleEn: string;
      imageUrl: string | null;
    }> = [];

    for (const id of itemIds) {
      // Search cache first
      for (const meta of cache.values()) {
        if (meta.docId === id) {
          suggestedItems.push({
            id,
            type: meta.type,
            titleAr: meta.titleAr,
            titleEn: meta.titleEn,
            imageUrl: meta.imageUrl,
          });
          break;
        }
      }
    }

    logger.info(`[askRawi] session=${conversationId} locale=${locale} topDocs=${topDocs.length} suggested=${suggestedItems.length}`);

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
  guide_verified: {
    type: "guide_verified",
    title: { ar: "تم توثيق حسابك", en: "Account Verified" },
    body:  { ar: "تهانينا! تم توثيق حسابك كمرشد سياحي معتمد.", en: "Congratulations! Your guide account has been verified." },
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

// ── Trigger 5: Tourist books a trip → notify the guide ────────────────────

export const onBookingCreated = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    if (!event.data) return;
    const data = event.data.data();
    const tutorId: string = data.tutorId ?? "";
    if (!tutorId) return;
    logger.info(`[notif] New booking ${event.params.bookingId} → guide ${tutorId}`);
    await notify(tutorId, "booking_new");
  }
);

// ── Trigger 6: Guide confirms or rejects a booking → notify tourist ────────

export const onBookingStatusChanged = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after  = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const touristId: string = after.touristId ?? "";
    if (!touristId) return;

    if (after.status === "accepted") {
      await notify(touristId, "booking_approved");
    } else if (after.status === "cancelled" || after.status === "rejected") {
      await notify(touristId, "booking_cancelled");
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

    // Only fire when verificationStatus transitions to "verified"
    if (
      before.verificationStatus === after.verificationStatus ||
      after.verificationStatus !== "verified" ||
      after.role !== "tutor"
    ) return;

    logger.info(`[notif] Guide verified: ${event.params.userId}`);
    await notify(event.params.userId, "guide_verified");
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