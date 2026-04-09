import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isAr = settings.locale.languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;

    final dateStr =
        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isAr ? 'تفاصيل الفعالية' : 'Event Details',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  event.imageUrl.isNotEmpty
                      ? Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.secondaryContainer,
                            child: const Icon(Icons.event, size: 60),
                          ),
                        )
                      : Container(
                          color: colorScheme.secondaryContainer,
                          child: const Icon(Icons.event, size: 60),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.getTitle(isAr),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Event type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: colorScheme.secondary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      isAr
                          ? event.eventType.labelAr
                          : event.eventType.labelEn,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info cards row
                  Row(
                    children: [
                      _infoCard(
                        context,
                        Icons.calendar_month,
                        dateStr,
                        isAr ? 'التاريخ' : 'Date',
                      ),
                      const Spacer(),
                      _infoCard(
                        context,
                        Icons.location_on_outlined,
                        event.getRegion(isAr),
                        isAr ? 'الموقع' : 'Location',
                      ),
                      const Spacer(),
                      _infoCard(
                        context,
                        Icons.access_time,
                        event.getTime(isAr),
                        isAr ? 'الوقت' : 'Time',
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1),
                  ),

                  // Description
                  Text(
                    isAr ? 'عن الفعالية' : 'About',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.getDescription(isAr),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Ticket button (if available)
                  if (event.ticketUrl != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () => _launchUrl(event.ticketUrl!),
                        child: Text(
                          isAr ? 'احجز تذكرتك الآن' : 'Book Ticket',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Directions button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openDirections(event.latitude, event.longitude),
                      icon: const Icon(Icons.directions_outlined),
                      label:
                          Text(isAr ? 'الاتجاهات' : 'Get Directions'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center),
      ],
    );
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
