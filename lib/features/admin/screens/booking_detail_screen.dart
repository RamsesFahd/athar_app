import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/booking_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';

class BookingDetailScreen extends ConsumerWidget {
  final BookingModel booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(adminRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز'), centerTitle: true),
      body: FutureBuilder<List<UserModel?>>(
        future: Future.wait([
          repo.getUserById(booking.touristId),
          repo.getUserById(booking.tutorId),
        ]),
        builder: (context, snapshot) {
          final theme = Theme.of(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tourist = snapshot.data?[0];
          final tutor = snapshot.data?[1];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripCard(context, theme),
                const SizedBox(height: 16),
                _buildPersonCard(
                  theme,
                  title: 'السائح',
                  icon: Icons.person_outlined,
                  user: tourist,
                ),
                const SizedBox(height: 16),
                _buildPersonCard(
                  theme,
                  title: 'المرشد',
                  icon: Icons.tour_outlined,
                  user: tutor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (booking.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    booking.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.tripTitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: booking.status),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(theme, Icons.calendar_today_outlined, 'التاريخ',
              '${booking.date}  •  ${booking.timeSlot}'),
          const SizedBox(height: 10),
          _infoRow(theme, Icons.people_outline, 'الأشخاص',
              '${booking.adultsCount} بالغ  •  ${booking.childrenCount} طفل'),
          const SizedBox(height: 10),
          _infoRow(theme, Icons.payments_outlined, 'المبلغ الإجمالي',
              '${CurrencyFormatter.formatNumber(booking.totalPrice, decimals: 2)} ريال'),
        ],
      ),
    );
  }

  Widget _buildPersonCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required UserModel? user,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          if (user == null)
            Text('لا توجد بيانات',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade500))
          else ...[
            _infoRow(theme, Icons.badge_outlined, 'الاسم', user.fullName),
            const SizedBox(height: 10),
            _infoRow(theme, Icons.email_outlined, 'البريد الإلكتروني',
                user.email),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow(theme, Icons.phone_outlined, 'رقم الجوال',
                  user.phoneNumber!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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

  BoxDecoration _cardDecoration(ThemeData theme) {
    return BoxDecoration(
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.approved => ('مقبول', Colors.green),
      BookingStatus.completed => ('مكتمل', Colors.blue),
      BookingStatus.rejected => ('مرفوض', Colors.red),
      BookingStatus.cancelled => ('ملغي', Colors.grey),
      _ => ('قيد المراجعة', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
