import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions';
import { GoogleGenerativeAI } from '@google/generative-ai';

initializeApp();

const db = getFirestore();
const geminiKey = process.env.GEMINI_API_KEY || '';
const geminiModel = process.env.GEMINI_MODEL || 'gemini-1.5-flash';

const allowedTagsByCategory: Record<string, string[]> = {
  Heritage: ['قصور', 'أحياء تاريخية', 'مدائن'],
  Nature: ['بحر', 'جبال', 'صحراء', 'غابة', 'أودية'],
  Arts: ['متاحف', 'معارض'],
  Modern: ['أبراج', 'معالم معمارية', 'وجهات ترفيهية'],
};

export const tagNewAttraction = onDocumentCreated('attractions/{attractionId}', async (event) => {
  const snap = event.data;
  if (!snap) {
    return;
  }

  const data = snap.data() as Record<string, unknown>;
  const category = String(data.category ?? '');
  const allowedTags = allowedTagsByCategory[category];

  if (!allowedTags || !geminiKey) {
    logger.warn('Skipping attraction tagging because category or Gemini key is missing', {
      attractionId: event.params.attractionId,
      category,
      hasGeminiKey: Boolean(geminiKey),
    });
    return;
  }

  const attractionName = JSON.stringify(data.name ?? {});
  const attractionDescription = JSON.stringify(data.description ?? {});
  const prompt = [
    'You are tagging a tourism attraction document.',
    'Return ONLY valid JSON in this exact shape: {"tags":["tag1","tag2"]}.',
    'Pick only tags that are relevant to the attraction and only from the allowed list.',
    `Allowed tags for category ${category}: ${allowedTags.join(', ')}`,
    'Do not output any extra text, markdown, or explanations.',
    `Attraction name: ${attractionName}`,
    `Attraction description: ${attractionDescription}`,
  ].join('\n');

  try {
    const genAI = new GoogleGenerativeAI(geminiKey);
    const model = genAI.getGenerativeModel({ model: geminiModel });
    const result = await model.generateContent(prompt);
    const rawText = result.response.text().trim();
    const parsed = parseTags(rawText, allowedTags);

    if (parsed.length === 0) {
      logger.warn('Gemini returned no valid attraction tags', {
        attractionId: event.params.attractionId,
        rawText,
      });
      return;
    }

    await db.collection('attractions').doc(event.params.attractionId).update({
      tags: parsed,
      tagsUpdatedAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    logger.error('Failed to auto-tag attraction document', {
      attractionId: event.params.attractionId,
      error,
    });
  }
});

function parseTags(rawText: string, allowedTags: string[]): string[] {
  const normalized = rawText.replace(/```json|```/g, '').trim();

  const candidates = [normalized];
  try {
    const parsed = JSON.parse(normalized) as { tags?: unknown };
    if (Array.isArray(parsed.tags)) {
      return sanitizeTags(parsed.tags, allowedTags);
    }
  } catch (_) {
    // fall through and try to extract an array from the text
  }

  const match = normalized.match(/\[([\s\S]*)\]/);
  if (match) {
    candidates.push(`[${match[1]}]`);
  }

  for (const candidate of candidates) {
    try {
      const parsed = JSON.parse(candidate) as unknown;
      if (Array.isArray(parsed)) {
        return sanitizeTags(parsed, allowedTags);
      }
    } catch (_) {
      continue;
    }
  }

  return [];
}

function sanitizeTags(value: unknown[], allowedTags: string[]): string[] {
  const allowed = new Set(allowedTags);
  return value
    .map((tag) => String(tag).trim())
    .filter((tag) => tag.length > 0)
    .filter((tag, index, all) => all.indexOf(tag) === index)
    .filter((tag) => allowed.has(tag));
}