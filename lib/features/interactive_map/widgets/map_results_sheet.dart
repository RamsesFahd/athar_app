import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athar_app/core/models/attractions/attraction_model.dart';
import 'package:athar_app/core/models/cultural/cultural_item_model.dart';
import 'package:athar_app/core/models/events/event_model.dart';
import 'package:athar_app/core/models/map/map_pin_model.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/features/interactive_map/logic/map_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class MapResultsSheet extends ConsumerStatefulWidget {
  final LatLngBounds? visibleBounds;
  final ValueChanged<double> onExtentChanged;

  const MapResultsSheet({
    super.key,
    this.visibleBounds,
    required this.onExtentChanged,
  });

  @override
  ConsumerState<MapResultsSheet> createState() => _MapResultsSheetState();
}

class _MapResultsSheetState extends ConsumerState<MapResultsSheet> {
  late final DraggableScrollableController _controller;
  ScrollController? _contentScrollController;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
    _controller.addListener(() {
      if (_controller.isAttached) {
        widget.onExtentChanged(_controller.size);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPins = ref.watch(filteredMapPinsProvider);
    final selectedPin = ref.watch(selectedMapPinProvider);

    // Auto-expand sheet when a pin is selected; also reset content scroll so
    // the header row (share + close buttons) is always visible at the top.
    ref.listen<MapPinModel?>(selectedMapPinProvider, (previous, next) {
      if (next != null && _controller.isAttached) {
        _controller.animateTo(
          0.60,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_contentScrollController?.hasClients == true) {
            _contentScrollController!.jumpTo(0);
          }
        });
      }
    });

    final visiblePins = widget.visibleBounds == null
        ? filteredPins
        : filteredPins
            .where((pin) => widget.visibleBounds!
                .contains(LatLng(pin.latitude, pin.longitude)))
            .toList();

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.30,
      minChildSize: 0.03,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.03, 0.30, 0.95],
      builder: (context, scrollController) {
        _contentScrollController = scrollController;
        return _SheetContent(
          scrollController: scrollController,
          selectedPin: selectedPin,
          visiblePins: visiblePins,
        );
      },
    );
  }
}

class _SheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final MapPinModel? selectedPin;
  final List<MapPinModel> visiblePins;

  const _SheetContent({
    required this.scrollController,
    required this.selectedPin,
    required this.visiblePins,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: selectedPin != null
          ? _PinDetail(pin: selectedPin!, scrollController: scrollController)
          : _ResultsList(pins: visiblePins, scrollController: scrollController),
    );
  }
}

class _PinDetail extends ConsumerWidget {
  final MapPinModel pin;
  final ScrollController scrollController;

