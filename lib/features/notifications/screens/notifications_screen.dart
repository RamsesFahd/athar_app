import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/notifications/logic/notifications_repository.dart';
import 'package:athar_app/features/notifications/widgets/notification_card.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authNotifierProvider).valueOrNull;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationsTitle),
        ),
        body: Center(
          child: Text(l10n.notificationsSignInRequired),
        ),
      );
    }

    final notificationsAsync =
        ref.watch(userNotificationsProvider(user.uId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.notificationsTitle,
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        error: (e, _) => Center(
          child: Text(
            l10n.notificationsLoadError,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.notificationsEmptyState,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                onDismissed: (_) {
                  ref
                      .read(notificationsRepositoryProvider)
                      .deleteNotification(user.uId, notification.id);
                },
                child: NotificationCard(
                  notification: notification,
                  onTap: () {
                    ref
                        .read(notificationsRepositoryProvider)
                        .markAsRead(user.uId, notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
