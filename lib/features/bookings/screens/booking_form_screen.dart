import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/contribution/user_reward_model.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/core/models/booking/trip_model.dart';
import 'package:athar_app/features/auth/logic/auth_notifier.dart';
import 'package:athar_app/features/bookings/logic/booking_repository.dart';
import 'package:athar_app/features/bookings/logic/booking_notifier.dart';
import 'package:athar_app/features/bookings/logic/booking_form_notifier.dart';
import 'package:athar_app/features/bookings/screens/booking_summary_screen.dart';
import 'package:athar_app/features/bookings/widgets/custom_stepper.dart';
import 'package:athar_app/features/guide_market/logic/trips_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Multi-step booking form — step 1: select date, time, adults, and children.
class BookingFormScreen extends ConsumerWidget {
  final TripModel trip;

  const BookingFormScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final form = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final rewardsAsync = currentUser is TouristModel
        ? ref.watch(unusedRewardsProvider(currentUser.uId))
        : const AsyncValue<List<UserRewardModel>>.data([]);
    final rewards = rewardsAsync.valueOrNull ?? const <UserRewardModel>[];
    UserRewardModel? freeTripReward;
    for (final reward in rewards) {
      if (reward.type == 'free_trip' && !reward.isUsed) {
        freeTripReward = reward;
        break;
      }
    }
    final availableFreeTripReward = freeTripReward;
    final bookedDates = trip.isPrivate
        ? ref.watch(bookedDatesForTripProvider(trip.id)).valueOrNull
        : null;
    final guideBookedDates = (trip.tutorType == 'individual' &&
            trip.tutorId != null &&
            trip.tutorId!.isNotEmpty)
        ? ref
            .watch(bookedDatesForGuideProvider(
                (tutorId: trip.tutorId!, currentTripId: trip.id)))
            .valueOrNull
        : null;

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
                        canIncrement: trip.availableSeats == null ||
                            _adultEquivalent(form) + 1 <= trip.availableSeats!,
                        theme: theme,
                      ),
                      if (trip.allowsKids) ...[
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
                          canIncrement: trip.availableSeats == null ||
                              (form.adults + ((form.children + 2) ~/ 2)) <=
                                  trip.availableSeats!,
                          minCount: 0,
                          theme: theme,
                        ),
                      ],
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
                        onTap: () => _pickDate(
                            context, formNotifier, trip, bookedDates, guideBookedDates),
                        theme: theme,
                      ),
                      if (availableFreeTripReward != null) ...[
                        const SizedBox(height: 12),
                        _buildRewardOptionTile(
                          reward: availableFreeTripReward,
                          isSelected: form.selectedRewardId ==
                              availableFreeTripReward.id,
                          onChanged: (selected) {
                            if (selected) {
                              formNotifier.selectReward(
                                rewardId: availableFreeTripReward.id,
                                rewardType: availableFreeTripReward.type,
                              );
                            } else {
                              formNotifier.clearReward();
                            }
                          },
                          l10n: l10n,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 62),
                  child: ElevatedButton(
                    onPressed: () =>
                        _onContinue(context, ref, form, isAr, l10n),
                    child: Text(
                      l10n.continue_btn,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
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
    bool canIncrement = true,
    int minCount = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
        ),
        const SizedBox(width: 12),
        _counterButton(Icons.remove, onRemove, theme, isEnabled: count > minCount),
        SizedBox(
          width: 60,
          child: Center(
            child: Text(
              '$count',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ),
        ),
        _counterButton(Icons.add, onAdd, theme,
            isPrimary: true, isEnabled: canIncrement),
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
              : (isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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

  Widget _buildRewardOptionTile({
    required UserRewardModel reward,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
        title: Text(
          l10n.useRewardOption,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isSelected ? l10n.rewardApplied : l10n.freeTripRewardUnlockedMessage,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  // Returns the adult-equivalent seat count: 2 children = 1 adult slot.
  int _adultEquivalent(BookingFormState form) =>
      form.adults + ((form.children + 1) ~/ 2);

  double _rawTotal(BookingFormState form) {
    return (trip.adultPrice * form.adults) + (trip.childPrice * form.children);
  }

  double _totalWithReward(BookingFormState form) {
    final total = _rawTotal(form);
    if (form.selectedRewardType == 'free_trip') {
      return (total - trip.adultPrice).clamp(0.0, total).toDouble();
    }
    return total;
  }

  Future<void> _pickDate(
    BuildContext context,
    BookingFormNotifier formNotifier,
    TripModel trip,
    Set<String>? bookedDates,
    Set<String>? guideBookedDates,
  ) async {
    final now = DateTime.now();
    // Earliest selectable day is tomorrow — guide must have 24h to respond.
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final first = (trip.startDate != null && trip.startDate!.isAfter(tomorrow))
        ? trip.startDate!
        : tomorrow;
    final last = trip.endDate ?? DateTime(now.year + 3);

    bool isDayBlocked(DateTime day) {
      final key = '${day.year.toString().padLeft(4, '0')}-'
          '${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';
      if (bookedDates?.contains(key) ?? false) return true;
      if (guideBookedDates?.contains(key) ?? false) return true;
      return false;
    }

    final hasAnyBlockedDates = bookedDates != null || guideBookedDates != null;

    final date = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: last,
      selectableDayPredicate:
          hasAnyBlockedDates ? (day) => !isDayBlocked(day) : null,
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
          content: Text(l10n.bookingSelectDateError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tripTime = trip.timeRange ?? trip.startTime ?? '';
    final rawTotal = _rawTotal(form);
    final totalWithReward = _totalWithReward(form);
    final rewardDiscountAmount = rawTotal - totalWithReward;

    ref.read(bookingNotifierProvider.notifier).updateDetails(
          date: form.selectedDate.toString().split(' ')[0],
          time: tripTime,
          adults: form.adults,
          children: form.children,
          adultPrice: trip.adultPrice,
          childPrice: trip.childPrice,
          totalPrice: totalWithReward,
          rewardId: form.selectedRewardId,
          rewardType: form.selectedRewardType,
          rewardDiscountAmount: rewardDiscountAmount,
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
          totalPrice: totalWithReward,
          imageUrl: trip.imageUrl,
          tripDurationDays: trip.tripDurationDays,
          rewardApplied: form.selectedRewardId != null,
          rewardDiscountAmount: rewardDiscountAmount,
        ),
      ),
    );
  }
}
