import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/contribution/contribution_model.dart';
import 'package:athar_app/core/constants/region_city_constants.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/services/gemini_service.dart';
import 'package:athar_app/features/contributions/logic/contribution_repository.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_notifier.dart';
import 'package:athar_app/features/cultural_archive/logic/cultural_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class ContributionReviewDetailScreen extends ConsumerStatefulWidget {
  final ContributionModel contribution;
  const ContributionReviewDetailScreen({super.key, required this.contribution});

  @override
  ConsumerState<ContributionReviewDetailScreen> createState() =>
      _ContributionReviewDetailScreenState();
}

class _ContributionReviewDetailScreenState
    extends ConsumerState<ContributionReviewDetailScreen> {
  late final TextEditingController _targetTitleController;
  late final TextEditingController _targetDescController;
  bool _isLoading = false;
  bool _isTranslating = false;

  ContributionModel get c => widget.contribution;

  // The language to be filled by admin (opposite of submission language)
  bool get _submittedInAr => c.submissionLanguage == 'ar';

  @override
  void initState() {
    super.initState();
    // Pre-fill target language fields if admin already filled them before
    _targetTitleController = TextEditingController(
      text: _submittedInAr ? c.titleEn : c.titleAr,
    );
    _targetDescController = TextEditingController(
      text: _submittedInAr ? c.descriptionEn : c.descriptionAr,
    );
  }

  @override
  void dispose() {
    _targetTitleController.dispose();
    _targetDescController.dispose();
    super.dispose();
  }

  // ── Auto-translate ──────────────────────────────────────────────────────────

  Future<void> _autoTranslate() async {
    setState(() => _isTranslating = true);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final sourceTitle = _submittedInAr ? c.titleAr : c.titleEn;
      final sourceDesc = _submittedInAr ? c.descriptionAr : c.descriptionEn;
      final targetLang = _submittedInAr ? 'English' : 'Arabic';

      final response = await gemini.getResponse(
        systemInstruction:
            'You are a cultural heritage translator. Return ONLY valid JSON with no markdown, no code blocks, no explanation.',
        prompt:
            'Translate to $targetLang. Input: {"title": ${jsonEncode(sourceTitle)}, "description": ${jsonEncode(sourceDesc)}}. Return: {"title": "...", "description": "..."}',
      );

      final cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _targetTitleController.text = parsed['title'] as String? ?? '';
        _targetDescController.text = parsed['description'] as String? ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).adminTranslationFailed('')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  // ── Approve ─────────────────────────────────────────────────────────────────

  Future<void> _showApproveDialog() async {
    final l10n = AppLocalizations.of(context);
    final targetTitle = _targetTitleController.text.trim();
    final targetDesc = _targetDescController.text.trim();

    if (targetTitle.isEmpty || targetDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _submittedInAr
                ? l10n.adminFillEnglishBeforeApprove
                : l10n.adminFillArabicBeforeApprove,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminApproveContribution),
        content: Text(l10n.adminApproveContributionConfirm(
          c.displayTitle,
          c.touristName,
          ContributionRepository.getPoints(c.category, c.mediaType),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l10n.adminApprove),
          ),
        ],
      ),
    );

    if (confirmed == true) await _approve(targetTitle, targetDesc);
  }

  Future<void> _approve(String targetTitle, String targetDesc) async {
    final admin = ref.read(authNotifierProvider).value;
    if (admin == null) return;
    setState(() => _isLoading = true);
    try {
      final points =
          ContributionRepository.getPoints(c.category, c.mediaType);
      await ref.read(adminRepositoryProvider).approveContribution(
            c.id,
            touristId: c.touristId,
            touristName: c.touristName,
            points: points,
            titleAr: _submittedInAr ? c.titleAr : targetTitle,
            titleEn: _submittedInAr ? targetTitle : c.titleEn,
            descriptionAr:
                _submittedInAr ? c.descriptionAr : targetDesc,
            descriptionEn:
                _submittedInAr ? targetDesc : c.descriptionEn,
            mediaUrl: c.mediaUrl,
            category: c.category,
            regionId: c.regionId,
            adminId: admin.uId,
            adminName: admin.fullName,
          );
      // Bust the cultural archive cache so the new item appears immediately
      ref.read(culturalRepositoryProvider).clearCache();
      ref.invalidate(culturalNotifierProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).adminContributionApproved),
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

  // ── Reject ──────────────────────────────────────────────────────────────────

  Future<void> _showRejectSheet() async {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adminRejectContribution,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.adminRejectContributionHelp,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.adminRejectReasonHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                            content: Text(l10n.adminPleaseEnterReason)),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    await _reject(reason);
                  },
                  child: Text(l10n.adminReject),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reject(String reason) async {
    final admin = ref.read(authNotifierProvider).value;
    if (admin == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).rejectContribution(
            c.id,
            touristId: c.touristId,
            adminId: admin.uId,
            adminName: admin.fullName,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).adminContributionRejected)),
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

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isPending = c.status == ContributionStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminReviewContribution),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _buildMediaPreview(theme),
                const SizedBox(height: 16),
                _buildTouristInfo(theme),
                const SizedBox(height: 16),
                _buildSubmissionInfo(theme),
                const SizedBox(height: 16),
                _buildSourceContent(theme),
                const SizedBox(height: 16),
                _buildTargetContent(theme, isPending),
                if (isPending) ...[
                  const SizedBox(height: 24),
                  _buildActionRow(theme),
                ],
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _buildMediaPreview(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: c.mediaType == 'image'
          ? Image.network(
              c.mediaUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined, size: 48),
              ),
            )
          : Container(
              height: 220,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_rounded,
                      size: 56,
                      color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(l10n.adminVideoContribution,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
    );
  }

  Widget _buildTouristInfo(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return _InfoCard(
      title: l10n.adminTourist,
      children: [
        _InfoRow(icon: Icons.person_outline, label: l10n.adminName, value: c.touristName),
        _InfoRow(icon: Icons.email_outlined, label: l10n.adminEmail, value: c.touristEmail),
      ],
    );
  }

  Widget _buildSubmissionInfo(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final region = regionLabel(c.regionId, isArabic: false);
    final regionAr = regionLabel(c.regionId, isArabic: true);
    final city = cityLabel(c.cityId, isArabic: false);
    final cityAr = cityLabel(c.cityId, isArabic: true);
    final date = DateFormat('MMM d, yyyy – HH:mm').format(c.createdAt);

    return _InfoCard(
      title: l10n.adminSubmissionDetails,
      children: [
        _InfoRow(
            icon: Icons.category_outlined,
            label: l10n.adminCategory,
            value: c.category.replaceAll('_', ' ').toUpperCase()),
        _InfoRow(
            icon: Icons.location_on_outlined,
            label: l10n.adminRegion,
            value: '$regionAr / $region'),
        _InfoRow(
            icon: Icons.location_city_outlined,
            label: l10n.adminCity,
            value: '$cityAr / $city'),
        _InfoRow(
            icon: Icons.language,
            label: l10n.adminSubmittedIn,
            value: c.submissionLanguage == 'ar' ? l10n.arabic : l10n.english),
        _InfoRow(icon: Icons.calendar_today_outlined, label: l10n.adminDate, value: date),
        if (c.status == ContributionStatus.rejected &&
            c.rejectionReason != null)
          _InfoRow(
              icon: Icons.cancel_outlined,
              label: l10n.adminRejectionReason,
              value: c.rejectionReason!,
              valueColor: Colors.red),
      ],
    );
  }

  Widget _buildSourceContent(ThemeData theme) {
    final sourceTitle = _submittedInAr ? c.titleAr : c.titleEn;
    final sourceDesc = _submittedInAr ? c.descriptionAr : c.descriptionEn;
    final l10n = AppLocalizations.of(context);
    final langLabel = _submittedInAr ? l10n.adminArabicByTourist : l10n.adminEnglishByTourist;

    return _InfoCard(
      title: langLabel,
      children: [
        _InfoRow(icon: Icons.title, label: l10n.adminTitle, value: sourceTitle),
        _InfoRow(
            icon: Icons.notes_rounded,
            label: l10n.adminDescription,
            value: sourceDesc,
            maxLines: 6),
      ],
    );
  }

  Widget _buildTargetContent(ThemeData theme, bool isPending) {
    final l10n = AppLocalizations.of(context);
    final targetLangLabel =
        _submittedInAr ? l10n.adminEnglishAdminFills : l10n.adminArabicAdminFills;

    return _InfoCard(
      title: targetLangLabel,
      children: [
        if (isPending) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTranslating ? null : _autoTranslate,
                  icon: _isTranslating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(
                      _isTranslating ? l10n.adminTranslating : l10n.adminAutoTranslate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _targetTitleController,
          readOnly: !isPending,
          decoration: InputDecoration(
            labelText: l10n.adminTitle,
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _targetDescController,
          readOnly: !isPending,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l10n.adminDescription,
            prefixIcon: const Icon(Icons.notes_rounded),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _showRejectSheet,
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: Text(l10n.adminReject,
                style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _showApproveDialog,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(l10n.adminApprove),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared UI helpers ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
