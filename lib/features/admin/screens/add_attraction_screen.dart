import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';

class AddAttractionScreen extends ConsumerStatefulWidget {
  final AttractionModel? editAttraction;

  const AddAttractionScreen({super.key, this.editAttraction});

  @override
  ConsumerState<AddAttractionScreen> createState() =>
      _AddAttractionScreenState();
}

class _AddAttractionScreenState extends ConsumerState<AddAttractionScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Identity ─────────────────────────────────────────────────────────────────
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();

  // ── Classification ────────────────────────────────────────────────────────────
  String _selectedCategory = 'Heritage';
  String _categoryColorCode = '#7D5A3C';

  static const _categories = ['Heritage', 'Nature', 'Arts', 'Modern'];
  static const _categoryDefaultColors = {
    'Heritage': '#7D5A3C',
    'Nature': '#3D8B49',
    'Arts': '#9B2335',
    'Modern': '#2E5FA3',
  };

  static const _regionToKey = {
    'central_region': 'central',
    'western_region': 'western',
    'northern_region': 'northern',
    'eastern_region': 'eastern',
    'southern_region': 'southern',
  };

  // ── Location ──────────────────────────────────────────────────────────────────
  String? _selectedRegionId;
  String? _selectedCityId;
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // ── Main Image ────────────────────────────────────────────────────────────────
  File? _mainImageFile;
  String? _existingMainImageUrl;

  // ── Gallery ───────────────────────────────────────────────────────────────────
  List<File> _galleryFiles = [];
  List<String> _existingGalleryUrls = [];

  // ── Video ─────────────────────────────────────────────────────────────────────
  File? _videoFile;
  String? _existingVideoUrl;

  // ── Hours & Fees ──────────────────────────────────────────────────────────────
  bool _isAlwaysOpen = false;
  final _hoursArController = TextEditingController();
  final _hoursEnController = TextEditingController();
  final _feeController = TextEditingController(text: '0');

  // ── Optional ──────────────────────────────────────────────────────────────────
  final _ticketUrlController = TextEditingController();

  bool _isSubmitting = false;

  bool get _isEditing => widget.editAttraction != null;
  int get _totalGalleryCount =>
      _existingGalleryUrls.length + _galleryFiles.length;

  List<String> get _availableCities {
    if (_selectedRegionId == null) return [];
    final key = _regionToKey[_selectedRegionId];
    if (key == null) return [];
    return regionCities[key] ?? [];
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) _initFromEdit(widget.editAttraction!);
  }

  void _initFromEdit(AttractionModel a) {
    _nameArController.text = a.name['ar'] ?? '';
    _nameEnController.text = a.name['en'] ?? '';
    _descArController.text = a.description['ar'] ?? '';
    _descEnController.text = a.description['en'] ?? '';
    _selectedCategory = a.category;
    _categoryColorCode = a.categoryColorCode;
    _selectedRegionId = a.region;
    _selectedCityId = _findCityId(a.city);
    _addressController.text = a.address;
    _latController.text = a.coordinates.latitude.toString();
    _lngController.text = a.coordinates.longitude.toString();
    _existingMainImageUrl = a.mainImage.isNotEmpty ? a.mainImage : null;
    _existingGalleryUrls = List.from(a.gallery);
    _isAlwaysOpen = a.isAlwaysOpen;
    _hoursArController.text = a.openingHours['ar'] ?? '';
    _hoursEnController.text = a.openingHours['en'] ?? '';
    _feeController.text = a.entryFee.toString();
    _ticketUrlController.text = a.ticketBookingUrl ?? '';
    _existingVideoUrl = a.videoUrl;
  }

  String? _findCityId(String cityName) {
    final lower = cityName.toLowerCase();
    for (final entry in cityMap.entries) {
      if ((entry.value['en'] ?? '').toLowerCase() == lower ||
          (entry.value['ar'] ?? '') == cityName) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _hoursArController.dispose();
    _hoursEnController.dispose();
    _feeController.dispose();
    _ticketUrlController.dispose();
    super.dispose();
  }

  // ── Media picking ─────────────────────────────────────────────────────────────

  Future<void> _pickMainImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _mainImageFile = File(picked.path));
  }

  Future<void> _addGalleryImage() async {
    if (_totalGalleryCount >= 8) return;
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _galleryFiles.add(File(picked.path)));
  }

  Future<void> _pickVideo() async {
    final picked =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => _videoFile = File(picked.path));
  }

  // ── Upload helpers ────────────────────────────────────────────────────────────

  Future<String> _uploadImage(File file, String folder) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(folder)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<String> _uploadVideo(File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance
        .ref()
        .child('attractions/videos')
        .child('${DateTime.now().millisecondsSinceEpoch}.$ext');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  // ── Submit ────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegionId == null) {
      _showSnackBar('Please select a region', isError: true);
      return;
    }
    if (_selectedCityId == null) {
      _showSnackBar('Please select a city', isError: true);
      return;
    }
    if (_mainImageFile == null && _existingMainImageUrl == null) {
      _showSnackBar('Please select a main image', isError: true);
      return;
    }

    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();
    if (latText.isEmpty || lngText.isEmpty) {
      _showSnackBar('Please enter coordinates (lat & lng)', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final mainImageUrl = _mainImageFile != null
          ? await _uploadImage(_mainImageFile!, 'attractions/main')
          : _existingMainImageUrl!;

      final newGalleryUrls = await Future.wait(
        _galleryFiles.map((f) => _uploadImage(f, 'attractions/gallery')),
      );
      final galleryUrls = [..._existingGalleryUrls, ...newGalleryUrls];

      String? videoUrl = _existingVideoUrl;
      if (_videoFile != null) {
        videoUrl = await _uploadVideo(_videoFile!);
      }

      final cityName = cityMap[_selectedCityId!]?['en'] ?? _selectedCityId!;

      final data = <String, dynamic>{
        'name': {
          'ar': _nameArController.text.trim(),
          'en': _nameEnController.text.trim(),
        },
        'description': {
          'ar': _descArController.text.trim(),
          'en': _descEnController.text.trim(),
        },
        'category': _selectedCategory,
        'categoryColorCode': _categoryColorCode,
        'region': _selectedRegionId,
        'city': cityName,
        'address': _addressController.text.trim(),
        'coordinates': GeoPoint(
          double.parse(latText),
          double.parse(lngText),
        ),
        'mainImage': mainImageUrl,
        'gallery': galleryUrls,
        'isAlwaysOpen': _isAlwaysOpen,
        'openingHours': _isAlwaysOpen
            ? <String, String>{}
            : {
                'ar': _hoursArController.text.trim(),
                'en': _hoursEnController.text.trim(),
              },
        'entryFee': double.tryParse(_feeController.text.trim()) ?? 0.0,
        'ticketBookingUrl': _ticketUrlController.text.trim().isEmpty
            ? null
            : _ticketUrlController.text.trim(),
        'videoUrl': videoUrl,
      };

      if (_isEditing) {
        await ref
            .read(adminRepositoryProvider)
            .updateAttraction(widget.editAttraction!.id, data);
        if (mounted) {
          _showSnackBar('Attraction updated!');
          Navigator.pop(context);
        }
      } else {
        await ref.read(adminRepositoryProvider).addAttraction(data);
        if (mounted) {
          _showSnackBar('Attraction added! AI tagging will run shortly.');
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    for (final c in [
      _nameArController,
      _nameEnController,
      _descArController,
      _descEnController,
      _addressController,
      _latController,
      _lngController,
      _hoursArController,
      _hoursEnController,
      _ticketUrlController,
    ]) {
      c.clear();
    }
    _feeController.text = '0';
    setState(() {
      _selectedCategory = 'Heritage';
      _categoryColorCode = _categoryDefaultColors['Heritage']!;
      _selectedRegionId = null;
      _selectedCityId = null;
      _mainImageFile = null;
      _existingMainImageUrl = null;
      _galleryFiles = [];
      _existingGalleryUrls = [];
      _videoFile = null;
      _existingVideoUrl = null;
      _isAlwaysOpen = false;
    });
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Attraction' : 'Add Attraction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main Image ─────────────────────────────────────────────
              _SectionHeader('Main Image *'),
              _ImagePickerTile(
                file: _mainImageFile,
                existingUrl: _existingMainImageUrl,
                onTap: _pickMainImage,
              ),

              const SizedBox(height: 24),

              // ── Identity ───────────────────────────────────────────────
              _SectionHeader('Name & Description'),
              _FormField(
                controller: _nameArController,
                hint: 'الاسم بالعربي',
                label: 'Name (Arabic)',
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _nameEnController,
                hint: 'Enter attraction name in English',
                label: 'Name (English)',
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _descArController,
                hint: 'الوصف بالعربي',
                label: 'Description (Arabic)',
                maxLines: 4,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _descEnController,
                hint: 'Enter description in English',
                label: 'Description (English)',
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // ── Classification ─────────────────────────────────────────
              _SectionHeader('Classification'),
              _Label('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _selectedCategory = v;
                    _categoryColorCode = _categoryDefaultColors[v]!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // ── Location ───────────────────────────────────────────────
              _SectionHeader('Location'),
              _Label('Region *'),
              DropdownButtonFormField<String>(
                value: _selectedRegionId,
                decoration: _inputDecoration(hint: 'Select a region'),
                items: regionsData
                    .map((r) => DropdownMenuItem(
                        value: r.regionId, child: Text(r.nameEn)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedRegionId = v;
                  _selectedCityId = null;
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _Label('City *'),
              DropdownButtonFormField<String>(
                value: _selectedCityId,
                decoration: _inputDecoration(
                  hint: _selectedRegionId == null
                      ? 'Select a region first'
                      : 'Select a city',
                ),
                items: _availableCities
                    .map((cityId) => DropdownMenuItem(
                          value: cityId,
                          child: Text(cityMap[cityId]?['en'] ?? cityId),
                        ))
                    .toList(),
                onChanged: _selectedRegionId == null
                    ? null
                    : (v) => setState(() => _selectedCityId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _addressController,
                hint: 'Full address',
                label: 'Address',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: _inputDecoration(hint: 'Latitude'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: _inputDecoration(hint: 'Longitude'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Hours & Fees ───────────────────────────────────────────
              _SectionHeader('Opening Hours & Entry Fee'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Always Open (24/7)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isAlwaysOpen,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _isAlwaysOpen = v),
              ),
              if (!_isAlwaysOpen) ...[
                const SizedBox(height: 8),
                _FormField(
                  controller: _hoursArController,
                  hint: 'مثال: 9 صباحاً – 10 مساءً',
                  label: 'Opening Hours (Arabic)',
                  textDirection: TextDirection.rtl,
                  required: false,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _hoursEnController,
                  hint: 'e.g. 9 AM – 10 PM',
                  label: 'Opening Hours (English)',
                  required: false,
                ),
              ],
              const SizedBox(height: 12),
              _FormField(
                controller: _feeController,
                hint: '0 = Free',
                label: 'Entry Fee (SAR) — 0 means free',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (double.tryParse(v?.trim() ?? '') == null)
                        ? 'Enter a valid number'
                        : null,
              ),

              const SizedBox(height: 24),

              // ── Gallery Images ─────────────────────────────────────────
              _SectionHeader('Gallery Images'),
              _buildGallerySection(theme),

              const SizedBox(height: 24),

              // ── Video ──────────────────────────────────────────────────
              _SectionHeader('Video (Optional)'),
              _VideoPickerTile(
                file: _videoFile,
                existingUrl: _existingVideoUrl,
                onTap: _pickVideo,
                onRemove: () => setState(() {
                  _videoFile = null;
                  _existingVideoUrl = null;
                }),
              ),

              const SizedBox(height: 24),

              // ── Optional ───────────────────────────────────────────────
              _SectionHeader('Optional'),
              _FormField(
                controller: _ticketUrlController,
                hint: 'https://tickets.example.com',
                label: 'Ticket Booking URL',
                keyboardType: TextInputType.url,
                required: false,
              ),

              const SizedBox(height: 32),

              // ── Submit ─────────────────────────────────────────────────
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
                          _isEditing ? 'Update Attraction' : 'Add Attraction',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_existingGalleryUrls.isEmpty && _galleryFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No gallery images added yet.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < _existingGalleryUrls.length; i++)
              _GalleryNetworkTile(
                url: _existingGalleryUrls[i],
                onRemove: () =>
                    setState(() => _existingGalleryUrls.removeAt(i)),
              ),
            for (int i = 0; i < _galleryFiles.length; i++)
              _GalleryFileTile(
                file: _galleryFiles[i],
                onRemove: () => setState(() => _galleryFiles.removeAt(i)),
              ),
            if (_totalGalleryCount < 8) _AddGalleryTile(onTap: _addGalleryImage),
          ],
        ),
        if (_totalGalleryCount >= 8)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Maximum 8 images reached.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
            ),
          ),
      ],
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700]),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final int maxLines;
  final TextDirection textDirection;
  final TextInputType? keyboardType;
  final bool required;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.label,
    this.maxLines = 1,
    this.textDirection = TextDirection.ltr,
    this.keyboardType,
    this.required = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textDirection: textDirection,
          keyboardType: keyboardType,
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required'
                      : null
                  : null),
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
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final File? file;
  final String? existingUrl;
  final VoidCallback onTap;

  const _ImagePickerTile({
    required this.file,
    this.existingUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = file != null || existingUrl != null;

    return GestureDetector(
      onTap: onTap,
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
        clipBehavior: Clip.antiAlias,
        child: hasContent
            ? Stack(
                fit: StackFit.expand,
                children: [
                  file != null
                      ? Image.file(file!, fit: BoxFit.cover)
                      : Image.network(
                          existingUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image_outlined,
                                size: 36),
                          ),
                        ),
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
                      child: const Text('Tap to change',
                          style:
                              TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to pick main image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _VideoPickerTile extends StatelessWidget {
  final File? file;
  final String? existingUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _VideoPickerTile({
    required this.file,
    this.existingUrl,
    required this.onTap,
    required this.onRemove,
  });

  bool get _hasVideo => file != null || existingUrl != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _hasVideo
              ? Colors.grey.shade900
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hasVideo
                ? Colors.grey.shade700
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _hasVideo ? _buildContent() : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildContent() {
    final label = file != null
        ? (file!.path.split('/').last.split('\\').last)
        : 'Video saved';

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 48, color: Colors.white70),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Tap to change',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.videocam_outlined,
            size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        Text(
          'Tap to pick a video',
          style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.6), fontSize: 13),
        ),
      ],
    );
  }
}

class _GalleryNetworkTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _GalleryNetworkTile({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child:
                    const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryFileTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _GalleryFileTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              file,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child:
                    const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddGalleryTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddGalleryTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 28,
                color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
