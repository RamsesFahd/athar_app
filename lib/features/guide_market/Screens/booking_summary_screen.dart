import 'package:cached_network_image/cached_network_image.dart';
import 'package:athar_app/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
import 'package:athar_app/core/theme/app_theme.dart';
import '../widgets/custom_stepper.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final String tripTitle;
  final String guideName;
  final String date;
  final String time;
  final int adults;
  final int children;
  final double adultPrice;
  final double childPrice;
  final double totalPrice;
  final String imageUrl;
  final int? tripDurationDays;
  final bool rewardApplied;
  final double rewardDiscountAmount;

  const BookingSummaryScreen({
    super.key,
    required this.tripTitle,
    required this.guideName,
    required this.date,
    required this.time,
    required this.adults,
    required this.children,
    this.adultPrice = 0.0,
    this.childPrice = 0.0,
    required this.totalPrice,
    required this.imageUrl,
    this.tripDurationDays,
    this.rewardApplied = false,
    this.rewardDiscountAmount = 0.0,
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isLoading = false;

  String _displayDate() {
    final duration = widget.tripDurationDays ?? 1;
    if (duration <= 1) return widget.date;
    final start = DateTime.tryParse(widget.date);
    if (start == null) return widget.date;
    final end = start.add(Duration(days: duration - 1));
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.booking_summary),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CustomStepper(currentStep: 2),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                ),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // قسم صورة العنوان والرحلة
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => ColoredBox(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      widget.tripTitle,
                                      style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 40),

                              _buildInfoRow(Icons.person_outline, l10n.guide, widget.guideName, theme),
                              _buildInfoRow(Icons.calendar_today, l10n.date, _displayDate(), theme),
                              _buildInfoRow(Icons.access_time, l10n.time, widget.time, theme),
                              _buildInfoRow(
                                Icons.people_outline,
                                l10n.people_count,
                                l10n.bookingPeopleSummary(
                                  widget.adults,
                                  widget.children,
                                ),
                                theme,
                              ),

                              const SizedBox(height: 10),
                              _buildPriceBreakdown(l10n, theme),
                              const SizedBox(height: 16),

                              // قسم التنويه — يتمرر مع باقي بيانات الحجز
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline, size: 24, color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.payment_note,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // زر إتمام الحجز
            SizedBox(
              width: double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirmBooking,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : Text(
                          l10n.complete_booking,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirmBooking() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(bookingNotifierProvider.notifier).confirmBooking();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).bookingConfirmedMessage),
          backgroundColor: Theme.of(context).semanticSuccess,
        ),
      );
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final errorText = e.toString();
      final msg = errorText.contains('tripDayAlreadyBookedError')
          ? l10n.tripDayAlreadyBookedError
          : errorText.contains('rewardUnavailable')
              ? l10n.rewardUnavailable
              : l10n.commonErrorWithMessage('');
      messenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          
          Text(
            "$label: ",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible( 
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(AppLocalizations l10n, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            
            _priceRow(
              l10n.bookingAdultPriceLine(
                widget.adults,
                CurrencyFormatter.formatNumber(widget.adultPrice),
              ),
              CurrencyFormatter.format(widget.adults * widget.adultPrice),
              theme,
            ),

            if (widget.children > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _priceRow(
                  widget.childPrice == 0
                      ? l10n.bookingChildFreeLine(widget.children)
                      : l10n.bookingChildPriceLine(
                          widget.children,
                          CurrencyFormatter.formatNumber(widget.childPrice),
                        ),
                  widget.childPrice == 0
                      ? Text(l10n.commonFree)
                      : CurrencyFormatter.format(widget.children * widget.childPrice),
                  theme,
                ),
              ),
            if (widget.rewardApplied && widget.rewardDiscountAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _priceRow(
                  l10n.rewardApplied,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '-',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CurrencyFormatter.format(
                        widget.rewardDiscountAmount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  theme,
                ),
              ),
          ],
        ),
      ),

      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Divider(thickness: 1), 
      ),

      
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.total_price,
        style: theme.textTheme.bodyLarge?.copyWith( 
          fontWeight: FontWeight.bold, 
          color: theme.colorScheme.primary,
        ),
      ),
            CurrencyFormatter.format(
              widget.totalPrice,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  Widget _priceRow(String label, Widget value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
          DefaultTextStyle.merge(
            style: isTotal
                ? theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium!,
            child: value,
          ),
        ],
      ),
    );
  }
}
