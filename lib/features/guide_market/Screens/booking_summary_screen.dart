import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../widgets/custom_stepper.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String tripTitle;
  final String guideName;
  final String date;
  final String time;
  final int adults;
  final int children;
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
    required this.totalPrice,
    required this.imageUrl,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {

  
  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context)!; 
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
_buildInfoRow(Icons.payments, l10n.total_price, "${widget.totalPrice.toStringAsFixed(2)} ${l10n.currency}", theme),

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
    onPressed: () {
      // ضعي هنا كود الـ Navigator الخاص بكِ
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary, 
      foregroundColor: Colors.white, // لون النص
      elevation: 2, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
      ),
    ),
   child: Text(l10n.complete_booking,
      style: TextStyle(
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