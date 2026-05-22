import 'package:flutter/material.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/admin/screens/all_bookings_screen.dart';
import 'package:athar_app/features/admin/screens/trip_approvals_screen.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class TripBookingsScreen extends StatelessWidget {
  const TripBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.adminTripsTab),
                Tab(text: l10n.profileTabBooking),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                TripApprovalsScreen(),
                AllBookingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
