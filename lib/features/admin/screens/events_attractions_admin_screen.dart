import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/screens/add_event_screen.dart';
import 'package:athar_app/features/admin/screens/attractions_admin_screen.dart';
import 'package:athar_app/features/events/logic/events_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class EventsAttractionsAdminScreen extends ConsumerWidget {
  const EventsAttractionsAdminScreen({super.key});

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
                Tab(text: l10n.homeEventsSectionTitle),
                Tab(text: l10n.attractionsTitle),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _EventsAdminTab(),
                AttractionsAdminScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsAdminTab extends ConsumerWidget {
  const _EventsAdminTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Stack(
      children: [
        eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(l10n.commonErrorWithMessage(e.toString()))),
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_outlined,
                        size: 72,
                        color: AppColors.primary.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.adminNoEvents,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _EventAdminTile(event: events[index]),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'add_event',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventScreen()),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(l10n.adminAddEvent),
          ),
        ),
      ],
    );
  }
}

class _EventAdminTile extends StatelessWidget {
  final EventModel event;
  const _EventAdminTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDate = dateFormat.format(event.eventDate);
    final endDate =
        event.endDate != null ? dateFormat.format(event.endDate!) : null;
    final dateText = endDate == null ? startDate : '$startDate - $endDate';
    final timeText = event.getTime(isAr);
    final regionText = event.getRegion(isAr);
    final typeText = isAr ? event.eventType.labelAr : event.eventType.labelEn;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.network(
              event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.getTitle(isAr),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeText • $regionText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText.isEmpty ? dateText : '$dateText • $timeText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
