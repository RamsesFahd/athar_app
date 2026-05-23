import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:athar_app/core/utils/share_utils.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/profile/logic/favorites_notifier.dart';
import 'package:athar_app/features/guide_market/screens/booking_form_screen.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/core/providers/settings_provider.dart';
import 'package:athar_app/services/tts_service.dart';

class TripDetailsScreen extends ConsumerWidget {
  final TripModel trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final ttsService = ref.read(ttsServiceProvider);

    final titleText = trip.getTitle(isAr);
    final descriptionText = trip.getDescription(isAr);
    final isFullyBooked = trip.isPrivate
        ? ref.watch(bookedDatesForTripProvider(trip.id)).whenOrNull(
                data: (dates) => trip.isPrivateFullyBooked(dates)) ??
            false
        : trip.isFullyBooked;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ────────────────────────────────────────
                CachedNetworkImage(
                  imageUrl: trip.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  memCacheWidth: 1080,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──────────────────────────────────────
                      Text(trip.getTitle(isAr),
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 8),

                      // ── Trip type + accessibility badges on one row ─
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTripTypeBadge(theme, l10n, isAr),
                          ..._buildAccessibilityBadgeList(theme, l10n, isAr),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Price display ──────────────────────────────
                      _buildPriceRow(theme, isAr, l10n),
                      const SizedBox(height: 16),

                      // ── Description ────────────────────────────────
                      if (descriptionText.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        MarkdownBody(
                          data: descriptionText,
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.6),
                            listBullet: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.6),
                            strong: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Guide info — live from user doc ────────────
                      StreamBuilder<DocumentSnapshot>(
                        stream: trip.tutorId != null
                            ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(trip.tutorId)
                                .snapshots()
                            : const Stream.empty(),
                        builder: (context, snap) {
                          final data =
                              snap.data?.data() as Map<String, dynamic>?;
                          final liveName =
                              data?['fullName'] as String? ?? trip.guide;
                          return _buildInfoRow(
                            context,
                            Icons.person_outline,
                            '${l10n.guide}: $liveName',
                            trailing: GestureDetector(
                              onTap: () =>
                                  _showGuideDetailsPopUp(context, l10n, isAr),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildInfoRow(context, Icons.verified_outlined,
                          '${l10n.license}: ${trip.license}'),
                      if (trip.timeRange != null)
                        _buildInfoRow(
                          context,
                          Icons.access_time,
                          '${l10n.time}: ${trip.timeRange}',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top navigation buttons ────────────────────────────────
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Row(
                  children: [
                    if (settings.isTtsEnabled)
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.volume_up_rounded,
                              color: Colors.white),
                          onPressed: () {
                            ttsService.speak('$titleText. $descriptionText');
                          },
                        ),
                      ),
                    if (settings.isTtsEnabled) const SizedBox(width: 8),
                    Consumer(
                      builder: (ctx, consumerRef, _) {
                        final isFavAsync =
                            consumerRef.watch(isFavoriteProvider(trip.id));
                        final isFav = isFavAsync.valueOrNull ?? false;
                        return CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                            ),
                            onPressed: () => consumerRef
                                .read(favoritesNotifierProvider.notifier)
                                .toggle(FavoriteItemModel.fromTrip(trip)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () => ShareUtils.shareTrip(
                          context: context,
                          titleAr: trip.titleAr,
                          titleEn: trip.titleEn,
                          cityAr: trip.cityAr,
                          cityEn: trip.cityEn,
                          adultPrice: trip.adultPrice,
                          isAr: isAr,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Book Now / Fully Booked button ────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isFullyBooked
                      ? null
                      : () {
                          final currentUser =
                              ref.read(authNotifierProvider).value;
                          if (currentUser is TouristModel &&
                              (currentUser.phoneNumber == null ||
                                  currentUser.phoneNumber!.isEmpty)) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.completeProfileTitle),
                                content: Text(l10n.phoneRequiredForTourist),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.commonOk),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          ref
                              .read(bookingNotifierProvider.notifier)
                              .startBooking(trip);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingFormScreen(trip: trip),
                            ),
                          );
                        },
                  style: isFullyBooked
                      ? ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.12),
                          foregroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        )
                      : null,
                  child: Text(
                    isFullyBooked ? l10n.tripFullyBooked : l10n.book_now,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeBadge(
    ThemeData theme,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final isPrivate = trip.isPrivate;
    final color = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrivate ? Icons.lock_outline : Icons.group_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isPrivate ? l10n.tripTypePrivate : l10n.tripTypeShared,
            style: (isAr
                    ? theme.textTheme.labelSmall ?? const TextStyle()
                    : const TextStyle(fontFamily: 'Tajawal'))
                .copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ThemeData theme, bool isAr, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildPriceItem(
            theme,
            label: l10n.tripAdultsPriceLabel,
            price: CurrencyFormatter.format(trip.adultPrice),
            icon: Icons.person_outline,
          ),
          if (trip.allowsKids) ...[
            Container(
              height: 30,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            _buildPriceItem(
              theme,
              label: l10n.tripChildrenPriceLabel,
              price: trip.childPrice == 0
                  ? Text(l10n.commonFree)
                  : CurrencyFormatter.format(trip.childPrice),
              icon: Icons.child_care_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceItem(ThemeData theme,
      {required String label, required Widget price, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              DefaultTextStyle(
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                child: price,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAccessibilityBadgeList(
    ThemeData theme,
    AppLocalizations l10n,
    bool isAr,
  ) {
    const badgeInfo = {
      'wheelchair': (icon: Icons.accessible_forward_rounded,),
      'family': (icon: Icons.family_restroom_rounded,),
    };

    final badges =
        trip.accessibilityFeatures.where(badgeInfo.containsKey).map((key) {
      final info = badgeInfo[key]!;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              key == 'wheelchair'
                  ? l10n.tripAccessibilityWheelchairShort
                  : l10n.tripAccessibilityFamilyShort,
              style: (isAr
                      ? theme.textTheme.labelSmall ?? const TextStyle()
                      : const TextStyle(fontFamily: 'Tajawal'))
                  .copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }).toList();

    return badges;
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text,
      {Widget? trailing}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  void _showGuideDetailsPopUp(
      BuildContext context, AppLocalizations l10n, bool isAr) {
    final theme = Theme.of(context);
    final rating = trip.guideRating;
    final reviews = trip.guideReviewsCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: trip.tutorId == null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.tripGuideUnavailable),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(trip.tutorId)
                    .snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data() as Map<String, dynamic>?;
                  final liveName = data?['fullName'] as String? ?? trip.guide;
                  final bio = data?['bio'] as String? ?? trip.guideBio ?? '';
                  final languages =
                      (data?['languages'] as List<dynamic>?)?.cast<String>() ??
                          trip.guideLanguages ??
                          [];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment:
                            isAr ? Alignment.topLeft : Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            Text(
                              liveName,
                              style: (isAr
                                      ? theme.textTheme.titleLarge ??
                                          const TextStyle()
                                      : const TextStyle(fontFamily: 'Tajawal'))
                                  .copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (rating != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(
                                        5,
                                        (i) => Icon(
                                              i < rating.round()
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            )),
                                  ),
                                  if (reviews != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.tripReviewsCount(reviews),
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            if (bio.isNotEmpty) ...[
                              const SizedBox(height: 25),
                              Align(
                                alignment: isAr
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(
                                  bio,
                                  textAlign:
                                      isAr ? TextAlign.right : TextAlign.left,
                                  style: (isAr
                                          ? theme.textTheme.bodyMedium ??
                                              const TextStyle()
                                          : const TextStyle(
                                              fontFamily: 'Tajawal'))
                                      .copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.6,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                            if (languages.isNotEmpty) ...[
                              const SizedBox(height: 30),
                              Align(
                                alignment: isAr
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(l10n.languages,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.start,
                                  children: languages
                                      .map((lang) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: theme
                                                      .colorScheme.primary
                                                      .withValues(alpha: 0.5),
                                                  width: 1.5),
                                            ),
                                            child: Text(
                                              lang,
                                              style: (isAr
                                                      ? theme.textTheme
                                                              .labelSmall ??
                                                          const TextStyle()
                                                      : const TextStyle(
                                                          fontFamily:
                                                              'Tajawal'))
                                                  .copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