  const _PinDetail({required this.pin, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(settingsProvider).locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEvent = pin.type == MapPinType.event;
    final isAttraction = pin.type == MapPinType.attraction;
    final event = isEvent ? pin.sourceModel as EventModel : null;
    final attraction = isAttraction ? pin.sourceModel as AttractionModel : null;
    final pinColor = isAttraction && pin.categoryColorCode != null
        ? _hexToColor(pin.categoryColorCode!)
        : isEvent
            ? cs.secondary
            : cs.primary;
    final landmark =
        !isEvent && !isAttraction ? pin.sourceModel as CulturalItemModel : null;
    final description = isEvent
        ? event!.getDescription(isAr)
        : isAttraction
            ? (isAr
                ? attraction!.description['ar'] ?? ''
                : attraction!.description['en'] ?? '')
            : (isAr ? landmark!.descriptionAr : landmark!.descriptionEn);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                    ),
                    tooltip: l10n.profileClose,
                    onPressed: () =>
                        ref.read(mapNotifierProvider.notifier).selectPin(null),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      pin.getTitle(isAr),
                      style:
                          tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                  tooltip: l10n.mapShareTooltip,
                  onPressed: () => _share(context),
                ),
              ],
            ),
          ),
          if (isEvent && event != null && pin.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _EventImageCarousel(
                  images: [pin.imageUrl, ...event.gallery],
                ),
              ),
            )
          else if (!isEvent && pin.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: pin.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 720,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => SizedBox(
                    height: 200,
                    child: ColoredBox(color: cs.surfaceContainerHighest),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.image_not_supported,
                        color: cs.onSurfaceVariant, size: 40),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(pin: pin, isAr: isAr),

                // ── Event-only: date range + time + free/paid badge ──────
                if (isEvent) ...[
                  const SizedBox(height: 14),
                  _EventDateRow(event: event!, isAr: isAr),
                  const SizedBox(height: 6),
                  _EventTimeRow(event: event, isAr: isAr),
                  const SizedBox(height: 12),
                  _FreeOrPaidBadge(isFree: event.isFree),
                ],

                const SizedBox(height: 20),
                Text(
                  isEvent
                      ? l10n.mapAboutEvent
                      : isAttraction
                          ? l10n.mapAboutAttraction
                          : l10n.mapAboutLandmark,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description.isNotEmpty
                      ? description
                      : (isAr
                          ? 'لا يوجد وصف متاح'
                          : 'No description available'),
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    height: 1.6,
                  ),
                ),

                if (isEvent && event!.videoUrl != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openUrl(event.videoUrl!),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text(isAr ? 'مشاهدة الفيديو' : 'Watch video'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],

                if (isEvent && event!.ticketUrl != null && !event.isFree) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(event.ticketUrl!),
                      icon: const Icon(Icons.confirmation_number_outlined),
                      label: Text(l10n.mapBookTicket),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                if (isEvent)
                  Row(
                    children: [
                      if (event!.ticketUrl != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openUrl(event.ticketUrl!),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(l10n.mapSource),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_outlined, size: 16),
                          label: Text(l10n.mapDirections),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pinColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(l10n.mapDirections),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _share(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final url = 'https://maps.google.com/?q=${pin.latitude},${pin.longitude}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.commonLinkCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${pin.latitude},${pin.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ResultsList extends ConsumerWidget {
  final List<MapPinModel> pins;
  final ScrollController scrollController;

  const _ResultsList({required this.pins, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverToBoxAdapter(child: _DragHandle()),
        if (pins.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mapNoResultsInArea,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PinListCard(pin: pins[index]),
              childCount: pins.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _PinListCard extends ConsumerWidget {
  final MapPinModel pin;

  const _PinListCard({required this.pin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(settingsProvider).locale.languageCode == 'ar';
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => ref.read(mapNotifierProvider.notifier).selectPin(pin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: pin.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: pin.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      memCacheWidth: 260,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        width: 80,
                        height: 80,
                        color: cs.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => _placeholder(cs),
                    )
                  : _placeholder(cs),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pin.getTitle(isAr),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _TypeBadge(pin: pin, isAr: isAr),
                  if (pin.type == MapPinType.event) ...[
                    const SizedBox(height: 4),
                    _EventInfoRow(
                        event: pin.sourceModel as EventModel, isAr: isAr),
                  ],
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        pin.type == MapPinType.landmark
            ? Icons.account_balance
            : pin.type == MapPinType.attraction
                ? Icons.place_outlined
                : Icons.celebration,
        color: cs.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final n = hex.replaceAll('#', '').padLeft(6, '0');
  return Color(int.parse('FF$n', radix: 16));
}

class _TypeBadge extends StatelessWidget {
  final MapPinModel pin;
  final bool isAr;

  const _TypeBadge({required this.pin, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String label;
    final Color color;

    if (pin.type == MapPinType.attraction) {
      label = AppLocalizations.of(context).mapAttractionLabel;
      final hex = pin.categoryColorCode;
      color = hex != null ? _hexToColor(hex) : const Color(0xFF3A6EA5);
    } else if (pin.type == MapPinType.landmark) {
      label = AppLocalizations.of(context).mapLandmarkLabel;
      color = cs.primary;
    } else {
      final event = pin.sourceModel as EventModel;
      label = isAr ? event.eventType.labelAr : event.eventType.labelEn;
      color = cs.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _FreeOrPaidBadge extends StatelessWidget {
  final bool isFree;

  const _FreeOrPaidBadge({required this.isFree});

  @override
  Widget build(BuildContext context) {
    final color = isFree ? Colors.green : Colors.orange;
    final l10n = AppLocalizations.of(context);
    final label = isFree ? l10n.commonFree : l10n.commonPaid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFree ? Icons.check_circle_outline : Icons.paid_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _EventDateRow extends StatelessWidget {
  final EventModel event;
  final bool isAr;

  const _EventDateRow({required this.event, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final start = event.eventDate;
    final end = event.endDate;

    final String dateText;
    if (end != null &&
        !(end.year == start.year &&
            end.month == start.month &&
            end.day == start.day)) {
      dateText =
          '${start.day}/${start.month}/${start.year} → ${end.day}/${end.month}/${end.year}';
    } else {
      dateText = '${start.day}/${start.month}/${start.year}';
    }

    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 15, color: cs.primary),
        const SizedBox(width: 6),
        Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _EventTimeRow extends StatelessWidget {
  final EventModel event;
  final bool isAr;

  const _EventTimeRow({required this.event, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = event.getTime(isAr);

    return Row(
      children: [
        Icon(Icons.access_time_outlined, size: 15, color: cs.primary),
        const SizedBox(width: 6),
        Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _EventImageCarousel extends StatefulWidget {
  final List<String> images;

  const _EventImageCarousel({required this.images});

  @override
  State<_EventImageCarousel> createState() => _EventImageCarouselState();
}

class _EventImageCarouselState extends State<_EventImageCarousel> {
  int _currentPage = 0;
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startTimer();
  }

  void _startTimer() {
    if (widget.images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              _timer?.cancel();
              setState(() => _currentPage = i);
              _startTimer();
            },
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.cover,
              memCacheWidth: 720,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) =>
                  ColoredBox(color: cs.surfaceContainerHighest),
              errorWidget: (_, __, ___) => Container(
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.image_not_supported,
                    color: cs.onSurfaceVariant, size: 40),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentPage ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Used in the results list cards only
class _EventInfoRow extends StatelessWidget {
  final EventModel event;
  final bool isAr;

  const _EventInfoRow({required this.event, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date =
        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}';
    final time = event.getTime(isAr);

    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: cs.primary),
        const SizedBox(width: 4),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Icon(Icons.access_time_outlined, size: 12, color: cs.primary),
        const SizedBox(width: 4),
        Text(time, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
