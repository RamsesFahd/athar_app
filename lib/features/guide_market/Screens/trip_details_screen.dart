import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/core/models/favorites/favorite_item_model.dart';
import 'package:athar_app/core/utils/share_utils.dart';
import 'package:athar_app/features/profile/logic/favorites_notifier.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:athar_app/features/guide_market/screens/booking_form_screen.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripDetailsScreen extends ConsumerWidget {
  final TripModel trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final isCompany = trip.tutorType == 'company';

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ────────────────────────────────────────
                Image.network(
                  trip.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──────────────────────────────────────
                      Text(trip.getTitle(isAr),
                          style: theme.textTheme.displayLarge),
                      const SizedBox(height: 12),

                      // ── Price display ──────────────────────────────
                      _buildPriceRow(theme, isAr),
                      const SizedBox(height: 16),

                      // ── Accessibility badges ───────────────────────
                      if (trip.accessibilityFeatures.isNotEmpty)
                        _buildAccessibilityBadges(theme, isAr),

                      const SizedBox(height: 20),

                      // ── About section ──────────────────────────────
                      Text(l10n.about_trip,
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 12),

                      MarkdownBody(
                        data: trip.getDescription(isAr),
                        styleSheet: MarkdownStyleSheet(
                          p: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                          listBullet: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 16),
                          strong: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Tutor / company info ───────────────────────
                      _buildInfoRow(
                        context,
                        Icons.person_outline,
                        '${l10n.guide}: ${trip.guide}',
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
                      ),
                      _buildInfoRow(context, Icons.verified_outlined,
                          '${l10n.license}: ${trip.license}'),
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
                    Consumer(
                      builder: (ctx, consumerRef, _) {
                        final isFavAsync =
                            consumerRef.watch(isFavoriteProvider(trip.id));
                        final isFav = isFavAsync.value ?? false;
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

          // ── Book Now button ───────────────────────────────────────
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
                  onPressed: () {
                    ref
                        .read(bookingNotifierProvider.notifier)
                        .startBooking(trip);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingFormScreen(trip: trip),
                      ),
                    );
                  },
                  child: Text(l10n.book_now),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ThemeData theme, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // قسم البالغين
          _buildPriceItem(
            theme,
            label: isAr ? 'للبالغين' : 'Adults',
            price: '${trip.adultPrice.toInt()} ${isAr ? 'ر.س' : 'SAR'}',
            icon: Icons.person_outline,
          ),

          // فاصل عمودي نحيف جداً وأنيق
          Container(
            height: 30,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: theme.dividerColor.withOpacity(0.2),
          ),

          // قسم الأطفال
          _buildPriceItem(
            theme,
            label: isAr ? 'للأطفال' : 'Children',
            price: trip.childPrice == 0
                ? (isAr ? 'مجاناً' : 'Free')
                : '${trip.childPrice.toInt()} ${isAr ? 'ر.س' : 'SAR'}',
            icon: Icons.child_care_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(ThemeData theme,
      {required String label, required String price, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
            Text(
              price,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessibilityBadges(ThemeData theme, bool isAr) {
    const badgeInfo = {
      'wheelchair': (
        icon: Icons.accessible_forward_rounded,
        labelEn: 'Accessible',
        labelAr: 'صديق للإعاقة',
      ),
      'family': (
        icon: Icons.family_restroom_rounded,
        labelEn: 'مناسب للعائلات',
        labelAr: 'مناسب للعائلات',
      ),
    };

    final badges =
        trip.accessibilityFeatures.where(badgeInfo.containsKey).map((key) {
      final info = badgeInfo[key]!;
      return Container(
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              isAr ? info.labelAr : info.labelEn,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        runSpacing: 10,
        children: badges,
      ),
    );
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
          Text(text, style: theme.textTheme.bodyMedium),
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
    final bio = trip.guideBio;
    final languages = trip.guideLanguages ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: isAr ? Alignment.topLeft : Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Text(
                    trip.guide,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal'),
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
                            isAr
                                ? "($reviews تقييم)"
                                : "($reviews reviews)",
                            style:
                                TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (bio != null && bio.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        bio,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[600],
                          height: 1.6,
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                  if (languages.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Align(
                      alignment:
                          isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(l10n.languages,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.5),
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal'),
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
        ),
      ),
    );
  }
}
