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
      default: return l10n.errorUnexpected;
    }
  }

  // Common divider for auth screens
  static Widget buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.orDivider,
            style: TextStyle(
              color: Colors.grey[400], 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}