import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum ButtonVariant { primary, outline }

class AtharButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading; // added for loading state

  const AtharButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false, // default to false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPrimary = variant == ButtonVariant.primary;
    final isHighContrast = theme.isHighContrast;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? colorScheme.primary : colorScheme.surface,
          foregroundColor:
              isPrimary ? colorScheme.onPrimary : colorScheme.primary,
          elevation: 0,
          side: variant == ButtonVariant.outline
              ? BorderSide(
                  color: colorScheme.outline,
                  width: isHighContrast ? 2 : 1.5,
                )
              : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          // handle disabled state based on isLoading
          disabledBackgroundColor:
              isPrimary ? colorScheme.onSurfaceVariant : colorScheme.surface,
          disabledForegroundColor:
              isPrimary ? colorScheme.surface : colorScheme.onSurfaceVariant,
        ),
        // disable the button when loading to prevent multiple taps (New)
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      isPrimary ? colorScheme.onPrimary : colorScheme.primary,
                ),
              )
            : Text(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
