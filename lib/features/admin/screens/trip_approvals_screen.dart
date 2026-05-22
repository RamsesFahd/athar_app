import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';

final _allTripsStreamProvider = StreamProvider.autoDispose<List<TripModel>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllTrips();
});

class TripApprovalsScreen extends ConsumerStatefulWidget {
  const TripApprovalsScreen({super.key});

  @override
  ConsumerState<TripApprovalsScreen> createState() => _TripApprovalsScreenState();
}

class _TripApprovalsScreenState extends ConsumerState<TripApprovalsScreen> {
  String? _filter = 'pending';

  static const _filters = [
    (label: 'قيد المراجعة', value: 'pending'),
    (label: 'مقبول', value: 'approved'),
    (label: 'مرفوض', value: 'rejected'),
    (label: 'الكل', value: null),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripsAsync = ref.watch(_allTripsStreamProvider);

    return Column(
      children: [
        _buildFilterRow(theme),
        Expanded(
          child: tripsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (all) {
              final filtered = _filter == null
                  ? all
                  : all.where((t) => t.status == _filter).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_travel_outlined,
                          size: 72,
                          color: AppColors.primary.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد رحلات',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _TripCard(trip: filtered[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isSelected = _filter == f.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.label),
                selected: isSelected,
                onSelected: (_) => setState(() => _filter = f.value),
                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                backgroundColor: Colors.transparent,
                showCheckmark: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailAdminScreen(trip: trip)),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: trip.imageUrl.isNotEmpty
                  ? Image.network(
                      trip.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.titleAr,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.cityAr}  •  ${trip.guide}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: trip.status),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined,
          color: Colors.grey, size: 24),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('مقبول', Colors.green),
      'rejected' => ('مرفوض', Colors.red),
      _ => ('قيد المراجعة', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Trip Detail Screen ────────────────────────────────────────────────────────

class TripDetailAdminScreen extends ConsumerStatefulWidget {
  final TripModel trip;
  const TripDetailAdminScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailAdminScreen> createState() =>
      _TripDetailAdminScreenState();
}

class _TripDetailAdminScreenState extends ConsumerState<TripDetailAdminScreen> {
  bool _isLoading = false;

  TripModel get trip => widget.trip;

  Future<void> _showApproveDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قبول الرحلة'),
        content: Text('هل تريد قبول رحلة "${trip.titleAr}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('قبول'),
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
      await ref.read(adminRepositoryProvider).approveTrip(
            trip.id,
            tutorId: trip.tutorId ?? '',
            adminId: admin.uId,
            adminName: admin.fullName,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الرحلة'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRejectSheet() async {
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
              const Text(
                'سبب الرفض',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'سيُبلَّغ المرشد بسبب رفض الرحلة.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'مثال: المعلومات غير مكتملة',
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
                  child: const Text('رفض'),
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
      await ref.read(adminRepositoryProvider).rejectTrip(
            trip.id,
            tutorId: trip.tutorId ?? '',
            adminId: admin.uId,
            adminName: admin.fullName,
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض الرحلة'), backgroundColor: Colors.orange),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الرحلة'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trip.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        trip.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trip.titleAr,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: trip.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(theme),
                  if (trip.status != 'pending' &&
                      trip.reviewedByAdminName != null) ...[
                    const SizedBox(height: 16),
                    _buildDecisionCard(theme),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: trip.status == 'pending'
          ? _buildBottomBar(theme)
          : null,
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
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
          Text('بيانات الرحلة',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          _infoRow(theme, Icons.location_city_outlined, 'المدينة',
              '${trip.cityAr} · ${trip.cityEn}'),
          const SizedBox(height: 12),
          _infoRow(theme, Icons.person_outline, 'المرشد', trip.guide),
          if (trip.company.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(theme, Icons.business_outlined, 'الشركة', trip.company),
          ],
          const SizedBox(height: 12),
          _infoRow(theme, Icons.payments_outlined, 'السعر', trip.price),
          const SizedBox(height: 12),
          _infoRow(theme, Icons.verified_outlined, 'الرخصة', trip.license),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5))),
              const SizedBox(height: 2),
              Text(value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionCard(ThemeData theme) {
    final isRejected = trip.status == 'rejected';
    final cardColor = isRejected
        ? Colors.red.withValues(alpha: 0.06)
        : Colors.green.withValues(alpha: 0.06);
    final borderColor = isRejected
        ? Colors.red.withValues(alpha: 0.25)
        : Colors.green.withValues(alpha: 0.25);
    final labelColor =
        isRejected ? Colors.red.shade700 : Colors.green.shade700;

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
                isRejected ? 'تفاصيل الرفض' : 'تفاصيل القبول',
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _decisionRow(theme, 'بواسطة', trip.reviewedByAdminName ?? '-'),
          const SizedBox(height: 6),
          _decisionRow(
            theme,
            'التاريخ',
            trip.reviewedAt != null
                ? DateFormat('yyyy-MM-dd – HH:mm').format(trip.reviewedAt!)
                : '-',
          ),
          if (isRejected && trip.rejectionReason != null) ...[
            const SizedBox(height: 6),
            _decisionRow(theme, 'السبب', trip.rejectionReason!),
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
          width: 70,
          child: Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                label: const Text('رفض',
                    style: TextStyle(
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
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('قبول',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
