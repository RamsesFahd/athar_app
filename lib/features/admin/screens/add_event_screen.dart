import 'dart:io';
import 'package:flutter/cupertino.dart';
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
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _ticketUrlController = TextEditingController();

  String? _selectedRegionId;
  EventType _selectedEventType = EventType.other;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _pickedImage;
  bool _isFree = true;
  bool _isSubmitting = false;

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

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final l10n = AppLocalizations.of(context);
    final current = isStart ? _startTime : _endTime;
    final initial = current ??
        (isStart
            ? const TimeOfDay(hour: 8, minute: 0)
            : const TimeOfDay(hour: 22, minute: 0));

    final now = DateTime.now();
    var selected =
        DateTime(now.year, now.month, now.day, initial.hour, initial.minute);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n.cancel,
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5))),
                    ),
                    Text(
                      isStart ? 'وقت البداية' : 'وقت النهاية',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          final tod = TimeOfDay(
                              hour: selected.hour, minute: selected.minute);
                          if (isStart) {
                            _startTime = tod;
                          } else {
                            _endTime = tod;
                          }
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Text(l10n.confirm,
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: theme.brightness,
                    primaryColor: theme.colorScheme.primary,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: false,
                    initialDateTime: selected,
                    onDateTimeChanged: (dt) => selected = dt,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmtTime(TimeOfDay t) => t.format(context);

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

  Future<void> _pasteCoordinates() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isEmpty) return;

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
    if (_startDate == null || _endDate == null) {
      _showError(l10n.adminSelectEventDate);
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('الرجاء اختيار وقت البداية والنهاية');
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
        'eventDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'timeAr': _formatTimeAr(_startTime!),
        'timeEn': _formatTimeEn(_startTime!),
        'endTimeAr': _formatTimeAr(_endTime!),
        'endTimeEn': _formatTimeEn(_endTime!),
        'latitude': double.parse(latText),
        'longitude': double.parse(lngText),
        'regionId': _selectedRegionId,
        'regionAr': region.nameAr,
        'regionEn': region.nameEn,
        'categoryId': '',
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
      _startDate = null;
      _endDate = null;
      _startTime = null;
      _endTime = null;
      _pickedImage = null;
      _isFree = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAddEvent),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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

            // Date range picker
            _SectionLabel(l10n.adminEventDate),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(12),
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
                    Icon(Icons.date_range_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      _startDate != null && _endDate != null
                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}  –  ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : l10n.adminSelectDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _startDate == null
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time pickers (start / end)
            _SectionLabel('وقت الفعالية'),
            Row(
              children: [
                Expanded(child: _timePicker(theme, isStart: true)),
                const SizedBox(width: 12),
                Expanded(child: _timePicker(theme, isStart: false)),
              ],
            ),
            const SizedBox(height: 24),

            // Lat / Lng with Smart Paste Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionLabel(l10n.adminMapCoordinates),
                TextButton.icon(
                  onPressed: _pasteCoordinates,
                  icon: const Icon(Icons.content_paste, size: 16),
                  label: const Text('لصق من الخرائط',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: _inputDecoration(hint: l10n.adminLatitude),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? l10n.requiredField
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: _inputDecoration(hint: l10n.adminLongitude),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? l10n.requiredField
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Event type
            _SectionLabel(l10n.adminEventType),
            DropdownButtonFormField<EventType>(
              initialValue: _selectedEventType,
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

            // Region
            _SectionLabel(l10n.adminRegion),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegionId,
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
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
    );
  }

  Widget _timePicker(ThemeData theme, {required bool isStart}) {
    final val = isStart ? _startTime : _endTime;
    return InkWell(
      onTap: () => _pickTime(isStart: isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isStart ? Icons.schedule_outlined : Icons.timer_off_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              val != null ? _fmtTime(val) : (isStart ? 'البداية' : 'النهاية'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: val == null
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
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
          ? (v) =>
              (v == null || v.trim().isEmpty) ? l10n.requiredField : null
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
