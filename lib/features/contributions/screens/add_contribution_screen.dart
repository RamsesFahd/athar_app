import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/contributions/logic/contribution_repository.dart';
import '../../../../generated/l10n/app_localizations.dart';

class AddContributionScreen extends ConsumerStatefulWidget {
  const AddContributionScreen({super.key});

  @override
  ConsumerState<AddContributionScreen> createState() =>
      _AddContributionScreenState();
}

class _AddContributionScreenState
    extends ConsumerState<AddContributionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  _ContributionTypeUi? _selectedCategory;
  String? _selectedRegionId;
  String? _selectedCityId;

  File? _mediaFile;
  String? _mediaType; // 'image' or 'video'

  bool _showValidation = false;
  bool _isLoading = false;

  static const List<_ContributionTypeUi> _categories = [
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

  Future<void> _pickImage() async {
    final xFile =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null) return;
    setState(() {
      _mediaFile = File(xFile.path);
      _mediaType = 'image';
    });
  }

  Future<void> _pickVideo() async {
    final xFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (xFile == null) return;
    setState(() {
      _mediaFile = File(xFile.path);
      _mediaType = 'video';
    });
  }

  Future<void> _submit(TouristModel tourist) async {
    setState(() => _showValidation = true);

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isCategoryValid = _selectedCategory != null;
    final isRegionValid = _selectedRegionId != null;
    final isCityValid = _selectedCityId != null;
    final isMediaValid = _mediaFile != null;

    if (!isFormValid || !isCategoryValid || !isRegionValid ||
        !isCityValid || !isMediaValid) {
      return;
    }

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(contributionRepositoryProvider).submitContribution(
            tourist: tourist,
            categoryId: _selectedCategory!.id,
            titleContent: _titleController.text.trim(),
            descriptionContent: _descriptionController.text.trim(),
            submissionLanguage: _isArabic ? 'ar' : 'en',
            regionId: _selectedRegionId!,
            cityId: _selectedCityId!,
            mediaFile: _mediaFile!,
            mediaType: _mediaType!,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submissionSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contributionErrorWithMessage('')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = _isArabic;
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: Center(child: Text(l10n.contributionAuthError)),
      ),
      data: (user) {
        if (user == null || user is! TouristModel) {
          return Scaffold(
            body: Center(child: Text(l10n.contributionUserUnavailable)),
          );
        }

        // Contributions require a verified phone number.
        if (!user.phoneVerified) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.addContributionTitle),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_locked_outlined,
                        size: 72,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                    const SizedBox(height: 20),
                    Text(
                      isArabic
                          ? 'التحقق من رقم الجوال مطلوب'
                          : 'Phone Verification Required',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.contributionPhoneVerificationRequiredBody,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.contributionGoToProfile),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.addContributionTitle),
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Text(
                        l10n.addContributionSubtitle,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      _buildSectionLabel(
                          context,
                          l10n.contributionTypeLabel),
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
                          l10n.locationLabel),
                      const SizedBox(height: 8),
                      _buildRegionDropdown(theme, l10n, isArabic),
                      const SizedBox(height: 18),
                      _buildSectionLabel(context, l10n.cityLabel),
                      const SizedBox(height: 8),
                      _buildCityDropdown(theme, l10n, isArabic),
                      const SizedBox(height: 18),
                      _buildSectionLabel(context, l10n.mediaLabel),
                      const SizedBox(height: 8),
                      _buildMediaSection(theme, l10n),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n, user),
                      const SizedBox(height: 12),
                      Text(
                        l10n.contentReviewNotice,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildTitleField(AppLocalizations l10n) {
    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: l10n.contributionTitleExampleHint,
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return l10n.requiredField;
        return null;
      },
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    final isArabic = _isArabic;
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: l10n.contributionDescriptionExampleHint,
        helperText: isArabic
            ? 'نصيحة: اذكر (التاريخ • الاستخدام • الموقع)'
            : 'Tip: include (history • usage • location)',
        prefixIcon: const Icon(Icons.notes_rounded),
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return l10n.requiredField;
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
              onTap: () => setState(() => _selectedCategory = category),
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
                    Icon(category.icon,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary),
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
                ? 'الرجاء اختيار نوع المحتوى'
                : 'Please select a content type',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedCategoryPoints(ThemeData theme, bool isArabic) {
    final category = _selectedCategory!;
    final primary = theme.colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stars_rounded, color: primary, size: 20),
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
                      color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'الصورة: ${category.imagePoints} نقطة • الفيديو: ${category.videoPoints} نقطة'
                      : 'Image: ${category.imagePoints} pts • Video: ${category.videoPoints} pts',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDropdown(
    ThemeData theme, AppLocalizations l10n, bool isArabic) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedRegionId,
      decoration: InputDecoration(
        hintText: l10n.contributionSelectRegionHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: theme.colorScheme.surface,
      items: regionMap.keys.map((id) {
        return DropdownMenuItem<String>(
          value: id,
          child: Text(regionMap[id]![isArabic ? 'ar' : 'en']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRegionId = value;
          _selectedCityId = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isArabic
              ? 'الرجاء اختيار المنطقة'
              : 'Please select a region';
        }
        return null;
      },
    );
  }

  Widget _buildCityDropdown(
      ThemeData theme, AppLocalizations l10n, bool isArabic) {
    final cityIds = _selectedRegionId == null
        ? <String>[]
        : (regionCities[_selectedRegionId] ?? <String>[]);

    return DropdownButtonFormField<String>(
      key: ValueKey(_selectedRegionId),
      initialValue: cityIds.contains(_selectedCityId) ? _selectedCityId : null,
      decoration: InputDecoration(
        hintText: _selectedRegionId == null
            ? l10n.contributionSelectRegionFirstHint
            : l10n.cityLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: theme.colorScheme.surface,
      items: cityIds.map((id) {
        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            cityMap[id]![isArabic ? 'ar' : 'en']!,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: _selectedRegionId == null
          ? null
          : (value) => setState(() => _selectedCityId = value),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.selectCityError;
        return null;
      },
    );
  }

  Widget _buildMediaSection(ThemeData theme, AppLocalizations l10n) {
    final showMediaError = _showValidation && _mediaFile == null;

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
                isSelected: _mediaType == 'image',
                onTap: _pickImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMediaTile(
                theme: theme,
                icon: Icons.videocam_outlined,
                label: l10n.addVideo,
                isSelected: _mediaType == 'video',
                onTap: _pickVideo,
              ),
            ),
          ],
        ),
        if (_mediaFile != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.contributionFileSelected,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Text(l10n.mediaRequiredHint, style: theme.textTheme.bodySmall),
        if (showMediaError) ...[
          const SizedBox(height: 8),
          Text(
            l10n.mediaRequiredError,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
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
    final foregroundColor =
        isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color;

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
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: foregroundColor),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: foregroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n, TouristModel tourist) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _submit(tourist),
      icon: const Icon(Icons.send),
      label: Text(l10n.submitContribution),
    );
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
