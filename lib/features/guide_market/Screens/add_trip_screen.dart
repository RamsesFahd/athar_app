import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key});

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleAr = TextEditingController();
  final _titleEn = TextEditingController();
  final _shortDescAr = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _descAr = TextEditingController(
    text: '## ما يشمله الجولة\n- \n\n## الجدول الزمني\n- \n\n## ما يجب إحضاره\n- ',
  );
  final _descEn = TextEditingController(
    text: '## What\'s Included\n- \n\n## Schedule\n- \n\n## What to Bring\n- ',
  );
  Map<String, String>? _selectedCity;

  // قائمة المدن المعتمدة في التطبيق
  static const List<Map<String, String>> _saudiCities = [
    {'ar': 'الرياض', 'en': 'Riyadh'},
    {'ar': 'جدة', 'en': 'Jeddah'},
    {'ar': 'مكة المكرمة', 'en': 'Makkah'},
    {'ar': 'المدينة المنورة', 'en': 'Madinah'},
    {'ar': 'العلا', 'en': 'AlUla'},
    {'ar': 'الدمام', 'en': 'Dammam'},
    {'ar': 'أبها', 'en': 'Abha'},
    {'ar': 'الطائف', 'en': 'Taif'},
    {'ar': 'تبوك', 'en': 'Tabuk'},
  ];
  final _adultPrice = TextEditingController();
  final _childPrice = TextEditingController();

  File? _pickedImage;
  bool _isSubmitting = false;
  final Set<String> _accessibilityFeatures = {};

  static const _accessibilityOptions = [
    (key: 'wheelchair', labelEn: 'Wheelchair Accessible', icon: Icons.accessible),
    (key: 'family', labelEn: 'Family / Child Friendly', icon: Icons.family_restroom),
  ];

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();
    _shortDescAr.dispose();
    _shortDescEn.dispose();
    _descAr.dispose();
    _descEn.dispose();
    
    _adultPrice.dispose();
    _childPrice.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('trip_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a trip image')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final currentUser = ref.read(authNotifierProvider).value;
      if (currentUser == null || currentUser is! TutorModel) {
        throw 'Could not identify tutor account';
      }

      final imageUrl = await _uploadImage(_pickedImage!);
      final tripId = const Uuid().v4();

      final adultPrice = double.tryParse(_adultPrice.text.trim()) ?? 0.0;
      final childPrice = double.tryParse(_childPrice.text.trim()) ?? 0.0;

      final trip = TripModel(
        id: tripId,
        titleAr: _titleAr.text.trim(),
        titleEn: _titleEn.text.trim(),
        shortDescriptionAr: _shortDescAr.text.trim(),
        shortDescriptionEn: _shortDescEn.text.trim(),
        descriptionAr: _descAr.text.trim(),
        descriptionEn: _descEn.text.trim(),
        cityAr: _selectedCity!['ar']!,
        cityEn: _selectedCity!['en']!,
        adultPrice: adultPrice,
        childPrice: childPrice,
        imageUrl: imageUrl,
        guide: currentUser.fullName,
        company: currentUser.companyName ?? '',
        license: currentUser.licenceNumber ?? '',
        tutorId: currentUser.uId,
        tutorType: currentUser.tutorType?.name ?? 'individual',
        accessibilityFeatures: _accessibilityFeatures.toList(),
        status: 'pending',
      );

      await ref.read(marketplaceRepositoryProvider).submitTrip(trip);

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Trip submitted! It will appear in the marketplace once approved by admin.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authNotifierProvider).value;
    final tutor = currentUser is TutorModel ? currentUser : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Image Picker ──────────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  image: _pickedImage != null
                      ? DecorationImage(
                          image: FileImage(_pickedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _pickedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.6)),
                          const SizedBox(height: 8),
                          Text('Tap to add trip image',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.7))),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // ── Section: Titles ───────────────────────────────────────
            _sectionHeader(theme, 'Trip Title'),
            const SizedBox(height: 12),
            _field(_titleAr, 'Title in Arabic (العنوان بالعربي)', required: true),
            const SizedBox(height: 12),
            _field(_titleEn, 'Title in English', required: true),
            const SizedBox(height: 20),

            // ── Section: Short Descriptions ───────────────────────────
            _sectionHeader(theme, 'Short Description'),
            const SizedBox(height: 12),
            _field(_shortDescAr, 'Short description in Arabic', required: true),
            const SizedBox(height: 12),
            _field(_shortDescEn, 'Short description in English', required: true),
            const SizedBox(height: 20),

            // ── Section: Full Descriptions ────────────────────────────
            _sectionHeader(theme, 'Full Description'),
            Text(
              'Use the template below — fill in each bullet point.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _field(_descAr, 'Full description in Arabic',
                required: true, maxLines: 8),
            const SizedBox(height: 12),
            _field(_descEn, 'Full description in English',
                required: true, maxLines: 8),
            const SizedBox(height: 20),

            // ── Section: Pricing ──────────────────────────────────────
            _sectionHeader(theme, 'Pricing (ر.س)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _adultPrice,
                    'Adult price',
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    extraValidator: (v) {
                      if (double.tryParse(v ?? '') == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _childPrice,
                    'Child price (0 = free)',
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    extraValidator: (v) {
                      if (double.tryParse(v ?? '') == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Section: Trip Details ─────────────────────────────────
            _sectionHeader(theme, 'Trip Details'),
            const SizedBox(height: 12),
            DropdownButtonFormField<Map<String, String>>(
              initialValue: _selectedCity,
              decoration: InputDecoration(
                labelText: 'City (المدينة)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _saudiCities.map((city) {
                final isAr = Localizations.localeOf(context).languageCode == 'ar';
                return DropdownMenuItem(
                  value: city,
                  child: Text(isAr ? city['ar']! : city['en']!),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCity = val),
              validator: (v) => v == null ? 'Please select a city / الرجاء اختيار المدينة' : null,
            ),
            const SizedBox(height: 20),

            // ── Section: Accessibility ────────────────────────────────
            _sectionHeader(theme, 'Accessibility'),
            const SizedBox(height: 8),
            ..._accessibilityOptions.map((opt) => CheckboxListTile(
                  value: _accessibilityFeatures.contains(opt.key),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _accessibilityFeatures.add(opt.key);
                      } else {
                        _accessibilityFeatures.remove(opt.key);
                      }
                    });
                  },
                  secondary: Icon(opt.icon, color: theme.colorScheme.primary),
                  title: Text(opt.labelEn, style: theme.textTheme.bodyMedium),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: 20),

            // ── Guide Info Preview ────────────────────────────────────
            if (tutor != null) ...[
              _sectionHeader(theme, 'Guide Info (auto-filled from your profile)'),
              const SizedBox(height: 8),
              if (tutor.tutorType == TutorType.individual) ...[
                _infoRow(theme, Icons.person_outline, 'Guide: ${tutor.fullName}'),
                _infoRow(theme, Icons.verified_outlined,
                    'License: ${tutor.licenceNumber ?? '—'}'),
              ] else ...[
                _infoRow(theme, Icons.business_outlined,
                    'Company: ${tutor.companyName ?? '—'}'),
                _infoRow(theme, Icons.verified_outlined,
                    'License: ${tutor.licenceNumber ?? '—'}'),
              ],
              const SizedBox(height: 20),
            ],

            // ── Submit ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Submit for Review',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Required';
        return extraValidator?.call(v);
      },
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
