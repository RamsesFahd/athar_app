import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';

class AddContributionScreen extends StatefulWidget {
  const AddContributionScreen({super.key});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _ContributionTypeUi? _selectedCategory;
  String? _selectedRegion;
  String? _selectedCity;

  bool _hasImage = false;
  bool _hasVideo = false;
  bool _showValidation = false;

  final List<_ContributionTypeUi> _categories = const [
    _ContributionTypeUi(
      id: 'traditional_food',
      titleAr: 'أكل شعبي',
      titleEn: 'Traditional Food',
      imagePoints: 40,
      videoPoints: 60,
      icon: Icons.restaurant_rounded,
    ),
    _ContributionTypeUi(
      id: 'handicraft',
      titleAr: 'حرف يدوية',
      titleEn: 'Handicraft',
      imagePoints: 50,
      videoPoints: 70,
      icon: Icons.handyman_rounded,
    ),
    _ContributionTypeUi(
      id: 'dance',
      titleAr: 'رقص',
      titleEn: 'Dance',
      imagePoints: 50,
      videoPoints: 80,
      icon: Icons.theater_comedy_rounded,
    ),
    _ContributionTypeUi(
      id: 'architecture',
      titleAr: 'عمارة',
      titleEn: 'Architecture',
      imagePoints: 30,
      videoPoints: 50,
      icon: Icons.account_balance_rounded,
    ),
    _ContributionTypeUi(
      id: 'music',
      titleAr: 'موسيقى',
      titleEn: 'Music',
      imagePoints: 50,
      videoPoints: 70,
      icon: Icons.music_note_rounded,
    ),
    _ContributionTypeUi(
      id: 'traditional_clothing',
      titleAr: 'لبس تقليدي',
      titleEn: 'Traditional Clothing',
      imagePoints: 40,
      videoPoints: 60,
      icon: Icons.checkroom_rounded,
    ),
  ];
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isArabic => Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = _isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addContributionTitle),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                l10n.addContributionSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 22),
              _buildSectionLabel(
                context,
                isArabic ? 'نوع المساهمة' : 'Contribution Type',
              ),
              const SizedBox(height: 8),
              _buildCategorySelector(theme, isArabic),
              if (_selectedCategory != null) ...[
                const SizedBox(height: 10),
                _buildSelectedCategoryPoints(theme, isArabic),
              ],
              const SizedBox(height: 18),
              _buildSectionLabel(context, l10n.titleLabel),
              const SizedBox(height: 8),
              _buildTitleField(l10n),
              const SizedBox(height: 18),
              _buildSectionLabel(context, l10n.descriptionLabel),
              const SizedBox(height: 8),
              _buildDescriptionField(l10n),
              const SizedBox(height: 18),
              _buildSectionLabel(
                context,
                isArabic ? 'المنطقة' : 'Region',
              ),
              const SizedBox(height: 8),
              _buildRegionDropdown(theme, isArabic),
              const SizedBox(height: 18),
              _buildSectionLabel(context, l10n.cityLabel),
              const SizedBox(height: 8),
              _buildCityDropdown(theme, l10n, isArabic),
              const SizedBox(height: 18),
              _buildSectionLabel(context, l10n.mediaLabel),
              const SizedBox(height: 8),
              _buildMediaSection(theme, l10n),
              const SizedBox(height: 24),
              _buildSubmitButton(l10n),
              const SizedBox(height: 12),
              Text(
                l10n.contentReviewNotice,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: isArabic
            ? 'مثال: رقصة الخطوة – عسير'
            : 'Example: Al-Khatwa Dance – Asir',
        prefixIcon: const Icon(Icons.title_rounded),

        // ✨ تحسين الشكل
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.requiredField;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: isArabic
            ? 'اكتب وصفًا واضحًا: ما هو؟ أين يُستخدم؟ ولماذا مهم؟'
            : 'Write a clear description: what is it, where is it used, and why is it important?',

        helperText: isArabic
            ? 'نصيحة: اذكر (التاريخ • الاستخدام • الموقع)'
            : 'Tip: include (history • usage • location)',

        prefixIcon: const Icon(Icons.notes_rounded),
        alignLabelWithHint: true,

        // ✨ تحسين الشكل
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.requiredField;
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector(ThemeData theme, bool isArabic) {
    final showCategoryError = _showValidation && _selectedCategory == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory?.id == category.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withValues(alpha: 0.30),
                    width: isSelected ? 1.4 : 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? category.titleAr : category.titleEn,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (showCategoryError) ...[
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'الرجاء اختيار نوع المساهمة'
                : 'Please select a contribution type',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedCategoryPoints(ThemeData theme, bool isArabic) {
    final category = _selectedCategory!;
    final primary = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.surface;
    final borderColor = theme.dividerColor.withValues(alpha: 0.10);
    final iconBackgroundColor = primary.withValues(alpha: 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.stars_rounded,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'نقاط ${category.titleAr}'
                      : '${category.titleEn} Points',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'الصورة: ${category.imagePoints} نقطة • الفيديو: ${category.videoPoints} نقطة'
                      : 'Image: ${category.imagePoints} pts • Video: ${category.videoPoints} pts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDropdown(ThemeData theme, bool isArabic) {
    final regions = isArabic
        ? const [
            'المنطقة الوسطى',
            'المنطقة الغربية',
            'المنطقة الشمالية',
            'المنطقة الشرقية',
            'المنطقة الجنوبية',
          ]
        : const [
            'Central Region',
            'Western Region',
            'Northern Region',
            'Eastern Region',
            'Southern Region',
          ];

    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      decoration: InputDecoration(
        hintText: isArabic ? 'اختر المنطقة' : 'Select region',
      ),
      dropdownColor: theme.colorScheme.surface,
      items: regions.map((region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRegion = value;
          _selectedCity = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isArabic ? 'الرجاء اختيار المنطقة' : 'Please select a region';
        }
        return null;
      },
    );
  }

  Widget _buildCityDropdown(
    ThemeData theme,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final citiesByRegion = {
      'المنطقة الوسطى': ['الرياض', 'القصيم', 'حائل'],
      'المنطقة الغربية': ['جدة', 'مكة', 'المدينة', 'الطائف'],
      'المنطقة الشمالية': ['تبوك', 'عرعر', 'سكاكا'],
      'المنطقة الشرقية': ['الدمام', 'الخبر', 'الأحساء', 'الجبيل'],
      'المنطقة الجنوبية': ['أبها', 'خميس مشيط', 'جازان', 'نجران', 'الباحة'],
      'Central Region': ['Riyadh', 'Qassim', 'Hail'],
      'Western Region': ['Jeddah', 'Makkah', 'Madinah', 'Taif'],
      'Northern Region': ['Tabuk', 'Arar', 'Sakaka'],
      'Eastern Region': ['Dammam', 'Khobar', 'Al Ahsa', 'Jubail'],
      'Southern Region': [
        'Abha',
        'Khamis Mushait',
        'Jazan',
        'Najran',
        'Al Baha'
      ],
    };

    final cities = _selectedRegion == null
        ? <String>[]
        : (citiesByRegion[_selectedRegion] ?? []);

    return DropdownButtonFormField<String>(
      value: cities.contains(_selectedCity) ? _selectedCity : null,
      decoration: InputDecoration(
        hintText: _selectedRegion == null
            ? (isArabic ? 'اختر المنطقة أولاً' : 'Select region first')
            : l10n.cityLabel,
      ),
      dropdownColor: theme.colorScheme.surface,
      items: cities.map((city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(
            city,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: _selectedRegion == null
          ? null
          : (value) {
              setState(() => _selectedCity = value);
            },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.selectCityError;
        }
        return null;
      },
    );
  }

  Widget _buildMediaSection(ThemeData theme, AppLocalizations l10n) {
    final showMediaError = _showValidation && !_hasImage && !_hasVideo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMediaTile(
                theme: theme,
                icon: Icons.photo_camera_outlined,
                label: l10n.addPhoto,
                isSelected: _hasImage,
                onTap: () {
                  setState(() {
                    _hasImage = true;
                    _hasVideo = false;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMediaTile(
                theme: theme,
                icon: Icons.videocam_outlined,
                label: l10n.addVideo,
                isSelected: _hasVideo,
                onTap: () {
                  setState(() {
                    _hasVideo = true;
                    _hasImage = false;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l10n.mediaRequiredHint,
          style: theme.textTheme.bodySmall,
        ),
        if (showMediaError) ...[
          const SizedBox(height: 8),
          Text(
            l10n.mediaRequiredError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaTile({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.35);

    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.06)
        : theme.colorScheme.surface;

    final foregroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 118,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: foregroundColor,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: _submit,
      icon: const Icon(Icons.send),
      label: Text(l10n.submitContribution),
    );
  }

  void _submit() {
    setState(() {
      _showValidation = true;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isCategoryValid = _selectedCategory != null;
    final isRegionValid = _selectedRegion != null;
    final isMediaValid = _hasImage || _hasVideo;

    if (!isFormValid || !isCategoryValid || !isRegionValid || !isMediaValid) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.submissionSuccessMessage),
      ),
    );

    Navigator.pop(context);
  }
}

class _ContributionTypeUi {
  final String id;
  final String titleAr;
  final String titleEn;
  final int imagePoints;
  final int videoPoints;
  final IconData icon;

  const _ContributionTypeUi({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.imagePoints,
    required this.videoPoints,
    required this.icon,
  });
}
