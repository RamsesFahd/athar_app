import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/core/navigation/app_routes.dart';
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
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

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
                    crossAxisAlignment: CrossAxisAlignment.start, // لضمان محاذاة العناصر لليمين في العربي
                    children: [
                      // قسم صورة العنوان والرحلة
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(widget.imageUrl,
                                width: 90, height: 90, fit: BoxFit.cover),
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

                      // تفاصيل الحجز (البيانات ملاصقة الآن)
                      _buildInfoRow(Icons.person_outline, l10n.guide, widget.guideName, theme),
                      _buildInfoRow(Icons.calendar_today, l10n.date, widget.date, theme),
                      _buildInfoRow(Icons.access_time, l10n.time, widget.time, theme),
                      _buildInfoRow(
                        Icons.people_outline,
                        l10n.people_count,
                        isAr
                            ? "${widget.adults} بالغ، ${widget.children} طفل"
                            : "${widget.adults} Adults, ${widget.children} Children",
                        theme,
                      ),

                      const SizedBox(height: 10),
                      _buildPriceBreakdown(l10n, theme, isAr),

                      const Spacer(),

                      // قسم التنويه
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
            ),
            const SizedBox(height: 16),

            // زر إتمام الحجز
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirmBooking,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(l10n.complete_booking),
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
        const SnackBar(content: Text('Booking confirmed!'), backgroundColor: Colors.green),
      );
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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

  Widget _buildPriceBreakdown(AppLocalizations l10n, ThemeData theme, bool isAr) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            
            _priceRow(
              isAr
                  ? '${widget.adults} بالغ × ${widget.adultPrice.toInt()} ر.س'
                  : '${widget.adults} Adult × ${widget.adultPrice.toInt()} SAR',
              '${(widget.adults * widget.adultPrice).toInt()} ${l10n.currency}',
              theme,
            ),
            
            
            if (widget.children > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _priceRow(
                  widget.childPrice == 0
                      ? (isAr ? '${widget.children} طفل (مجاناً)' : '${widget.children} Child (Free)')
                      : (isAr
                          ? '${widget.children} طفل × ${widget.childPrice.toInt()} ر.س'
                          : '${widget.children} Child × ${widget.childPrice.toInt()} SAR'),
                  widget.childPrice == 0
                      ? (isAr ? 'مجاناً' : 'Free')
                      : '${(widget.children * widget.childPrice).toInt()} ${l10n.currency}',
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
            Text(
             '${widget.totalPrice.toInt()} ${l10n.currency}',
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
  Widget _priceRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
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
          Text(
            value,
            style: isTotal
                ? theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}