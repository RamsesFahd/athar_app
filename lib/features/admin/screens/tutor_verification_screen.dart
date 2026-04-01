import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';

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
                Text('No pending verifications',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tutors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _TutorVerificationCard(tutor: tutors[index]),
        );
      },
    );
  }
}

class _TutorVerificationCard extends ConsumerWidget {
  final TutorModel tutor;
  const _TutorVerificationCard({required this.tutor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(adminRepositoryProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: tutor.profileImage != null
                      ? NetworkImage(tutor.profileImage!)
                      : null,
                  child: tutor.profileImage == null
                      ? Icon(Icons.person,
                          color: AppColors.primary, size: 26)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tutor.fullName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(tutor.email,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _TypeBadge(type: tutor.tutorType),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'License',
              value: tutor.licenceNumber ?? 'Not provided',
            ),
            if (tutor.companyName != null)
              _InfoRow(
                icon: Icons.business_outlined,
                label: 'Company',
                value: tutor.companyName!,
              ),
            if (tutor.commercialRegistration != null)
              _InfoRow(
                icon: Icons.article_outlined,
                label: 'Commercial Reg.',
                value: tutor.commercialRegistration!,
              ),
            if (tutor.phoneNumber != null)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: tutor.phoneNumber!,
              ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await repo.rejectTutor(tutor.uId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor rejected'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await repo.approveTutor(tutor.uId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor approved'),
                              backgroundColor: Colors.green),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final TutorType? type;
  const _TypeBadge({this.type});

  @override
  Widget build(BuildContext context) {
    final isCompany = type == TutorType.company;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompany
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isCompany
                ? Colors.blue.withValues(alpha: 0.4)
                : Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Text(
        isCompany ? 'Company' : 'Individual',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCompany ? Colors.blue.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
