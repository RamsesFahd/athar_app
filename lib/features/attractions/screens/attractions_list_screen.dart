import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/attractions/logic/attractions_repository.dart';
import 'package:athar_app/features/attractions/widgets/attraction_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AttractionsListScreen extends ConsumerStatefulWidget {
  const AttractionsListScreen({super.key});

  @override
  ConsumerState<AttractionsListScreen> createState() =>
      _AttractionsListScreenState();
}

class _AttractionsListScreenState
    extends ConsumerState<AttractionsListScreen> {
  bool _isGridView = true;
  bool _showFilters = false;
  String _selectedRegion = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static Color _hexColor(String code) {
    final n = code.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$n', radix: 16));
  }

  // ── دالة مساعدة لرفع الصورة من الـ Assets إلى Storage ──
  Future<String> _uploadImageFromAssets(
      String assetPath, String storagePath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final ref = FirebaseStorage.instance.ref().child(storagePath);
    await ref.putData(bytes);

    return await ref.getDownloadURL();
  }

  // ── 🔴 الدالة الرئيسية لرفع البيانات والصور 🔴 ──
  Future<void> _uploadBulkDataWithImages(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'جاري الرفع (الصور تأخذ وقت، لا تقفل التطبيق)... ⏳')),
    );

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('attractions');
    final batch = firestore.batch();

    // 💡 ضع جميع بيانات المعالم هنا
    // 💡 ضع جميع بيانات المعالم هنا
    final attractionsData = [
      {
        'nameAr': 'غابة رغدان',
        'nameEn': 'Raghadan Forest',
        'city': 'الباحة',
        'region': 'southern_region', // المنطقة الجنوبية
        'category': 'Nature', // تصنيف ثابت
        'categoryColorCode': '#3D8B49', // لون الطبيعة الثابت
        'localMainImage': 'assets/images/attractions/ra1.png',
        'localGallery': [
          'assets/images/attractions/ra2.png',
          'assets/images/attractions/ra3.png'
        ],
        'descriptionAr': 'تعد غابة رغدان في الباحة من أشهر وأكبر غابات المملكة، وتتميز بمساحتها الواسعة والضباب الذي يغطي معظم مناطقها؛ إذ تقع الغابة في منطقة مرتفعة، وتضم أشجاراً معمرة منذ مئات السنين. يضم متنزه غابة رغدان أنشطة وفعاليات ومرافق متنوعة للجميع؛ حيث يحتوي على مطل على طبيعة الباحة الخلابة ومرتفعاتها بين الضباب، وشلالات مياه، وجسر معلق وفعالية الانزلاق الحر.',
        'descriptionEn': 'Raghadan Forest in Al Baha is one of the Kingdom\'s most famous and largest forests, characterized by its vast area and the fog that covers most of its regions. The forest features centuries-old trees, scenic viewpoints, waterfalls, a suspension bridge, and a zipline.',
        'address': 'طريق الملك عبدالعزيز، رغدان، الباحة',
        'coordinates': const GeoPoint(20.0298, 41.4429),
        'isAlwaysOpen': true,
        'openingHoursAr': '',
        'openingHoursEn': '',
        'entryFee': 0.0,
        'ticketBookingUrl': null,
      },
      {
        'nameAr': 'شاطئ نصف القمر',
        'nameEn': 'Half Moon Beach',
        'city': 'الخبر',
        'region': 'eastern_region', // المنطقة الشرقية
        'category': 'Nature', // تصنيف ثابت
        'categoryColorCode': '#3D8B49', // لون الطبيعة الثابت
        'localMainImage': 'assets/images/attractions/mo1.png',
        'localGallery': [
          'assets/images/attractions/mo2.png'
        ],
        'descriptionAr': 'يعتبر شاطئ نصف القمر من أشهر الشواطئ في السعودية، ومن أطولها في منطقة الخليج العربي ويمتد على طول 18 كيلومتر تقريباً، وسمى بذلك بسبب شكله المنحني على شكل نصف قمر. ويضم الشاطئ أكثر من 700 مظلة وجلسة تطل على البحر، بالإضافة إلى ملاعب لممارسات الرياضات المختلفة.',
        'descriptionEn': 'Half Moon Beach is one of the most famous and longest beaches in Saudi Arabia and the Arabian Gulf, stretching approximately 18 km. Named for its crescent shape, the beach features over 700 shaded seating areas, sports fields, horseback riding, and cycling.',
        'address': 'خليج نصف القمر، الظهران',
        'coordinates': const GeoPoint(26.1362, 50.0386),
        'isAlwaysOpen': true,
        'openingHoursAr': '',
        'openingHoursEn': '',
        'entryFee': 0.0,
        'ticketBookingUrl': null,
      },
      {
        'nameAr': 'مسجد الرحمة',
        'nameEn': 'Al Rahma Mosque',
        'city': 'جدة',
        'region': 'western_region', // المنطقة الغربية
        'category': 'Heritage', // تصنيف ثابت
        'categoryColorCode': '#7D5A3C', // لون التراث الثابت
        'localMainImage': 'assets/images/attractions/rah1.png',
        'localGallery': [
          'assets/images/attractions/rah2.png'
        ],
        'descriptionAr': 'يُطلق على مسجد الرحمة اسم المسجد العائم، ويقف بشكل فريد فوق عدد من الركائز الخرسانية البيضاء في البحر الأحمر، وهو أول مسجد في العالم يتم بناؤه فوق الماء. تم بناء المسجد من الرخام الأبيض اللامع، وفي الداخل، تزينه قبة فيروزية عملاقة بـ56 نافذة ملونة ومحاطة بآيات قرآنية مكتوبة بالخط العربي.',
        'descriptionEn': 'Known as the Floating Mosque, Al Rahma Mosque uniquely stands on white concrete pillars in the Red Sea. It is the first mosque in the world built over water. Built from gleaming white marble, its interior is decorated with a giant turquoise dome and stained glass windows.',
        'address': 'طريق الكورنيش، الشاطئ، جدة',
        'coordinates': const GeoPoint(21.648694, 39.100972), 
        'isAlwaysOpen': true,
        'openingHoursAr': '',
        'openingHoursEn': '',
        'entryFee': 0.0,
        'ticketBookingUrl': null,
      },
      {
        'nameAr': 'نافورة الملك فهد',
        'nameEn': 'King Fahd\'s Fountain',
        'city': 'جدة',
        'region': 'western_region', // المنطقة الغربية
        'category': 'Modern', // تصنيف ثابت
        'categoryColorCode': '#2E5FA3', // اللون الحديث الثابت
        'localMainImage': 'assets/images/attractions/naf1.png',
        'localGallery': [
          'assets/images/attractions/naf2.png'
        ],
        'descriptionAr': 'حين تقف أمام نافورة الملك فهد التي تعد أطول نافورة في العالم ستكون على مقربة من نصب تذكاري يتجاوز عمره 30 عامًا، وسط أمواج البحر الأحمر، على ارتفاع 312 مترًا وسرعة ضخ المياه تبلغ 350 كلم/ساعة. تزيّن مياه النافورة الهائلة غروب شمس مدينة جدة.',
        'descriptionEn': 'King Fahd\'s Fountain is the tallest of its type in the world, jetting water up to 312 meters at speeds of 350 km/h into the Red Sea. Gifted to the city by King Fahd in 1985, the fountain beautifully decorates Jeddah\'s sunset and night sky.',
        'address': 'الكورنيش، الأندلس، جدة',
        'coordinates': const GeoPoint(21.5152, 39.1481),
        'isAlwaysOpen': false,
        'openingHoursAr': '٦:٠٠ م - ٣:٠٠ ص',
        'openingHoursEn': '6:00 PM - 3:00 AM',
        'entryFee': 0.0,
        'ticketBookingUrl': null,
      },
      {
        'nameAr': 'نادي شاطئ شيدز',
        'nameEn': 'Shades Beach Club',
        'city': 'جدة',
        'region': 'western_region', // المنطقة الغربية
        'category': 'Modern', // تصنيف ثابت
        'categoryColorCode': '#2E5FA3', // اللون الحديث الثابت
        'localMainImage': 'assets/images/attractions/sha1.png',
        'localGallery': [
          'assets/images/attractions/sha2.png',
          'assets/images/attractions/sha3.png'
        ],
        'descriptionAr': 'يقع النادي على سواحل درة العروس الخلابة، ويُعد أول نادٍ شاطئي من نوعه في السعودية. وقد صُمّم النادي ليكون مساحة واسعة وعائلية تجمع بين الراحة، والخصوصية، والخدمات الشاطئية المتكاملة، في أجواء راقية تطل مباشرة على البحر الأحمر.',
        'descriptionEn': 'Located on the stunning shores of Durrat Al Arus, Shades is the first beach club of its kind in Saudi Arabia. Designed as a spacious family-friendly destination, it combines comfort, privacy, and full beach services in an elegant setting overlooking the Red Sea.',
        'address': 'درة العروس، جدة',
        'coordinates': const GeoPoint(21.9547, 38.9608),
        'isAlwaysOpen': false,
        'openingHoursAr': '٩:٠٠ ص - ١٢:٠٠ ص',
        'openingHoursEn': '9:00 AM - 12:00 AM',
        'entryFee': 0.0, 
        'ticketBookingUrl': null,
      },
    ];
    try {
      for (var item in attractionsData) {
        final docRef = collection.doc(); // إنشاء ID المعلم

        // 1. رفع الصورة الأساسية
        final mainImagePath = item['localMainImage'] as String;
        final mainImageUrl = await _uploadImageFromAssets(
          mainImagePath,
          'attractions/${docRef.id}/main_image.jpg',
        );

        // 2. رفع صور المعرض (Gallery) إن وجدت
        List<String> galleryUrls = [];
        final localGallery = item['localGallery'] as List<String>;
        for (int i = 0; i < localGallery.length; i++) {
          final url = await _uploadImageFromAssets(
            localGallery[i],
            'attractions/${docRef.id}/gallery_$i.jpg',
          );
          galleryUrls.add(url);
        }

        // 3. تنظيف البيانات
        item.remove('localMainImage');
        item.remove('localGallery');
        item['mainImage'] = mainImageUrl;
        item['gallery'] = galleryUrls;
        item['createdAt'] = FieldValue.serverTimestamp();

        // 4. إضافة البيانات للـ Batch
        batch.set(docRef, item);
      }

      // 5. حفظ كل شيء
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الصور والبيانات بنجاح! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final attractionsAsync = ref.watch(attractionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'المعالم السياحية' : 'Attractions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          attractionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (items) {
              final regions = ['All', ...{...items.map((i) => i.region)}];
              final categories = ['All', ...{...items.map((i) => i.category)}];

              final categoryColors = <String, Color>{
                for (final item in items)
                  item.category: _hexColor(item.categoryColorCode),
              };

              final filtered = items.where((item) {
                final matchRegion =
                    _selectedRegion == 'All' || item.region == _selectedRegion;
                final matchCat = _selectedCategory == 'All' ||
                    item.category == _selectedCategory;
                final q = _searchQuery.toLowerCase();
                final matchSearch = q.isEmpty ||
                    item.getName(isAr).toLowerCase().contains(q) ||
                    item.city.toLowerCase().contains(q);
                return matchRegion && matchCat && matchSearch;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: isAr
                                    ? 'ابحث عن معلم سياحي...'
                                    : 'Search attractions...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.sage800
                                          .withValues(alpha: 0.4),
                                    ),
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.primary),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _isGridView = !_isGridView),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Icon(
                              _isGridView ? Icons.grid_view : Icons.view_list,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _showFilters = !_showFilters),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: _showFilters
                                    ? AppColors.primary.withValues(alpha: 0.7)
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.3),
                              ),
                              backgroundColor: _showFilters
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.white,
                            ),
                            child: Icon(
                              Icons.tune,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showFilters) ...[
                    const SizedBox(height: 12),
                    _FilterRow(
                      label: isAr ? 'المنطقة' : 'Region',
                      options: regions,
                      selected: _selectedRegion,
                      onSelected: (v) => setState(() => _selectedRegion = v),
                      isAr: isAr,
                    ),
                    const SizedBox(height: 6),
                    _FilterRow(
                      label: isAr ? 'التصنيف' : 'Category',
                      options: categories,
                      selected: _selectedCategory,
                      onSelected: (v) => setState(() => _selectedCategory = v),
                      isAr: isAr,
                      colorFor: (v) => v == 'All' ? null : categoryColors[v],
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          items.isEmpty
                              ? (isAr
                                  ? 'لا توجد معالم سياحية'
                                  : 'No attractions available')
                              : (isAr ? 'لا توجد نتائج' : 'No results found'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: _isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.6,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) => AttractionCard(
                                attraction: filtered[index],
                                isGridView: true,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) => AttractionCard(
                                attraction: filtered[index],
                                isGridView: false,
                              ),
                            ),
                    ),
                ],
              );
            },
          ),
          
          // ── 🔴 زر الرفع المؤقت 🔴 ──
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _uploadBulkDataWithImages(context),
              icon: const Icon(Icons.cloud_upload, size: 28),
              label: const Text(
                'رفع البيانات والصور\n(اضغط مرة واحدة)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ), // <-- هنا قوس إغلاق الـ Stack
    ); // <-- وهنا قوس إغلاق الـ Scaffold الذي كان مفقوداً
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isAr;
  final Color? Function(String)? colorFor;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.isAr,
    this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = options[index];
          final isSelected = value == selected;
          final accent = colorFor?.call(value) ??
              Theme.of(context).colorScheme.primary;

          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                value == 'All' ? (isAr ? 'الكل' : 'All') : value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.sage800,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}