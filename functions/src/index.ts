import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai"; // رجعنا للمكتبة المثبتة عندك عشان يختفي الأيرور ✅

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