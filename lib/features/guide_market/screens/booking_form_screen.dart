import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_stepper.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/features/guide_market/logic/booking_form_notifier.dart';
import 'package:athar_app/features/guide_market/screens/booking_summary_screen.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Multi-step booking form — step 1: select date, time, adults, and children.
/// Formerly booking_details_screen.dart — renamed for clarity (Issue I).
/// Form state is now held in [BookingFormNotifier] instead of setState (Issue K).
class BookingFormScreen extends ConsumerWidget {
  final TripModel trip;

  const BookingFormScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final form = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.booking_details,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                          l10n.people_count, Icons.people_outline, theme),
                      const SizedBox(height: 32),
                      _buildCounterRow(
                        title: l10n.adults,
                        subtitle: l10n.bookingAdultsAgeSubtitle,
                        count: form.adults,
                        onAdd: formNotifier.incrementAdults,
                        onRemove: formNotifier.decrementAdults,
                        theme: theme,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(thickness: 0.8, height: 1),
                      ),
                      _buildCounterRow(
                        title: l10n.children,
                        subtitle: l10n.bookingChildrenAgeSubtitle,
                        count: form.children,
                        onAdd: formNotifier.incrementChildren,
                        onRemove: formNotifier.decrementChildren,
                        theme: theme,
                      ),
                      const SizedBox(height: 48),
                      _buildSectionHeader(
                        l10n.bookingDateTimeTitle,
                        Icons.calendar_today_outlined,
                        theme,
                      ),
                      const SizedBox(height: 24),
                      _buildModernPickerTile(
                        label: l10n.date,
                        value: form.selectedDate == null
                            ? l10n.select
                            : form.selectedDate.toString().split(' ')[0],
                        icon: Icons.event_available,
                        onTap: () => _pickDate(context, formNotifier, trip),
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
                  onPressed: () => _onContinue(context, ref, form, isAr, l10n),
                  child: Text(
                    l10n.continue_btn,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
        Text(title, style: theme.textTheme.titleLarge),
      ],
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
        const Spacer(),
        _counterButton(Icons.remove, onRemove, theme, isEnabled: count > 1),
        SizedBox(
          width: 60,
          child: Center(
            child: Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ),
        ),
        _counterButton(Icons.add, onAdd, theme, isPrimary: true),
      ],
    );
  }

  Widget _counterButton(
    IconData icon,
    VoidCallback onTap,
    ThemeData theme, {
    bool isPrimary = false,
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface)
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Icon(
          icon,
          color: isPrimary
              ? theme.colorScheme.onPrimary
              : (isEnabled ? theme.colorScheme.primary : Colors.grey),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildModernPickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12)),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickDate(
      BuildContext context, BookingFormNotifier formNotifier, TripModel trip) async {
    final now = DateTime.now();
    final first = trip.startDate != null && trip.startDate!.isAfter(now)
        ? trip.startDate!
        : now;
    final last = trip.endDate ?? DateTime(now.year + 3);
    final date = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (date != null) formNotifier.selectDate(date);
  }

  void _onContinue(
    BuildContext context,
    WidgetRef ref,
    BookingFormState form,
    bool isAr,
     AppLocalizations l10n,
  ) {
    if (!form.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.bookingSelectDateError,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tripTime = trip.timeRange ?? trip.startTime ?? '';

    ref.read(bookingNotifierProvider.notifier).updateDetails(
          date: form.selectedDate.toString().split(' ')[0],
          time: tripTime,
          adults: form.adults,
          children: form.children,
          adultPrice: trip.adultPrice,
          childPrice: trip.childPrice,
          totalPrice:
              (trip.adultPrice * form.adults) + (trip.childPrice * form.children),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          tripTitle: trip.getTitle(isAr),
          guideName: trip.guide,
          date: form.selectedDate.toString().split(' ')[0],
          time: tripTime,
          adults: form.adults,
          children: form.children,
          adultPrice: trip.adultPrice,
          childPrice: trip.childPrice,
          totalPrice: (trip.adultPrice * form.adults) +
              (trip.childPrice * form.children),
          imageUrl: trip.imageUrl,
        ),
      ),
    );
  }
}
