import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/trip_management/logic/trip_management_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key, this.initialTrip});

  /// When non-null, the screen operates in "edit" mode.
  final TripModel? initialTrip;

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleAr = TextEditingController();
  final _titleEn = TextEditingController();
  final _shortDescAr = TextEditingController();
  final _shortDescEn = TextEditingController();
  final _descAr = TextEditingController();
  final _descEn = TextEditingController();
  final _adultPrice = TextEditingController();
  final _childPrice = TextEditingController();
  final _maxCapacity = TextEditingController();
  final _tripDurationDays = TextEditingController();

  Map<String, String>? _selectedCity;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _allowsKids = false;
  bool _isMultiDayTrip = false;
  String _tripType = 'shared';
  File? _pickedImage;
  String? _existingImageUrl;
  bool _isSubmitting = false;
  final Set<String> _accessibilityFeatures = {};
  final Set<String> _tripLanguages = {};
  bool _didApplyDefaultDescriptionTemplate = false;

  bool get _isEditing => widget.initialTrip != null;

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

  static const _languageOptions = [
    'ar', 'en', 'fr', 'es', 'de', 'tr', 'ur', 'zh'
  ];

  static const _accessibilityOptions = [
    (key: 'wheelchair', icon: Icons.accessible),
    (key: 'family', icon: Icons.family_restroom),
  ];

  @override
  void initState() {
    super.initState();
    final trip = widget.initialTrip;
    if (trip == null) return;

    _titleAr.text = trip.titleAr;
    _titleEn.text = trip.titleEn;
    _shortDescAr.text = trip.shortDescriptionAr;
    _shortDescEn.text = trip.shortDescriptionEn;
    _descAr.text = trip.descriptionAr;
    _descEn.text = trip.descriptionEn;
    _adultPrice.text =
        trip.adultPrice > 0 ? trip.adultPrice.toInt().toString() : '';
    _childPrice.text =
        trip.childPrice > 0 ? trip.childPrice.toInt().toString() : '';
    _maxCapacity.text = trip.maxCapacity?.toString() ?? '';
    _allowsKids = trip.allowsKids;
    _isMultiDayTrip = (trip.tripDurationDays ?? 0) > 1;
    if (_isMultiDayTrip) _tripDurationDays.text = trip.tripDurationDays.toString();
    _existingImageUrl = trip.imageUrl.isNotEmpty ? trip.imageUrl : null;
    _startTime = _parseTimeStr(trip.startTime);
    _endTime = _parseTimeStr(trip.endTime);
    _startDate = trip.startDate;
    _endDate = trip.endDate;
    _tripType = trip.tripType;
    _accessibilityFeatures.addAll(trip.accessibilityFeatures);
    _tripLanguages.addAll(trip.tripLanguages ?? []);
    _selectedCity = _saudiCities.firstWhere(
      (c) => c['ar'] == trip.cityAr || c['en'] == trip.cityEn,
      orElse: () => {'ar': trip.cityAr, 'en': trip.cityEn},
    );
  }

  TimeOfDay? _parseTimeStr(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

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
    _maxCapacity.dispose();
    _tripDurationDays.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) => t.format(context);
  String _fmtTimeStr(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _pickTime({required bool isStart}) async {
    final l10n = AppLocalizations.of(context);
    final current = isStart ? _startTime : _endTime;
    final initial = current ??
        (isStart
            ? const TimeOfDay(hour: 8, minute: 0)
            : const TimeOfDay(hour: 18, minute: 0));

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
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.45,
            minHeight: 280,
          ),
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
                      isStart ? l10n.addTripStartTime : l10n.addTripEndTime,
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

  Future<void> _submit(TutorModel tutor) async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null && _existingImageUrl == null) {
      _snack(l10n.addTripImageRequired, isError: true);
      return;
    }
    if (_startTime == null || _endTime == null) {
      _snack(l10n.addTripDailyTimesRequired, isError: true);
      return;
    }
    if (_startDate == null || _endDate == null) {
      _snack(l10n.addTripAvailabilityDatesRequired, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final imageUrl = _pickedImage != null
          ? await _uploadImage(_pickedImage!)
          : _existingImageUrl!;

      final tripId =
          _isEditing ? widget.initialTrip!.id : const Uuid().v4();
      final adultPrice = double.tryParse(_adultPrice.text.trim()) ?? 0.0;
      final childPrice = _allowsKids
          ? (double.tryParse(_childPrice.text.trim()) ?? 0.0)
          : 0.0;

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
        allowsKids: _allowsKids,
        maxCapacity: int.tryParse(_maxCapacity.text.trim()),
        tripDurationDays: _isMultiDayTrip
            ? int.tryParse(_tripDurationDays.text.trim())
            : null,
        imageUrl: imageUrl,
        guide: tutor.fullName,
        company: tutor.companyName ?? '',
        license: tutor.licenceNumber ?? tutor.tourismLicenceNumber ?? '',
        tutorId: tutor.uId,
        tutorType: tutor.tutorType?.name ?? 'individual',
        accessibilityFeatures: _accessibilityFeatures.toList(),
        tripLanguages:
            _tripLanguages.isEmpty ? null : _tripLanguages.toList(),
        guideBio: tutor.bio,
        guideLanguages: tutor.languages,
        guideRating: tutor.rating,
        guideReviewsCount: tutor.reviewsCount,
        tripType: _tripType,
        status: 'pending',
        startTime: _fmtTimeStr(_startTime!),
        endTime: _fmtTimeStr(_endTime!),
        startDate: _startDate,
        endDate: _endDate,
      );

      if (_isEditing) {
        await ref
            .read(tripManagementRepositoryProvider)
            .updateTrip(trip);
      } else {
        await ref
            .read(tripManagementRepositoryProvider)
            .submitTrip(trip);
      }

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? l10n.addTripUpdatedSuccess
              : l10n.addTripSubmittedSuccess),
          backgroundColor: Theme.of(context).semanticSuccess,
          duration: const Duration(seconds: 4),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.commonErrorWithMessage('')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String> _uploadImage(File file) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('trip_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await storageRef.putFile(file);
    return await task.ref.getDownloadURL();
  }

  void _snack(String msg, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? theme.colorScheme.error : theme.semanticSuccess,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(authNotifierProvider).value;
    final tutor = currentUser is TutorModel ? currentUser : null;

    if (tutor != null && tutor.isCredentialExpired) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addTripTitle)),
        body: _BlockedView(
          theme: theme,
          icon: Icons.lock_outline,
          color: Colors.red,
          title: l10n.addTripCredentialExpiredTitle,
          body: l10n.addTripCredentialExpiredBody,
          onBack: () => Navigator.of(context).pop(),
        ),
      );
    }

    if (tutor != null &&
        tutor.verificationStatus != VerificationStatus.verified) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addTripTitle)),
        body: _BlockedView(
          theme: theme,
          icon: Icons.verified_outlined,
          color: Colors.orange,
          title: l10n.addTripAccountUnverifiedTitle,
          body: l10n.addTripAccountUnverifiedBody,
          onBack: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isEditing ? l10n.addTripEditTitle : l10n.addTripNewTitle)),
      body: Theme(
        data: Theme.of(context).copyWith(
          checkboxTheme: CheckboxThemeData(
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.55),
              width: 1.8,
            ),
          ),
          inputDecorationTheme:
              Theme.of(context).inputDecorationTheme.copyWith(
                    labelStyle: Theme.of(context).textTheme.bodyLarge,
                    floatingLabelStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.35),
                        width: 1.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.35),
                        width: 1.8,
                      ),
                    ),
                  ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (tutor != null && tutor.isCredentialExpiringSoon)
                _WarningBanner(
                  theme: theme,
                  message: l10n.addTripLicenseExpiringSoonWarning,
                ),
              _buildImagePicker(theme),
              const SizedBox(height: 24),
              _SectionHeader(theme: theme, title: l10n.addTripTypeSection),
              const SizedBox(height: 12),
              _buildTripTypeSection(theme, l10n),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme,
                  title: l10n.addTripTimingDurationSection),
              const SizedBox(height: 12),
              _buildAvailabilitySection(theme),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme, title: l10n.addTripTitleSection),
              const SizedBox(height: 12),
              _buildTitlesSection(),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme,
                  title: l10n.addTripShortDescriptionSection),
              const SizedBox(height: 12),
              _buildShortDescSection(),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme,
                  title: l10n.addTripDetailedDescriptionSection),
              const SizedBox(height: 8),
              _buildDetailedDescSection(theme),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme, title: l10n.addTripLocationSection),
              const SizedBox(height: 12),
              _buildCitySection(),
              const SizedBox(height: 20),
              _SectionHeader(
                theme: theme,
                title: l10n.addTripPricingCapacitySection,
                trailing: SvgPicture.asset(
                  'assets/icons/saudi_riyal.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPricingSection(theme),
              const SizedBox(height: 20),
              _SectionHeader(
                  theme: theme, title: l10n.accessibility),
              const SizedBox(height: 8),
              _buildAccessibilitySection(theme),
              if (tutor != null &&
                  tutor.tutorType == TutorType.company) ...[
                const SizedBox(height: 20),
                _SectionHeader(
                    theme: theme,
                    title: l10n.addTripTripLanguagesSection),
                const SizedBox(height: 8),
                _buildLanguagesSection(theme),
              ],
              if (tutor != null) ...[
                const SizedBox(height: 20),
                _SectionHeader(
                    theme: theme, title: l10n.guide_info_autofilled),
                const SizedBox(height: 8),
                _buildGuideInfo(theme, tutor),
              ],
              const SizedBox(height: 20),
              _buildSubmitButton(theme, tutor),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final hasNewImage = _pickedImage != null;
    final hasExisting = _existingImageUrl != null;

    DecorationImage? decorationImage;
    if (hasNewImage) {
      decorationImage = DecorationImage(
          image: FileImage(_pickedImage!), fit: BoxFit.cover);
    } else if (hasExisting) {
      decorationImage = DecorationImage(
          image: CachedNetworkImageProvider(_existingImageUrl!),
          fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(minHeight: 150, maxHeight: 220),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      theme.colorScheme.primary.withValues(alpha: 0.3)),
              image: decorationImage,
            ),
            child: (!hasNewImage && !hasExisting)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.6)),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addTripImagePrompt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7)),
                      ),
                    ],
                  )
                : null,
          ),
          if (hasNewImage || hasExisting)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      l10n.addTripChangeImage,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripTypeSection(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: ['shared', 'private'].map((type) {
        final selected = _tripType == type;
        final label = type == 'shared'
            ? l10n.addTripTypeShared
            : l10n.addTripTypePrivate;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tripType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsetsDirectional.only(
                  end: type == 'shared' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.35),
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
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

  Widget _buildAvailabilitySection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final String dateLabel;
    if (_startDate != null && _endDate != null) {
      final s =
          '${_startDate!.year}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.day.toString().padLeft(2, '0')}';
      final e =
          '${_endDate!.year}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.day.toString().padLeft(2, '0')}';
      dateLabel = '$s – $e';
    } else {
      dateLabel = l10n.addTripPickAvailabilityPeriod;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickDateRange,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.addTripAvailabilityPeriod,
              prefixIcon: const Icon(Icons.date_range_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              dateLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _startDate == null
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _timePicker(theme, isStart: true)),
            const SizedBox(width: 12),
            Expanded(child: _timePicker(theme, isStart: false)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l10n.addTripDailyStartEndHint,
              style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _isMultiDayTrip,
          onChanged: (v) => setState(() {
            _isMultiDayTrip = v ?? false;
            if (!_isMultiDayTrip) _tripDurationDays.clear();
          }),
          secondary: Icon(Icons.hotel_outlined,
              color: theme.colorScheme.primary),
          title: Text(l10n.addTripMultiDayTitle,
              style: theme.textTheme.bodyLarge),
          subtitle: Text(l10n.addTripMultiDaySubtitle,
              style: theme.textTheme.bodyMedium),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        if (_isMultiDayTrip) ...[
          const SizedBox(height: 8),
          _field(
            _tripDurationDays,
            l10n.addTripDurationDaysLabel,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3)
            ],
            extraValidator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 2) return l10n.addTripDurationDaysMinError;
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _timePicker(ThemeData theme, {required bool isStart}) {
    final l10n = AppLocalizations.of(context);
    final val = isStart ? _startTime : _endTime;
    return InkWell(
      onTap: () => _pickTime(isStart: isStart),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStart ? l10n.addTripStartTime : l10n.addTripEndTime,
          prefixIcon: Icon(isStart
              ? Icons.schedule_outlined
              : Icons.timer_off_outlined),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          val != null ? _fmtTime(val) : '--:--',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: val == null
                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTitlesSection() {
    final l10n = AppLocalizations.of(context);
    return Column(children: [
      _field(_titleAr, l10n.addTripTitleArLabel, required: true),
      const SizedBox(height: 12),
      _field(_titleEn, l10n.addTripTitleEnLabel, required: true),
    ]);
  }

  Widget _buildShortDescSection() {
    final l10n = AppLocalizations.of(context);
    return Column(children: [
      _field(_shortDescAr, l10n.addTripShortDescArLabel, required: true),
      const SizedBox(height: 12),
      _field(_shortDescEn, l10n.addTripShortDescEnLabel, required: true),
    ]);
  }

  Widget _buildDetailedDescSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.description_template_hint,
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        _field(_descAr, l10n.addTripDescArLabel,
            required: true, maxLines: 8),
        const SizedBox(height: 12),
        _field(_descEn, l10n.addTripDescEnLabel,
            required: true, maxLines: 8),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyDefaultDescriptionTemplate || widget.initialTrip != null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    _descAr.text = l10n.addTripDescTemplateAr;
    _descEn.text = l10n.addTripDescTemplateEn;
    _didApplyDefaultDescriptionTemplate = true;
  }

  Widget _buildCitySection() {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<Map<String, String>>(
      initialValue: _selectedCity,
      decoration: InputDecoration(
        labelText: l10n.addTripCity,
        prefixIcon: const Icon(Icons.location_city_outlined),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _saudiCities.map((city) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        return DropdownMenuItem(
          value: city,
          child: Text(isAr ? city['ar']! : city['en']!),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCity = val),
      validator: (v) => v == null ? l10n.addTripCityRequired : null,
    );
  }

  Widget _buildPricingSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          _adultPrice,
          l10n.addTripAdultPriceLabel,
          required: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            _DecimalInputFormatter(),
            LengthLimitingTextInputFormatter(8)
          ],
          extraValidator: (v) => double.tryParse(v ?? '') == null
              ? l10n.addTripValidNumberError
              : null,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _allowsKids,
          onChanged: (v) => setState(() {
            _allowsKids = v ?? false;
            if (!_allowsKids) _childPrice.clear();
          }),
          secondary: Icon(Icons.child_friendly_outlined,
              color: theme.colorScheme.primary),
          title: Text(l10n.addTripAllowsChildren,
              style: theme.textTheme.bodyLarge),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        if (_allowsKids) ...[
          const SizedBox(height: 8),
          _field(
            _childPrice,
            l10n.addTripChildPriceLabel,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              _DecimalInputFormatter(),
              LengthLimitingTextInputFormatter(8)
            ],
            extraValidator: (v) {
              if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                return l10n.addTripValidNumberError;
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l10n.addTripChildrenCapacityNote,
                style: theme.textTheme.bodyMedium),
          ),
        ],
        const SizedBox(height: 12),
        _field(
          _maxCapacity,
          l10n.addTripMaxCapacityLabel,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4)
          ],
          extraValidator: (v) {
            if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
              return l10n.addTripValidIntegerError;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: _accessibilityOptions
          .map((opt) => CheckboxListTile(
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
                secondary:
                    Icon(opt.icon, color: theme.colorScheme.primary),
                title: Text(_accessibilityLabel(l10n, opt.key),
                    style: theme.textTheme.bodyLarge),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ))
          .toList(),
    );
  }

  Widget _buildLanguagesSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _languageOptions.map((lang) {
        final selected = _tripLanguages.contains(lang);
        return FilterChip(
          label: Text(_languageLabel(l10n, lang)),
          selected: selected,
          onSelected: (on) => setState(() {
            if (on) {
              _tripLanguages.add(lang);
            } else {
              _tripLanguages.remove(lang);
            }
          }),
          selectedColor:
              theme.colorScheme.primary.withValues(alpha: 0.15),
          checkmarkColor: theme.colorScheme.primary,
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.35),
            width: selected ? 1.8 : 1.2,
          ),
          labelStyle: TextStyle(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  String _accessibilityLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'wheelchair':
        return l10n.accessibility_wheelchair;
      case 'family':
        return l10n.accessibility_family;
      default:
        return key;
    }
  }

  String _languageLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'ar':
        return l10n.arabic;
      case 'en':
        return l10n.english;
      case 'fr':
        return l10n.french;
      case 'es':
        return l10n.spanish;
      case 'de':
        return l10n.german;
      case 'tr':
        return l10n.turkish;
      case 'ur':
        return l10n.urdu;
      case 'zh':
        return l10n.chinese;
      default:
        return key;
    }
  }

  Widget _buildGuideInfo(ThemeData theme, TutorModel tutor) {
    final l10n = AppLocalizations.of(context);
    const dash = '-';
    return Column(
      children: tutor.tutorType == TutorType.individual
          ? [
              _infoRow(theme, Icons.person_outline,
                  l10n.addTripGuideName(tutor.fullName)),
              _infoRow(theme, Icons.verified_outlined,
                  l10n.addTripLicenseValue(tutor.licenceNumber ?? dash)),
            ]
          : [
              _infoRow(theme, Icons.business_outlined,
                  l10n.addTripCompanyName(tutor.companyName ?? dash)),
              _infoRow(
                  theme,
                  Icons.verified_outlined,
                  l10n.addTripTourismLicenseValue(
                      tutor.tourismLicenceNumber ?? dash)),
            ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, TutorModel? tutor) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: ElevatedButton(
          onPressed:
              (_isSubmitting || tutor == null) ? null : () => _submit(tutor),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isEditing
                      ? l10n.addTripSaveChanges
                      : l10n.addTripSubmitForReview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return AppLocalizations.of(context).addTripRequiredField;
        }
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
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.theme, required this.title, this.trailing});

  final ThemeData theme;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Text(title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ));
    if (trailing == null) return text;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      text,
      const SizedBox(width: 6),
      trailing!,
    ]);
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.theme, required this.message});

  final ThemeData theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Colors.orange, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _BlockedView extends StatelessWidget {
  const _BlockedView({
    required this.theme,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onBack,
  });

  final ThemeData theme;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(body,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6)),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onBack,
              child: Text(l10n.addTripBackToProfile),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    return newValue;
  }
}
