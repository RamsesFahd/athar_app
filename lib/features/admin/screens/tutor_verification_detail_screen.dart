import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TutorVerificationDetailScreen extends ConsumerStatefulWidget {
  final TutorModel tutor;
  const TutorVerificationDetailScreen({super.key, required this.tutor});

  @override
  ConsumerState<TutorVerificationDetailScreen> createState() =>
      _TutorVerificationDetailScreenState();
}

class _TutorVerificationDetailScreenState
    extends ConsumerState<TutorVerificationDetailScreen> {
  bool _isLoading = false;

  TutorModel get tutor => widget.tutor;

  // ── Approve ──────────────────────────────────────────────────────────────────

  Future<void> _showApproveDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminVerifyGuideTitle),
        content: Text(l10n.adminVerifyGuideConfirm(tutor.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminVerifyGuide),
          ),
        ],
      ),
    );
    if (confirmed == true) await _approve();
  }

  Future<void> _approve() async {
    final admin = ref.read(authNotifierProvider).value;
    if (admin == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).approveTutor(
            tutor.uId,
            adminId: admin.uId,
            adminName: admin.fullName,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).adminGuideVerifiedSuccess),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commonErrorWithMessage('')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Reject ───────────────────────────────────────────────────────────────────

  Future<void> _showRejectSheet() async {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adminRejectionReason,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.adminRejectRequestHelp,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.adminRejectRequestHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setSheetState(() {}),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: reasonController.text.trim().isEmpty
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _reject(reasonController.text.trim());
                        },
                  child: Text(l10n.adminReject),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reject(String reason) async {
    final admin = ref.read(authNotifierProvider).value;
    if (admin == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).rejectTutor(
            tutor.uId,
            adminId: admin.uId,
            adminName: admin.fullName,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).adminRequestRejected),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commonErrorWithMessage('')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isIndividual = tutor.tutorType == TutorType.individual;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminReviewVerification),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTutorHeader(theme),
                  const SizedBox(height: 20),
                  _buildCredentialCard(theme, isIndividual),
                  if (tutor.verificationStatus != VerificationStatus.pending &&
                      tutor.verifiedByAdminName != null) ...[
                    const SizedBox(height: 16),
                    _buildDecisionCard(theme),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildTutorHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: tutor.profileImage != null
              ? NetworkImage(tutor.profileImage!)
              : null,
          child: tutor.profileImage == null
              ? Text(
                  tutor.fullName.isNotEmpty ? tutor.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tutor.fullName,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(tutor.email, style: theme.textTheme.bodySmall),
              if (tutor.phoneNumber != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                    const SizedBox(width: 4),
                    Text(tutor.phoneNumber!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55))),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              _typeBadge(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeBadge(ThemeData theme) {
    final isIndividual = tutor.tutorType == TutorType.individual;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isIndividual ? theme.colorScheme.primary : Colors.indigo)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isIndividual ? l10n.adminGuideTypeIndividual : l10n.adminGuideTypeCompany,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isIndividual ? theme.colorScheme.primary : Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildCredentialCard(ThemeData theme, bool isIndividual) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIndividual ? l10n.adminLicenseData : l10n.adminCompanyData,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          if (isIndividual) ...[
            _credentialRow(
              theme,
              icon: Icons.badge_outlined,
              label: l10n.adminLicenseNumber,
              value: tutor.licenceNumber,
            ),
            const SizedBox(height: 14),
            _credentialRow(
              theme,
              icon: Icons.calendar_today_outlined,
              label: l10n.adminLicenseExpiry,
              value: _formatDate(tutor.licenceExpiryDate),
              expiryDate: tutor.licenceExpiryDate,
            ),
          ] else ...[
            _credentialRow(
              theme,
              icon: Icons.business_outlined,
              label: l10n.adminCompanyName,
              value: tutor.companyName,
            ),
            const SizedBox(height: 14),
            _credentialRow(
              theme,
              icon: Icons.receipt_long_outlined,
              label: l10n.adminCommercialRegistration,
              value: tutor.commercialRegistration,
            ),
            const SizedBox(height: 14),
            _credentialRow(
              theme,
              icon: Icons.calendar_today_outlined,
              label: l10n.adminCommercialRegistrationExpiry,
              value: _formatDate(tutor.commercialRegExpiryDate),
              expiryDate: tutor.commercialRegExpiryDate,
            ),
            const Divider(height: 24),
            Text(
              l10n.adminTourismActivityLicense,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _credentialRow(
              theme,
              icon: Icons.tour_outlined,
              label: l10n.adminTourismLicenseNumber,
              value: tutor.tourismLicenceNumber,
            ),
            const SizedBox(height: 14),
            _credentialRow(
              theme,
              icon: Icons.calendar_today_outlined,
              label: l10n.adminTourismLicenseExpiry,
              value: _formatDate(tutor.tourismLicenceExpiryDate),
              expiryDate: tutor.tourismLicenceExpiryDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _credentialRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String? value,
    DateTime? expiryDate,
  }) {
    final isExpiringSoon = expiryDate != null &&
        expiryDate.difference(DateTime.now()).inDays < 30 &&
        expiryDate.isAfter(DateTime.now());
    final isExpired =
        expiryDate != null && expiryDate.isBefore(DateTime.now());
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 2),
              Text(
                value ?? '—',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (isExpired)
          _statusChip(l10n.adminStatusExpired, Colors.red)
        else if (isExpiringSoon)
          _statusChip(l10n.adminExpiringSoon, Colors.orange),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildDecisionCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final isRejected = tutor.verificationStatus == VerificationStatus.rejected;
    final cardColor = isRejected
        ? Colors.red.withValues(alpha: 0.06)
        : Colors.green.withValues(alpha: 0.06);
    final borderColor = isRejected
        ? Colors.red.withValues(alpha: 0.25)
        : Colors.green.withValues(alpha: 0.25);
    final labelColor = isRejected ? Colors.red.shade700 : Colors.green.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected ? Icons.cancel_outlined : Icons.verified_outlined,
                size: 16,
                color: labelColor,
              ),
              const SizedBox(width: 6),
              Text(
                isRejected ? l10n.adminRejectionDetails : l10n.adminVerificationDetails,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _decisionRow(theme, l10n.adminBy, tutor.verifiedByAdminName ?? '-'),
          const SizedBox(height: 6),
          _decisionRow(
            theme,
            l10n.adminDate,
            tutor.verificationActionAt != null
                ? DateFormat('yyyy-MM-dd – HH:mm')
                    .format(tutor.verificationActionAt!)
                : '-',
          ),
          if (isRejected && tutor.rejectionReason != null) ...[
            const SizedBox(height: 6),
            _decisionRow(theme, l10n.adminRejectionReason, tutor.rejectionReason!),
          ],
        ],
      ),
    );
  }

  Widget _decisionRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
        Expanded(
          child: Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _showRejectSheet,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                label: Text(l10n.adminReject,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _showApproveDialog,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(l10n.adminVerify,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
