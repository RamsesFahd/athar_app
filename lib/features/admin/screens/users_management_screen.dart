import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/logic/admin_repository.dart';
import 'package:athar_app/features/admin/screens/tutor_verification_detail_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.adminUsersTab),
                Tab(text: l10n.adminGuidesTab),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _UsersTab(),
                _GuidesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Users Tab ────────────────────────────────────────────────────────────────

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: l10n.adminSearchUsersHint,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: ref.watch(adminRepositoryProvider).getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allUsers = snapshot.data ?? [];
              // Exclude guests
              final filtered = allUsers
                  .where((u) =>
                      u.role != UserRole.guest &&
                      (_searchQuery.isEmpty ||
                          u.fullName
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          u.email.toLowerCase().contains(_searchQuery)))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? l10n.adminNoUsersFound
                        : l10n.adminNoResultsFor(_searchQuery),
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade500),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _UserTile(user: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Guides Tab ───────────────────────────────────────────────────────────────

class _GuidesTab extends ConsumerStatefulWidget {
  const _GuidesTab();

  @override
  ConsumerState<_GuidesTab> createState() => _GuidesTabState();
}

class _GuidesTabState extends ConsumerState<_GuidesTab> {
  VerificationStatus _filter = VerificationStatus.pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filterLabels = {
      VerificationStatus.pending: l10n.adminStatusPending,
      VerificationStatus.verified: l10n.adminStatusApproved,
      VerificationStatus.rejected: l10n.adminStatusRejected,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterLabels.entries.map((entry) {
                final selected = _filter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = entry.key),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : Colors.grey,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<TutorModel>>(
            stream: ref.watch(adminRepositoryProvider).getAllTutors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tutors = (snapshot.data ?? [])
                  .where((t) => t.verificationStatus == _filter)
                  .toList();

              if (tutors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text(
                        l10n.adminNoGuidesForStatus(
                          filterLabels[_filter]?.toLowerCase() ?? '',
                        ),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tutors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _GuideTile(tutor: tutors[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shared tile widgets ───────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTutor = user is TutorModel;
    final tutor = isTutor ? user as TutorModel : null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Icon(Icons.person, color: AppColors.primary, size: 22)
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _RoleBadge(role: user.role),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(user.email,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis),
            if (isTutor && tutor!.verificationStatus != null) ...[
              const SizedBox(height: 4),
              _VerificationBadge(status: tutor.verificationStatus!),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  final TutorModel tutor;
  const _GuideTile({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIndividual = tutor.tutorType == TutorType.individual;
    final status = tutor.verificationStatus;

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
          border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12)),
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
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: tutor.profileImage != null
                  ? NetworkImage(tutor.profileImage!)
                  : null,
              child: tutor.profileImage == null
                  ? Icon(Icons.person, color: AppColors.primary, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tutor.fullName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(tutor.email,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis),
                  if (status != null) ...[
                    const SizedBox(height: 4),
                    _VerificationBadge(status: status),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _typeBadge(context, isIndividual),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(BuildContext context, bool isIndividual) {
    final l10n = AppLocalizations.of(context);
    final color = isIndividual ? Colors.orange : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isIndividual ? l10n.adminGuideTypeIndividual : l10n.adminGuideTypeCompany,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isIndividual
                ? Colors.orange.shade700
                : Colors.blue.shade700),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case UserRole.tutor:
        color = Colors.blue;
        label = l10n.adminRoleTutor;
      case UserRole.admin:
        color = Colors.purple;
        label = l10n.adminRoleAdmin;
      default:
        color = Colors.teal;
        label = l10n.adminRoleTourist;
    }
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

class _VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    final l10n = AppLocalizations.of(context);
    String label;
    switch (status) {
      case VerificationStatus.verified:
        color = Colors.green;
        icon = Icons.verified;
        label = l10n.adminStatusApproved;
      case VerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_top_rounded;
        label = l10n.adminStatusPending;
      case VerificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = l10n.adminStatusRejected;
      case VerificationStatus.expired:
        color = Colors.grey;
        icon = Icons.timer_off_outlined;
        label = l10n.adminStatusExpired;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        label = status.name;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
