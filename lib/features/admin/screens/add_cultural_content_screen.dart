import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AddCulturalContentScreen extends ConsumerStatefulWidget {
  final CulturalItemModel? editItem;

  const AddCulturalContentScreen({super.key, this.editItem});

  @override
  ConsumerState<AddCulturalContentScreen> createState() =>
      _AddCulturalContentScreenState();
}

class _AddCulturalContentScreenState
    extends ConsumerState<AddCulturalContentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String _selectedCategory = 'food';
  String? _selectedRegionId;
  File? _pickedImage;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.editItem != null;

  static const List<({String id, String label})> _categories = [
    (id: 'food', label: 'طعام تقليدي'),
    (id: 'craft', label: 'حرفة يدوية'),
    (id: 'dance', label: 'رقص'),
    (id: 'architecture', label: 'عمارة'),
    (id: 'music', label: 'موسيقى'),
    (id: 'clothing', label: 'ملابس تقليدية'),
  ];

  static const _legacyRegionMap = {
    'northern': 'northern_region',
    'central': 'central_region',
    'western': 'western_region',
    'eastern': 'eastern_region',
    'southern': 'southern_region',
  };

  String? _normalizeRegionId(String? id) {
    if (id == null) return null;
    final validIds = regionsData.map((r) => r.regionId).toSet();
    if (validIds.contains(id)) return id;
    return _legacyRegionMap[id];
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final item = widget.editItem!;
      _titleArController.text = item.titleAr;
      _titleEnController.text = item.titleEn;
      _descArController.text = item.descriptionAr;
      _descEnController.text = item.descriptionEn;
      final validCategoryIds = _categories.map((c) => c.id).toSet();
      _selectedCategory =
          validCategoryIds.contains(item.categoryId) ? item.categoryId : 'food';
      _selectedRegionId = _normalizeRegionId(item.regionId);
      if (item.latitude != null) _latController.text = '${item.latitude}';
      if (item.longitude != null) _lngController.text = '${item.longitude}';
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<String?> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('cultural_items')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminSelectRegion)),
      );
      return;
    }
    if (!_isEditMode && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminPickImage)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final region = regionsData.firstWhere(
        (r) => r.regionId == _selectedRegionId,
      );

      final latText = _latController.text.trim();
      final lngText = _lngController.text.trim();

      if (_isEditMode) {
        final data = <String, dynamic>{
          'titleAr': _titleArController.text.trim(),
          'titleEn': _titleEnController.text.trim(),
          'descriptionAr': _descArController.text.trim(),
          'descriptionEn': _descEnController.text.trim(),
          'categoryId': _selectedCategory,
          'regionId': _selectedRegionId,
          'regionAr': region.nameAr,
          'regionEn': region.nameEn,
        };
        if (latText.isNotEmpty && lngText.isNotEmpty) {
          data['latitude'] = double.parse(latText);
          data['longitude'] = double.parse(lngText);
        }
        if (_pickedImage != null) {
          final imageUrl = await _uploadImage(_pickedImage!);
          if (imageUrl != null) data['imageUrl'] = imageUrl;
        }
        await ref
            .read(adminRepositoryProvider)
            .updateCulturalItem(widget.editItem!.id, data);
      } else {
        final imageUrl = await _uploadImage(_pickedImage!);
        if (imageUrl == null) throw Exception(l10n.adminImageUploadFailed);
        final data = <String, dynamic>{
          'titleAr': _titleArController.text.trim(),
          'titleEn': _titleEnController.text.trim(),
          'descriptionAr': _descArController.text.trim(),
          'descriptionEn': _descEnController.text.trim(),
          'categoryId': _selectedCategory,
          'regionId': _selectedRegionId,
          'regionAr': region.nameAr,
          'regionEn': region.nameEn,
          'imageUrl': imageUrl,
        };
        if (latText.isNotEmpty && lngText.isNotEmpty) {
          data['latitude'] = double.parse(latText);
          data['longitude'] = double.parse(lngText);
        }
        await ref.read(adminRepositoryProvider).addCulturalItem(data);
      }

      ref.invalidate(culturalNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? l10n.adminItemUpdated
                : l10n.adminCulturalItemAdded),
            backgroundColor: Theme.of(context).semanticSuccess,
          ),
        );
        if (_isEditMode) {
          Navigator.pop(context);
        } else {
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.commonErrorWithMessage('')),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleArController.clear();
    _titleEnController.clear();
    _descArController.clear();
    _descEnController.clear();
    _latController.clear();
    _lngController.clear();
    setState(() {
      _selectedCategory = 'food';
      _selectedRegionId = null;
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final screenContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            _SectionLabel(l10n.adminImage),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(_pickedImage!, fit: BoxFit.cover),
                      )
                    : _isEditMode && widget.editItem!.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(widget.editItem!.imageUrl,
                                    fit: BoxFit.cover),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(l10n.adminTapToChange,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              Text(l10n.adminPickImage,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.6))),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionLabel(l10n.adminTitleArabic),
            _FormField(
              controller: _titleArController,
              hint: l10n.adminTitleArabicHint,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            _SectionLabel(l10n.adminTitleEnglish),
            _FormField(
              controller: _titleEnController,
              hint: l10n.adminTitleEnglishHint,
            ),
            const SizedBox(height: 16),

            _SectionLabel(l10n.adminDescriptionArabic),
            _FormField(
              controller: _descArController,
              hint: l10n.adminDescriptionArabicHint,
              maxLines: 4,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            _SectionLabel(l10n.adminDescriptionEnglish),
            _FormField(
              controller: _descEnController,
              hint: l10n.adminDescriptionEnglishHint,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            _SectionLabel(l10n.adminCategory),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(),
              items: _categories
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v ?? 'food'),
            ),

            const SizedBox(height: 16),

            _SectionLabel(l10n.adminRegion),
            DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: _inputDecoration(hint: l10n.adminSelectRegion),
              items: regionsData
                  .map((r) => DropdownMenuItem(
                      value: r.regionId, child: Text(r.nameAr)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRegionId = v),
              validator: (v) => v == null ? l10n.adminSelectRegion : null,
            ),

            const SizedBox(height: 16),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.adminMapCoordinatesOptional,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration:
                            _inputDecoration(hint: l10n.adminLatitudeExample),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        decoration:
                            _inputDecoration(hint: l10n.adminLongitudeExample),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _isEditMode
                            ? l10n.adminUpdateItem
                            : l10n.adminAddToArchive,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditMode ? l10n.adminEditArchiveItem : l10n.adminAddArchiveItem),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: screenContent,
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextDirection textDirection;

  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.textDirection = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
