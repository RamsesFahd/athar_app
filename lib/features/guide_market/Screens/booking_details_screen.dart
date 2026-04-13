import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_stepper.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/features/guide_market/Screens/booking_summary_screen.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final TripModel trip;
  const BookingDetailsScreen({super.key, required this.trip});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  int adults = 1;
  int children = 0;
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> availableTimes = [
    "8:00 AM - 11:00 AM",
    "9:00 AM - 1:00 PM",
    "11:00 AM - 2:00 PM",
    "1:00 PM - 5:00 PM",
    "4:00 PM - 8:00 PM",
    "6:00 PM - 9:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';


    return Scaffold(
    appBar: AppBar(
  title: Text(
    l10n.booking_details, 
    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18), // تقليل الحجم قليلاً ليتناسب مع الهيدر
  ),
  centerTitle: true,
),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const CustomStepper(currentStep: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.all(28), // تكبير الحشوة الداخلية للحاوية
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16), // زوايا أنعم قليلاً
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(l10n.people_count, Icons.people_outline, theme),
                      const SizedBox(height: 32), // مساحة أكبر
                      _buildCounterRow(
                        title: l10n.adults,
                        subtitle: isAr ? "12 سنة فما فوق" : "12+ years",
                        count: adults,
                        onAdd: () => setState(() => adults++),
                        onRemove: () => setState(() { if (adults > 1) adults--; }),
                        theme: theme,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(thickness: 0.8, height: 1),
                      ),
                      _buildCounterRow(
                        title: l10n.children,
                        subtitle: isAr ? "تحت 12 سنة" : "Under 12 years",
                        count: children,
                        onAdd: () => setState(() => children++),
                        onRemove: () => setState(() { if (children > 0) children--; }),
                        theme: theme,
                      ),
                      const SizedBox(height: 48), // مساحة فصل أكبر
                      _buildSectionHeader(
                        isAr ? "التاريخ والوقت" : "Date & Time",
                        Icons.calendar_today_outlined, 
                        theme
                      ),
                      const SizedBox(height: 24),
                      _buildModernPickerTile(
                        label: l10n.date,
                        value: selectedDate == null ? l10n.select : selectedDate.toString().split(' ')[0],
                        icon: Icons.event_available,
                        onTap: _pickDate,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _buildModernPickerTile(
                        label: l10n.time,
                        value: selectedTime == null 
                        ? l10n.select 
                        : (isAr ? selectedTime!.replaceAll('AM', 'ص').replaceAll('PM', 'م') : selectedTime!),
                        icon: Icons.schedule,
                        onTap: () => _showTimePickerSheet(theme, l10n),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 62, 
                child: ElevatedButton(
                  onPressed: _onContinue,
                  child: Text(
                    l10n.continue_btn,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
      const SizedBox(width: 16),
      Text(
        title, 
        style: theme.textTheme.titleLarge, 
      ),
    ],
  );
}

  Widget _buildCounterRow({required String title, required String subtitle, required int count, required VoidCallback onAdd, required VoidCallback onRemove, required ThemeData theme}) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
        const Spacer(),
        _counterButton(Icons.remove, onRemove, theme, isEnabled: count > 1),
        SizedBox(
          width: 60,
          child: Center(child: Text("$count", style: theme.textTheme.titleLarge?.copyWith(fontSize: 22))),
        ),
        _counterButton(Icons.add, onAdd, theme, isPrimary: true),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap, ThemeData theme, {bool isPrimary = false, bool isEnabled = true}) {
  return InkWell(
    onTap: isEnabled ? onTap : null,
    customBorder: const CircleBorder(), 
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(10), 
      decoration: BoxDecoration(
        color: isEnabled 
          ? (isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface) 
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1), 
        shape: BoxShape.circle, 
        border: isPrimary ? null : Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Icon(
        icon, 
        color: isPrimary ? theme.colorScheme.onPrimary : (isEnabled ? theme.colorScheme.primary : Colors.grey), 
        size: 20, 
      ),
    ),
  );
}

  Widget _buildModernPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap, required ThemeData theme}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Text(label, style: theme.textTheme.bodyLarge), 
          const Spacer(),
          Text(
            value, 
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        ],
      ),
    ),
  );
}

  
  void _showTimePickerSheet(ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(l10n.select_time, style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.2, 
              ),
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                final time = availableTimes[index];
                final isSelected = selectedTime == time;
                final isAr = Localizations.localeOf(context).languageCode == 'ar';

                return InkWell(
                  onTap: () {
                    setState(() => selectedTime = time);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isAr ? time.replaceAll('AM', 'ص').replaceAll('PM', 'م') : time,
                        style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? theme.colorScheme.primary : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _onContinue() {
    if (selectedDate != null && selectedTime != null) {
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      ref.read(bookingNotifierProvider.notifier).updateDetails(
        date: selectedDate.toString().split(' ')[0],
        time: selectedTime!,
        adults: adults,
        children: children,
        adultPrice: widget.trip.adultPrice,
        childPrice: widget.trip.childPrice,
        totalPrice: (widget.trip.adultPrice * adults) + (widget.trip.childPrice * children),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSummaryScreen(
            tripTitle: widget.trip.getTitle(isAr),
            guideName: "أثر - مرشدك السياحي",
            date: selectedDate.toString().split(' ')[0],
            time: selectedTime!,
            adults: adults,
            children: children,
            totalPrice: (widget.trip.adultPrice * adults) + (widget.trip.childPrice * children),
            imageUrl: widget.trip.imageUrl,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Localizations.localeOf(context).languageCode == 'ar' ? "يرجى اختيار التاريخ والوقت للمتابعة" : "Please select date and time"),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
}