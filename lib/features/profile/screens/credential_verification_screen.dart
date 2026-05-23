import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/profile/logic/profile_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CredentialVerificationScreen extends ConsumerStatefulWidget {
  const CredentialVerificationScreen({super.key});

  @override
  ConsumerState<CredentialVerificationScreen> createState() =>
      _CredentialVerificationScreenState();
}

class _CredentialVerificationScreenState
    extends ConsumerState<CredentialVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Individual fields
  final _licenceNumber = TextEditingController();
  DateTime? _licenceExpiryDate;

  // Company fields
  final _companyName = TextEditingController();
  final _commercialReg = TextEditingController();
  DateTime? _commercialRegExpiry;
  final _tourismLicenceNumber = TextEditingController();
  DateTime? _tourismLicenceExpiry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillFromExistingData();
  }

  bool _prefilled = false;
  void _prefillFromExistingData() {
    if (_prefilled) return;
    final user = ref.read(authNotifierProvider).value;
    if (user is! TutorModel) return;
    _prefilled = true;

    if (user.tutorType == TutorType.individual) {
      if (user.licenceNumber != null) _licenceNumber.text = user.licenceNumber!;
      if (user.licenceExpiryDate != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _licenceExpiryDate = user.licenceExpiryDate),
        );
      }
    } else {
      if (user.companyName != null) _companyName.text = user.companyName!;
      if (user.commercialRegistration != null) {
        _commercialReg.text = user.commercialRegistration!;
      }
      if (user.tourismLicenceNumber != null) {
        _tourismLicenceNumber.text = user.tourismLicenceNumber!;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _commercialRegExpiry = user.commercialRegExpiryDate;
            _tourismLicenceExpiry = user.tourismLicenceExpiryDate;
          }));
    }
  }

  @override
  void dispose() {
    _licenceNumber.dispose();
    _companyName.dispose();
    _commercialReg.dispose();
    _tourismLicenceNumber.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit(TutorModel tutor, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data;

    if (tutor.tutorType == TutorType.individual) {
      if (_licenceExpiryDate == null) {
        _showError(l10n.credVerifPickLicenceExpiry);
        return;
      }
      data = {
        'licenceNumber': _licenceNumber.text.trim(),
        'licenceExpiryDate': Timestamp.fromDate(_licenceExpiryDate!),
      };
    } else {
      if (_commercialRegExpiry == null || _tourismLicenceExpiry == null) {
        _showError(l10n.credVerifPickAllExpiry);
        return;
      }
      data = {
        'companyName': _companyName.text.trim(),
        'commercialRegistration': _commercialReg.text.trim(),
        'commercialRegExpiryDate': Timestamp.fromDate(_commercialRegExpiry!),
        'tourismLicenceNumber': _tourismLicenceNumber.text.trim(),
        'tourismLicenceExpiryDate': Timestamp.fromDate(_tourismLicenceExpiry!),
      };
    }

    await ref.read(profileNotifierProvider.notifier).submitCredentials(data);

    if (!mounted) return;
    final state = ref.read(profileNotifierProvider);
    if (state is AsyncError) {
      _showError(l10n.commonErrorWithMessage(''));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.credVerifSuccess),
          backgroundColor: Theme.of(context).semanticSuccess,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    final authState = ref.watch(authNotifierProvider);
    final notifierState = ref.watch(profileNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return authState.when(
      data: (user) {
        if (user == null || user is! TutorModel) {
          return const Scaffold(body: Center(child: Text('Not a tutor account')));
        }
        if (user.verificationStatus == VerificationStatus.verified) {
          return _buildVerifiedScaffold(context, l10n);
        }
        if (user.verificationStatus == VerificationStatus.pending) {
          return _buildPendingReviewScaffold(context, l10n);
        }
        if (!user.phoneVerified) {
          return _buildPhoneNotVerifiedScaffold(context, l10n);
        }
        final isIndividual = user.tutorType == TutorType.individual;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.credVerifTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.verificationStatus == VerificationStatus.rejected &&
                      user.rejectionReason != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isHighContrast
                            ? Colors.white
                            : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHighContrast
                              ? theme.colorScheme.onSurface
                              : Colors.red.withValues(alpha: 0.3),
                          width: isHighContrast ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.credVerifRejectionTitle,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.rejectionReason!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionHeader(
                    theme,
                    isIndividual
                        ? l10n.credVerifIndividualLicence
                        : l10n.credVerifCompanyDetails,
                    isIndividual ? Icons.person_outlined : Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),
                  if (isIndividual) ...[
                    _buildTextField(
                      controller: _licenceNumber,
                      label: l10n.credVerifLicenceNumber,
                      icon: Icons.badge_outlined,
                      requiredMsg: l10n.credVerifRequired,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: l10n.credVerifLicenceExpiry,
                      value: _licenceExpiryDate,
                      icon: Icons.calendar_today_outlined,
                      placeholder: l10n.credVerifPickDate,
                      onTap: () => _pickDate(
                        current: _licenceExpiryDate,
                        onPicked: (d) => setState(() => _licenceExpiryDate = d),
                      ),
                      theme: theme,
                    ),
                  ] else ...[
                    _buildTextField(
                      controller: _companyName,
                      label: l10n.credVerifCompanyName,
                      icon: Icons.business_outlined,
                      requiredMsg: l10n.credVerifRequired,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _commercialReg,
                      label: l10n.credVerifCommercialReg,
                      icon: Icons.receipt_long_outlined,
                      requiredMsg: l10n.credVerifRequired,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: l10n.credVerifCommercialRegExpiry,
                      value: _commercialRegExpiry,
                      icon: Icons.calendar_today_outlined,
                      placeholder: l10n.credVerifPickDate,
                      onTap: () => _pickDate(
                        current: _commercialRegExpiry,
                        onPicked: (d) => setState(() => _commercialRegExpiry = d),
                      ),
                      theme: theme,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      theme,
                      l10n.credVerifTourismLicenceSection,
                      Icons.tour_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tourismLicenceNumber,
                      label: l10n.credVerifTourismLicenceNumber,
                      icon: Icons.badge_outlined,
                      requiredMsg: l10n.credVerifRequired,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: l10n.credVerifTourismLicenceExpiry,
                      value: _tourismLicenceExpiry,
                      icon: Icons.calendar_today_outlined,
                      placeholder: l10n.credVerifPickDate,
                      onTap: () => _pickDate(
                        current: _tourismLicenceExpiry,
                        onPicked: (d) => setState(() => _tourismLicenceExpiry = d),
                      ),
                      theme: theme,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(user, l10n),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.credVerifSubmit,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.credVerifReviewNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isHighContrast
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(l10n.commonErrorWithMessage('')))),
    );
  }

  Widget _buildVerifiedScaffold(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.credVerifTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isHighContrast
                      ? Colors.white
                      : Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_outlined,
                  size: 56,
                  color: isHighContrast ? theme.colorScheme.primary : Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.credVerifVerifiedTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.credVerifVerifiedBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isHighContrast
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingReviewScaffold(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.credVerifTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isHighContrast
                      ? Colors.white
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_outlined,
                  size: 56,
                  color: isHighContrast ? theme.colorScheme.primary : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.credVerifPendingTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.credVerifPendingBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isHighContrast
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNotVerifiedScaffold(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isHighContrast = theme.isHighContrast;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.credVerifTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isHighContrast
                      ? Colors.white
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_locked_outlined,
                  size: 56,
                  color: isHighContrast ? theme.colorScheme.primary : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.credVerifPhoneNotVerifiedTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.credVerifPhoneNotVerifiedBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isHighContrast
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String requiredMsg,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? requiredMsg : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required String placeholder,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final formatted = value != null
        ? DateFormat('yyyy-MM-dd').format(value)
        : placeholder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          formatted,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value == null
                ? theme.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
      ),
    );
  }
}
