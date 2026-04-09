import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/interactive_map/screens/event_detail_screen.dart';
import 'package:athar_app/features/interactive_map/screens/landmark_detail_screen.dart';

class MapBottomSheet extends ConsumerWidget {
  final MapPinModel pin;

  const MapBottomSheet({super.key, required this.pin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isAr = settings.locale.languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Image
          if (pin.imageUrl.isNotEmpty)
            Image.network(
              pin.imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + type badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pin.getTitle(isAr),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TypeBadge(pin: pin, isAr: isAr),
                  ],
                ),
                const SizedBox(height: 8),

                // Event-specific info row
                if (pin.type == MapPinType.event)
                  _EventInfoRow(event: pin.sourceModel as EventModel, isAr: isAr),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('عرض التفاصيل'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openDirections,
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text('الاتجاهات'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    if (pin.type == MapPinType.landmark) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandmarkDetailScreen(
            item: pin.sourceModel as CulturalItemModel,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(
            event: pin.sourceModel as EventModel,
          ),
        ),
      );
    }
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${pin.latitude},${pin.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final MapPinModel pin;
  final bool isAr;

  const _TypeBadge({required this.pin, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (pin.type == MapPinType.landmark) {
      return _badge(context, isAr ? 'معلم ثقافي' : 'Landmark', colorScheme.primary);
    }

    final event = pin.sourceModel as EventModel;
    final label = isAr ? event.eventType.labelAr : event.eventType.labelEn;
    return _badge(context, label, colorScheme.secondary);
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
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

class _EventInfoRow extends StatelessWidget {
  final EventModel event;
  final bool isAr;

  const _EventInfoRow({required this.event, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date =
        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}';
    final time = event.getTime(isAr);

    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
        Icon(Icons.access_time_outlined, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(time, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
