import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../widgets/saved_card.dart';


class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Page title
        title: Text(l10n.savedTitle, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            // Saved card 
            SavedCard(),
            SavedCard(),
            SavedCard(),
          ],
        ),
      ),
    );
  }
}