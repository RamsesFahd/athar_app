import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ButtonVariant { primary, outline }

class AtharButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool isLoading; // added for loading state

  const AtharButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false, // default to false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: variant == ButtonVariant.primary
              ? AppColors.primary
              : Colors.white,
          foregroundColor: variant == ButtonVariant.primary
              ? Colors.white
              : AppColors.primary,
          elevation: 0,
          side: variant == ButtonVariant.outline
              ? const BorderSide(color: AppColors.primary, width: 1.5)
              : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          // handle disabled state based on isLoading
          disabledBackgroundColor: variant == ButtonVariant.primary
              ? AppColors.sage500
              : Colors.white,
        ),
        // disable the button when loading to prevent multiple taps (New)
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant == ButtonVariant.primary
                      ? Colors.white
                      : AppColors.primary,
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
