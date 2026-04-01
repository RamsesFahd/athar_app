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
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

  return Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context)!.booking_summary)),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CustomStepper(currentStep: 4),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.imageUrl, width: 80, height: 80, fit: BoxFit.cover)),
                        const SizedBox(width: 16),
                        Expanded(child: Text(widget.tripTitle, style: theme.textTheme.titleLarge)),
                      ],
                    ),
                    const Divider(height: 30),
                    
_buildInfoRow(Icons.person_outline, l10n.guide, widget.guideName, theme),
_buildInfoRow(Icons.calendar_today, l10n.date, widget.date, theme),
_buildInfoRow(Icons.access_time, l10n.time, widget.time, theme),
_buildInfoRow(Icons.people_outline, l10n.people_count, 
    isAr ? "${widget.adults} بالغ، ${widget.children} طفل" : "${widget.adults} Adults, ${widget.children} Children", 
    theme),
_buildPriceBreakdown(l10n, theme, isAr),

const Spacer(), 

                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 20, color: Colors.grey.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l10n.payment_note, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          
          SizedBox(
  width: double.infinity,
  height: 56, 
  child: ElevatedButton(
    onPressed: _isLoading
        ? null
        : () async {
            setState(() => _isLoading = true);
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            try {
              await ref
                  .read(bookingNotifierProvider.notifier)
                  .confirmBooking();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed!'),
                  backgroundColor: Colors.green,
                ),
              );
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            } catch (e) {
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary, 
      foregroundColor: Colors.white, // لون النص
      elevation: 2, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
      ),
    ),
    child: _isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          )
        : Text(
            l10n.complete_booking,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
  ),
),
        ],
      ),
    ),
  );
}
  Widget _buildModernTextField(String label, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
          child: Text(
            label, 
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold, 
              color: theme.colorScheme.primary 
            )
          ),
        ),
        TextField(
          style: theme.textTheme.bodyLarge, 
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.colorScheme.surface, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3))
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(AppLocalizations l10n, ThemeData theme, bool isAr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text('${l10n.total_price}: ',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _priceRow(
                  isAr
                      ? '${widget.adults} بالغ × ${widget.adultPrice.toInt()} ر.س'
                      : '${widget.adults} Adult × ${widget.adultPrice.toInt()} SAR',
                  '${(widget.adults * widget.adultPrice).toInt()} ${l10n.currency}',
                  theme,
                ),
                if (widget.children > 0)
                  _priceRow(
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
                const Divider(height: 12),
                _priceRow(
                  l10n.total_price,
                  '${widget.totalPrice.toInt()} ${l10n.currency}',
                  theme,
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, ThemeData theme,
      {bool bold = false}) {
    final style = bold
        ? theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
        : theme.textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text("$label: ", style: theme.textTheme.bodySmall),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}