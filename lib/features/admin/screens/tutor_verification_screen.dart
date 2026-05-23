import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/admin/screens/tutor_verification_detail_screen.dart';

class TutorVerificationScreen extends ConsumerWidget {
  const TutorVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return StreamBuilder<List<TutorModel>>(
      stream: ref.watch(adminRepositoryProvider).getPendingTutors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tutors = snapshot.data ?? [];

        if (tutors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 72,
                    color: AppColors.primary.withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طلبات توثيق معلّقة',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tutors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              _PendingTutorCard(tutor: tutors[index]),
        );
      },
    );
  }
}

class _PendingTutorCard extends StatelessWidget {
  final TutorModel tutor;
  const _PendingTutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIndividual = tutor.tutorType == TutorType.individual;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TutorVerificationDetailScreen(tutor: tutor),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
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
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: tutor.profileImage != null
                  ? NetworkImage(tutor.profileImage!)
                  : null,
              child: tutor.profileImage == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 26)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.fullName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.email,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _typeBadge(isIndividual),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(bool isIndividual) {
    final color = isIndividual ? Colors.orange : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isIndividual ? 'فردي' : 'شركة',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isIndividual ? Colors.orange.shade700 : Colors.blue.shade700,
        ),
      ),
    );
  }
}
