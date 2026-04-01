import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';

class AddCulturalContentScreen extends ConsumerStatefulWidget {
  const AddCulturalContentScreen({super.key});

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

  String _selectedCategory = 'food';
  String? _selectedRegionId;
  File? _pickedImage;
  bool _isSubmitting = false;

  static const List<({String id, String label})> _categories = [
    (id: 'food', label: 'Traditional Food'),
    (id: 'craft', label: 'Handicraft'),
    (id: 'dance', label: 'Dance'),
    (id: 'architecture', label: 'Architecture'),
    (id: 'music', label: 'Music'),
    (id: 'clothing', label: 'Traditional Clothing'),
  ];

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a region')),
      );
      return;
    }
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final imageUrl = await _uploadImage(_pickedImage!);
      if (imageUrl == null) throw Exception('Image upload failed');

      // Resolve region names from the selected regionId
      final region = regionsData.firstWhere(
        (r) => r.regionId == _selectedRegionId,
      );

      await ref.read(adminRepositoryProvider).addCulturalItem({
        'titleAr': _titleArController.text.trim(),
        'titleEn': _titleEnController.text.trim(),
        'descriptionAr': _descArController.text.trim(),
        'descriptionEn': _descEnController.text.trim(),
        'categoryId': _selectedCategory,
        'regionId': _selectedRegionId,
        'regionAr': region.nameAr,
        'regionEn': region.nameEn,
        'imageUrl': imageUrl,
      });

      // Invalidate the cultural archive so it reloads with the new item
      ref.invalidate(culturalNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cultural item added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    setState(() {
      _selectedCategory = 'food';
      _selectedRegionId = null;
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            _SectionLabel('Image'),
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: AppColors.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('Tap to pick image',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.6))),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Titles
            _SectionLabel('Title (Arabic)'),
            _FormField(
              controller: _titleArController,
              hint: 'أدخل العنوان بالعربي',
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            _SectionLabel('Title (English)'),
            _FormField(
              controller: _titleEnController,
              hint: 'Enter English title',
            ),
            const SizedBox(height: 16),

            // Descriptions
            _SectionLabel('Description (Arabic)'),
            _FormField(
              controller: _descArController,
              hint: 'أدخل الوصف بالعربي',
              maxLines: 4,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            _SectionLabel('Description (English)'),
            _FormField(
              controller: _descEnController,
              hint: 'Enter English description',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Category
            _SectionLabel('Category'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(),
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedCategory = v ?? 'food'),
            ),

            const SizedBox(height: 16),

            // Region
            _SectionLabel('Region'),
            DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: _inputDecoration(hint: 'Select a region'),
              items: regionsData
                  .map((r) => DropdownMenuItem(
                      value: r.regionId, child: Text(r.nameEn)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRegionId = v),
              validator: (v) =>
                  v == null ? 'Please select a region' : null,
            ),

            const SizedBox(height: 32),

            // Submit
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
                    : const Text('Add to Archive',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
