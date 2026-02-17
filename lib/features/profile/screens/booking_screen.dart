import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../widgets/booking_card.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Page title
        title: Text(l10n.upcomingBookingTitle, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Booking card 
            BookingCard(detailsText: l10n.detailsButton),

            // Booking card 
            BookingCard(detailsText: l10n.detailsButton),
          ],
        ),
      ),
    );
  }
}