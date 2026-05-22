import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();
  // ❌ تم حذف متحكمات الوقت اليدوية
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _ticketUrlController = TextEditingController();

  String? _selectedRegionId;
  EventType _selectedEventType = EventType.other;
  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedTime; // ✅ إضافة متغير للوقت
  File? _pickedImage;
  bool _isFree = true;
  bool _isSubmitting = false;

  static const List<({String id, String label})> _categories = [
    (id: 'food', label: 'Traditional Food'),
    (id: 'craft', label: 'Handicraft'),
    (id: 'dance', label: 'Dance'),
    (id: 'architecture', label: 'Architecture'),
    (id: 'music', label: 'Music'),
    (id: 'clothing', label: 'Traditional Clothing'),
  ];

  String _selectedCategory = 'food';

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _ticketUrlController.dispose();
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
        .child('events')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final firstDate = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate.add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedEndDate = picked);
  }

  // ✅ دالة لاختيار الوقت
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // ✅ دوال لتنسيق الوقت تلقائياً للغتين
  String _formatTimeEn(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatTimeAr(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // ✅ دالة ذكية لاستخراج الإحداثيات من النصوص المنسوخة أو روابط جوجل ماب
  Future<void> _pasteCoordinates() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isEmpty) return;

    // يبحث عن الإحداثيات بصيغة: 21.4225, 39.8261 أو من رابط جوجل @21.4225,39.8261
    final regExp = RegExp(r'(-?\d+\.\d+),\s*(-?\d+\.\d+)');
    final match = regExp.firstMatch(text);

    if (match != null) {
      setState(() {
        _latController.text = match.group(1)!;
        _lngController.text = match.group(2)!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استخراج الإحداثيات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError('لم يتم العثور على إحداثيات صالحة في الحافظة');
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      _showError(l10n.adminSelectRegion);
      return;
    }
    if (_selectedDate == null) {
      _showError(l10n.adminSelectEventDate);
      return;
    }
    if (_selectedTime == null) {
      _showError('الرجاء اختيار وقت الفعالية'); // أضفها في الترجمة لاحقاً
      return;
    }
    if (_pickedImage == null) {
      _showError(l10n.adminPickImage);
      return;
    }
    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();
    if (latText.isEmpty || lngText.isEmpty) {
      _showError(l10n.adminEventCoordinatesRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final imageUrl = await _uploadImage(_pickedImage!);
      if (imageUrl == null) throw Exception(l10n.adminImageUploadFailed);

      final region =
          regionsData.firstWhere((r) => r.regionId == _selectedRegionId);

      await ref.read(adminRepositoryProvider).addEvent({
        'titleAr': _titleArController.text.trim(),
        'titleEn': _titleEnController.text.trim(),
        'descriptionAr': _descArController.text.trim(),
        'descriptionEn': _descEnController.text.trim(),
        'imageUrl': imageUrl,
        'eventDate': Timestamp.fromDate(_selectedDate!),
        if (_selectedEndDate != null)
          'endDate': Timestamp.fromDate(_selectedEndDate!),
        'timeAr': _formatTimeAr(_selectedTime!), // ✅ توليد الوقت العربي آلياً
        'timeEn': _formatTimeEn(_selectedTime!), // ✅ توليد الوقت الإنجليزي آلياً
        'latitude': double.parse(latText),
        'longitude': double.parse(lngText),
        'regionId': _selectedRegionId,
        'regionAr': region.nameAr,
        'regionEn': region.nameEn,
        'categoryId': _selectedCategory,
        'eventType': _selectedEventType.value,
        'isFree': _isFree,
        if (_ticketUrlController.text.trim().isNotEmpty)
          'ticketUrl': _ticketUrlController.text.trim(),
      });

      ref.invalidate(mapNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminEventAdded),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) _showError(l10n.commonErrorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleArController.clear();
    _titleEnController.clear();
    _descArController.clear();
    _descEnController.clear();
    _latController.clear();
    _lngController.clear();
    _ticketUrlController.clear();
    setState(() {
      _selectedRegionId = null;
      _selectedEventType = EventType.other;
      _selectedDate = null;
      _selectedEndDate = null;
      _selectedTime = null; // ✅ تصفير الوقت
      _pickedImage = null;
      _isFree = true;
      _selectedCategory = 'food';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: AppColors.primary.withValues(alpha: 0.5)),
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
                hint: l10n.adminTitleEnglishHint),
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

            // Date picker
            _SectionLabel(l10n.adminEventDate),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : l10n.adminSelectDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedDate != null
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Date picker (optional)
            _SectionLabel(l10n.adminEndDateOptional),
            GestureDetector(
              onTap: _pickEndDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedEndDate != null
                            ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                            : l10n.adminSelectEndDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _selectedEndDate != null
                              ? null
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_selectedEndDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedEndDate = null),
                        child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Time Picker (بدل الإدخال اليدوي)
            _SectionLabel('وقت الفعالية'), // يمكنك إضافتها لملف الترجمة
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTime != null
                          ? _formatTimeAr(_selectedTime!)
                          : 'اختر وقت الفعالية',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedTime != null
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Lat / Lng with Smart Paste Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionLabel(l10n.adminMapCoordinates),
                TextButton.icon(
                  onPressed: _pasteCoordinates,
                  icon: const Icon(Icons.content_paste, size: 16),
                  label: const Text('لصق من الخرائط', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: _inputDecoration(hint: l10n.adminLatitude),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: _inputDecoration(hint: l10n.adminLongitude),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Event type
            _SectionLabel(l10n.adminEventType),
            DropdownButtonFormField<EventType>(
              value: _selectedEventType,
              decoration: _inputDecoration(),
              items: EventType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.labelEn),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedEventType = v ?? EventType.other),
            ),
            const SizedBox(height: 16),

            // Category
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

            // Region
            _SectionLabel(l10n.adminRegion),
            DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: _inputDecoration(hint: l10n.adminSelectRegion),
              items: regionsData
                  .map((r) => DropdownMenuItem(
                      value: r.regionId, child: Text(r.nameEn)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRegionId = v),
              validator: (v) => v == null ? l10n.adminSelectRegion : null,
            ),
            const SizedBox(height: 16),

            // Free / Paid toggle
            _SectionLabel(l10n.adminAdmission),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_isFree ? l10n.adminFreeEntry : l10n.adminPaidEntry),
              subtitle: Text(_isFree ? l10n.commonFree : l10n.commonPaid),
              value: _isFree,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _isFree = v),
            ),

            // Ticket URL (only shown when paid)
            if (!_isFree) ...[
              _SectionLabel(l10n.adminTicketUrl),
              _FormField(
                controller: _ticketUrlController,
                hint: 'https://...',
                required: false,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

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
                    : Text(l10n.adminAddEvent,
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
  final bool required;

  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.textDirection = TextDirection.ltr,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null
          : null,
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