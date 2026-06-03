import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class AuthUtils {
  // Mapping backend error keys to localized strings
  static String translateError(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'errorEmailAlreadyInUse': return l10n.errorEmailAlreadyInUse;
      case 'errorInvalidEmail': return l10n.errorInvalidEmail;
      case 'errorUserNotFound': return l10n.errorUserNotFound;
      case 'errorWrongPassword': return l10n.errorWrongPassword;
      case 'errorWeakPassword': return l10n.errorWeakPassword;
      case 'errorEmailNotVerified': return l10n.errorEmailNotVerified;
      default: return l10n.errorUnexpected;
    }
  }

  static Widget buildDivider(AppLocalizations l10n) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orDivider,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        );
      },
    );
  }
}
