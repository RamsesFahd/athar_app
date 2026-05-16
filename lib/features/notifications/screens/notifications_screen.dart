import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/notifications/logic/notifications_repository.dart';
import 'package:athar_app/features/notifications/widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final user = ref.watch(authNotifierProvider).valueOrNull;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'التنبيهات' : 'Notifications'),
        ),
        body: Center(
          child: Text(isAr ? 'يرجى تسجيل الدخول' : 'Please sign in'),
        ),
      );
    }

    final notificationsAsync =
        ref.watch(userNotificationsProvider(user.uId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isAr ? 'التنبيهات' : 'Notifications',
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
            isAr ? 'حدث خطأ أثناء تحميل التنبيهات' : 'Failed to load notifications',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        data: (notifications) {
  if (notifications.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          isAr ? 'لا توجد تنبيهات حتى الآن' : 'No notifications yet',
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

              return NotificationCard(
                notification: notification,
                onTap: () {
                  ref
                      .read(notificationsRepositoryProvider)
                      .markAsRead(user.uId, notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}