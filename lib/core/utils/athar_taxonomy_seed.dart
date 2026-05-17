// ============================================================================
// Athar — Taxonomy Seed File
// ----------------------------------------------------------------------------
// This file seeds the /taxonomy Firestore collection with the official set of
// 15 user-facing interests used across:
//   - Onboarding interest selection screen
//   - Profile → My Interests section
//   - "You Might Like" home recommendations
//   - Personalized banner targeting
//   - Rawi (AI chatbot) semantic matching
//
// Each interest carries:
//   - A stable English ID (never localize this — used in code & Firestore queries)
//   - Bilingual labels (Arabic primary, English secondary)
//   - An image (Firebase Storage path, e.g., 'taxonomy/heritage_sites.webp')
//   - An icon emoji for compact UI display
//   - The archive category it primarily maps to (one of the 6 + 'general')
//   - Synonyms used by the Cloud Function for tag→interest mapping
//   - Related interests for "users who liked X also liked Y" expansion
//   - appliesTo: which content collections this interest filters
//   - displayOrder: rendering order in the onboarding grid
//
// Total: 15 interests across 5 groups (3+3+4+3+2)
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class TaxonomySeed {
  static const String collectionName = 'taxonomy';

  /// Run this once after deployment to seed the taxonomy collection.
  /// Idempotent: uses set() with merge:true so re-running won't duplicate.
  static Future<void> seedAll() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (final interest in _interests) {
      final docRef = firestore.collection(collectionName).doc(interest.id);
      batch.set(docRef, interest.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
    print('✓ Seeded ${_interests.length} interests into /$collectionName');
  }

  // ==========================================================================
  // THE 15 OFFICIAL INTERESTS
  // ==========================================================================
  static final List<_InterestSeed> _interests = [

    // ────────────────────────────────────────────────────────────────────────
    // GROUP 1: التراث والعمارة — Heritage & Architecture (3)
    // ────────────────────────────────────────────────────────────────────────

    _InterestSeed(
      id: 'heritage_sites',
      labelAr: 'مواقع تراثية',
      labelEn: 'Heritage Sites',
      imageUrl: 'taxonomy/heritage_sites.webp',
      icon: '🏛️',
      category: 'architecture',
      synonyms: [
        'تراث', 'تراثي', 'أثري', 'قديم', 'موروث', 'تاريخي',
        'الدرعية', 'العلا', 'مدائن صالح', 'حصن', 'قلعة',
        'heritage', 'historic', 'historical', 'ancient', 'ruins',
        'diriyah', 'alula', 'hegra', 'old town'
      ],
      relatedInterests: ['architecture_palaces', 'museums_galleries', 'history_stories'],
      appliesTo: ['attractions', 'cultural_items', 'trips'],
      displayOrder: 1,
    ),

    _InterestSeed(
      id: 'architecture_palaces',
      labelAr: 'عمارة وقصور',
      labelEn: 'Architecture & Palaces',
      imageUrl: 'taxonomy/architecture_palaces.webp',
      icon: '🕌',
      category: 'architecture',
      synonyms: [
        'قصر', 'قصور', 'مسجد', 'مساجد', 'بيت', 'منزل تراثي',
        'طين', 'نجدي', 'حجازي', 'عسيري', 'برج', 'أبراج',
        'palace', 'mosque', 'architecture', 'tower', 'building',
        'najdi', 'hijazi', 'aseeri', 'mud brick'
      ],
      relatedInterests: ['heritage_sites', 'photography_spots'],
      appliesTo: ['attractions', 'cultural_items'],
      displayOrder: 2,
    ),

    _InterestSeed(
      id: 'museums_galleries',
      labelAr: 'متاحف ومعارض',
      labelEn: 'Museums & Galleries',
      imageUrl: 'taxonomy/museums_galleries.webp',
      icon: '🖼️',
      category: 'general',
      synonyms: [
        'متحف', 'متاحف', 'معرض', 'معارض', 'قاعة', 'جاليري',
        'فن', 'فنون', 'عرض فني',
        'museum', 'gallery', 'exhibition', 'art space', 'cultural center'
      ],
      relatedInterests: ['heritage_sites', 'history_stories', 'crafts_handmade'],
      appliesTo: ['attractions', 'events'],
      displayOrder: 3,
    ),

    // ────────────────────────────────────────────────────────────────────────
    // GROUP 2: الطبيعة والمغامرة — Nature & Adventure (3)
    // ────────────────────────────────────────────────────────────────────────

    _InterestSeed(
      id: 'desert_adventures',
      labelAr: 'صحراء ومغامرات',
      labelEn: 'Desert & Adventures',
      imageUrl: 'taxonomy/desert_adventures.webp',
      icon: '🏜️',
      category: 'general',
      synonyms: [
        'صحراء', 'رمال', 'كثبان', 'تطعيس', 'برّ', 'دباب',
        'مخيم', 'تخييم', 'ربع الخالي', 'النفود',
        'desert', 'dunes', 'sand', 'off-road', 'drifting', 'camping',
        'rub al khali', 'empty quarter', 'safari'
      ],
      relatedInterests: ['mountains_valleys', 'photography_spots', 'guided_trips'],
      appliesTo: ['attractions', 'trips'],
      displayOrder: 4,
    ),

    _InterestSeed(
      id: 'mountains_valleys',
      labelAr: 'جبال وأودية',
      labelEn: 'Mountains & Valleys',
      imageUrl: 'taxonomy/mountains_valleys.webp',
      icon: '⛰️',
      category: 'general',
      synonyms: [
        'جبل', 'جبال', 'وادي', 'أودية', 'هايكنق', 'طلعة',
        'السودة', 'فيفاء', 'طويق', 'عسير', 'الطائف',
        'mountain', 'valley', 'hiking', 'peak', 'cliff',
        'asir', 'taif', 'fifa', 'tuwaiq'
      ],
      relatedInterests: ['desert_adventures', 'photography_spots', 'guided_trips'],
      appliesTo: ['attractions', 'trips'],
      displayOrder: 5,
    ),

    _InterestSeed(
      id: 'sea_coasts',
      labelAr: 'بحر وسواحل',
      labelEn: 'Sea & Coasts',
      imageUrl: 'taxonomy/sea_coasts.webp',
      icon: '🌊',
      category: 'general',
      synonyms: [
        'بحر', 'بحار', 'ساحل', 'سواحل', 'كورنيش', 'شاطئ', 'شواطئ',
        'غوص', 'قوارب', 'البحر الأحمر', 'الخليج العربي', 'جدة', 'ينبع',
        'sea', 'coast', 'beach', 'corniche', 'diving', 'red sea',
        'gulf', 'jeddah', 'yanbu'
      ],
      relatedInterests: ['photography_spots', 'guided_trips', 'family_experiences'],
      appliesTo: ['attractions', 'trips'],
      displayOrder: 6,
    ),

    // ────────────────────────────────────────────────────────────────────────
    // GROUP 3: الثقافة الحية — Living Culture (4) — covers all 6 archive cats
    // ────────────────────────────────────────────────────────────────────────

    _InterestSeed(
      id: 'music_folk_arts',
      labelAr: 'موسيقى وفنون شعبية',
      labelEn: 'Music & Folk Arts',
      imageUrl: 'taxonomy/music_folk_arts.webp',
      icon: '🎵',
      category: 'music', // also covers 'dance' via synonyms
      synonyms: [
        'موسيقى', 'أغاني', 'طرب', 'عود', 'دف', 'طبل',
        'عرضة', 'سامري', 'مجرور', 'خبيتي', 'رقصة', 'رقص شعبي',
        'فنون شعبية', 'فلكلور',
        'music', 'songs', 'oud', 'drums', 'folk', 'dance', 'performance',
        'ardha', 'samri', 'majrur'
      ],
      relatedInterests: ['festivals_events', 'cultural_history', 'crafts_handmade'],
      appliesTo: ['cultural_items', 'events', 'trips'],
      displayOrder: 7,
    ),

    _InterestSeed(
      id: 'traditional_food',
      labelAr: 'أكل وموروث الطعام',
      labelEn: 'Food & Culinary Heritage',
      imageUrl: 'taxonomy/traditional_food.webp',
      icon: '🍽️',
      category: 'food',
      synonyms: [
        'أكل', 'طعام', 'مأكولات', 'مطبخ', 'وصفة', 'وصفات',
        'كبسة', 'مطازيز', 'جريش', 'مرقوق', 'مفطح', 'قهوة', 'قهوة سعودية',
        'تمر', 'حلويات', 'كليجا',
        'food', 'cuisine', 'dish', 'recipe', 'coffee', 'dates',
        'kabsa', 'gursan', 'jareesh', 'mufattah', 'kleeja'
      ],
      relatedInterests: ['festivals_events', 'guided_trips', 'family_experiences'],
      appliesTo: ['cultural_items', 'events', 'trips'],
      displayOrder: 8,
    ),

    _InterestSeed(
      id: 'crafts_handmade',
      labelAr: 'حِرف يدوية',
      labelEn: 'Handicrafts',
      imageUrl: 'taxonomy/crafts_handmade.webp',
      icon: '🧵',
      category: 'craft',
      synonyms: [
        'حرفة', 'حرف', 'حرفية', 'صناعة يدوية', 'يدوي',
        'سدو', 'نسيج', 'سعف', 'خوص', 'فخار', 'خزف', 'نحاس',
        'حلي', 'فضة', 'بخور', 'عطور',
        'craft', 'handicraft', 'handmade', 'weaving', 'pottery',
        'sadu', 'palm leaf', 'silver', 'incense'
      ],
      relatedInterests: ['traditional_attire', 'museums_galleries', 'music_folk_arts'],
      appliesTo: ['cultural_items', 'events', 'trips'],
      displayOrder: 9,
    ),

    _InterestSeed(
      id: 'traditional_attire',
      labelAr: 'أزياء وموروث ملبسي',
      labelEn: 'Traditional Attire',
      imageUrl: 'taxonomy/traditional_attire.webp',
      icon: '👗',
      category: 'clothing',
      synonyms: [
        'لبس', 'ملابس', 'زي', 'أزياء', 'ثوب', 'عباية', 'شيلة',
        'مشلح', 'بشت', 'غترة', 'شماغ', 'عقال',
        'تطريز', 'دراعة', 'زبون',
        'attire', 'clothing', 'dress', 'thobe', 'bisht', 'abaya',
        'shemagh', 'embroidery'
      ],
      relatedInterests: ['crafts_handmade', 'cultural_history', 'museums_galleries'],
      appliesTo: ['cultural_items', 'events'],
      displayOrder: 10,
    ),

    // ────────────────────────────────────────────────────────────────────────
    // GROUP 4: التجارب والفعاليات — Experiences & Events (3)
    // ────────────────────────────────────────────────────────────────────────

    _InterestSeed(
      id: 'festivals_events',
      labelAr: 'فعاليات ومهرجانات',
      labelEn: 'Festivals & Events',
      imageUrl: 'taxonomy/festivals_events.webp',
      icon: '🎉',
      category: 'general',
      synonyms: [
        'فعالية', 'فعاليات', 'مهرجان', 'مهرجانات', 'موسم', 'احتفال',
        'يوم وطني', 'يوم التأسيس', 'موسم الرياض', 'موسم جدة',
        'كرنفال', 'حفل',
        'festival', 'event', 'season', 'celebration', 'carnival',
        'national day', 'founding day', 'riyadh season', 'jeddah season'
      ],
      relatedInterests: ['music_folk_arts', 'traditional_food', 'family_experiences'],
      appliesTo: ['events', 'trips'],
      displayOrder: 11,
    ),

    _InterestSeed(
      id: 'guided_trips',
      labelAr: 'رحلات مع مرشدين',
      labelEn: 'Guided Trips',
      imageUrl: 'taxonomy/guided_trips.webp',
      icon: '🧭',
      category: 'general',
      synonyms: [
        'رحلة', 'رحلات', 'مرشد', 'مرشدين', 'دليل سياحي', 'جولة',
        'استكشاف', 'مغامرة منظمة',
        'trip', 'tour', 'guide', 'guided', 'expedition', 'excursion'
      ],
      relatedInterests: ['desert_adventures', 'mountains_valleys', 'family_experiences'],
      appliesTo: ['trips'],
      displayOrder: 12,
    ),

    _InterestSeed(
      id: 'family_experiences',
      labelAr: 'تجارب عائلية',
      labelEn: 'Family Experiences',
      imageUrl: 'taxonomy/family_experiences.webp',
      icon: '👨‍👩‍👧‍👦',
      category: 'general',
      synonyms: [
        'عائلة', 'عائلي', 'أطفال', 'مناسبة عائلية', 'ترفيه عائلي',
        'حديقة', 'متنزه', 'ملاهي',
        'family', 'kids', 'children', 'family-friendly', 'park', 'amusement'
      ],
      relatedInterests: ['festivals_events', 'sea_coasts', 'guided_trips'],
      appliesTo: ['attractions', 'trips', 'events'],
      displayOrder: 13,
    ),

    // ────────────────────────────────────────────────────────────────────────
    // GROUP 5: اهتمامات عرضية — Cross-cutting Interests (2)
    // ────────────────────────────────────────────────────────────────────────

    _InterestSeed(
      id: 'photography_spots',
      labelAr: 'تصوير وأماكن مصورة',
      labelEn: 'Photography Spots',
      imageUrl: 'taxonomy/photography_spots.webp',
      icon: '📷',
      category: 'general',
      synonyms: [
        'تصوير', 'صور', 'فوتوغرافي', 'منظر', 'مناظر', 'إطلالة',
        'سينمائي', 'انستقرام',
        'photography', 'photo', 'scenic', 'view', 'instagrammable', 'cinematic'
      ],
      relatedInterests: ['mountains_valleys', 'sea_coasts', 'architecture_palaces'],
      appliesTo: ['attractions', 'trips'],
      displayOrder: 14,
    ),

    _InterestSeed(
      id: 'history_stories',
      labelAr: 'تاريخ وقصص',
      labelEn: 'History & Stories',
      imageUrl: 'taxonomy/history_stories.webp',
      icon: '📖',
      category: 'general',
      synonyms: [
        'تاريخ', 'قصة', 'قصص', 'حكاية', 'حكايات', 'موروث شفهي',
        'سيرة', 'رواية',
        'history', 'story', 'tale', 'narrative', 'legend', 'folklore'
      ],
      relatedInterests: ['heritage_sites', 'museums_galleries', 'music_folk_arts'],
      appliesTo: ['cultural_items', 'attractions'],
      displayOrder: 15,
    ),
  ];
}

// ============================================================================
// Internal Model
// ============================================================================
class _InterestSeed {
  final String id;
  final String labelAr;
  final String labelEn;
  final String imageUrl;
  final String icon;
  final String category; // one of: architecture, clothing, craft, dance, food, music, general
  final List<String> synonyms;
  final List<String> relatedInterests;
  final List<String> appliesTo; // collections: attractions, trips, events, cultural_items
  final int displayOrder;

  const _InterestSeed({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.imageUrl,
    required this.icon,
    required this.category,
    required this.synonyms,
    required this.relatedInterests,
    required this.appliesTo,
    required this.displayOrder,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': {
      'ar': labelAr,
      'en': labelEn,
    },
    'imageUrl': imageUrl,
    'icon': icon,
    'category': category,
    'synonyms': synonyms,
    'relatedInterests': relatedInterests,
    'appliesTo': appliesTo,
    'displayOrder': displayOrder,
    'isActive': true,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
