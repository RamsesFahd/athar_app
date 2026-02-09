import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, outline }

class AtharButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;

  const AtharButton({super.key, required this.label, required this.onPressed, this.variant = ButtonVariant.primary});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == ButtonVariant.primary ? AppColors.primary : Colors.transparent,
        foregroundColor: variant == ButtonVariant.primary ? Colors.white : AppColors.primary,
        side: variant == ButtonVariant.outline ? const BorderSide(color: AppColors.primary) : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}