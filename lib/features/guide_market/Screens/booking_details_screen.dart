import 'package:flutter/material.dart';
import '../widgets/custom_stepper.dart';
import 'package:athar_app/features/guide_market/screens/booking_summary_screen.dart';
import 'package:athar_app/features/guide_market/screens/guide_selection_screen.dart';
import 'package:athar_app/core/models/trip/trip.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';


class BookingDetailsScreen extends StatefulWidget {
  final Trip trip;
  const BookingDetailsScreen({super.key, required this.trip});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int adults = 1;
  int children = 0;
  DateTime? selectedDate;
  String? selectedTime; // تغير من TimeOfDay إلى String

  // القائمة الثابتة للأوقات
  final List<String> availableTimes = [
    "9:00 ص - 1:00 م",
    "1:00 م - 5:00 م",
    "4:00 م - 8:00 م",
  ];

  void _showTimeSelectionSheet(ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.select_time, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...availableTimes.map((time) => ListTile(
              title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.access_time, color: theme.colorScheme.primary),
              onTap: () {
                setState(() => selectedTime = time);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showPeopleDialog(ThemeData theme, AppLocalizations l10n) {
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.people_count, style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCounterRow(l10n.adults, Icons.person, adults,
              () => setDialogState(() => adults++), () => setDialogState(() { if (adults > 1) adults--; }), theme),
            const Divider(),
            _buildCounterRow(l10n.children, Icons.child_care, children,
              () => setDialogState(() => children++), () => setDialogState(() { if (children > 0) children--; }), theme),
          ],
        ),
        actions: [TextButton(onPressed: () { setState(() {}); Navigator.pop(context); }, child: Text(l10n.done))],
      ),
    ),
  );
}

  Widget _buildCounterRow(String title, IconData icon, int count, VoidCallback onAdd, VoidCallback onRemove, ThemeData theme) {
    return Row(children: [
      Icon(icon, color: theme.colorScheme.primary),
      const SizedBox(width: 10),
      Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      const Spacer(),
      IconButton(onPressed: onRemove, icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.primary)),
      Text("$count", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      IconButton(onPressed: onAdd, icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary)),
    ]);
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.booking_details)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CustomStepper(currentStep: 2),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildActionRow(
                     l10n.people_count,
                     Icons.group,
                    isAr ? "$adults بالغ، $children طفل" : "$adults Adults, $children Children",
                    () => _showPeopleDialog(theme, l10n),
                     theme,
                     ),
                    _buildActionRow(
                     l10n.date,
                    Icons.calendar_today,
                    selectedDate == null ? l10n.select : selectedDate.toString().split(' ')[0],
                    () async {
                    DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                    builder: (context, child) {
                    return Theme(
                    data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: theme.colorScheme.primary,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.all(Colors.black),
              todayForegroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
              yearForegroundColor: WidgetStateProperty.all(Colors.black),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => selectedDate = date);
  },
  theme,
),
_buildActionRow(
                    l10n.time,
                    Icons.access_time,
                    selectedTime ?? l10n.select,
                    () => _showTimeSelectionSheet(theme, l10n),
                    theme,
                  ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity, 
                height: 56,
                child: ElevatedButton(
  onPressed: () {
    if (selectedDate != null && selectedTime != null) {
      // ننتقل لصفحة اختيار المرشد أولاً ونمرر لها البيانات
      Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => GuideSelectionScreen(
    tripTitle: widget.trip.getTitle(isAr), 
    tripPrice: double.tryParse(widget.trip.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0,
    date: selectedDate.toString().split(' ')[0],
    time: selectedTime!,
    adults: adults,
    children: children,
    imageUrl: widget.trip.imageUrl,
  ),
),
);
    } else {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.complete_data)));
    }
  },
  child: Text(l10n.continue_btn),
),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon, String value, VoidCallback onTap, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: 150, 
            child: OutlinedButton(
              onPressed: onTap,
              child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}