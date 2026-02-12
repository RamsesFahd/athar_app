import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, outline }

class AtharButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;

  const AtharButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: variant == ButtonVariant.primary ? AppColors.primary : Colors.white,
          foregroundColor: variant == ButtonVariant.primary ? Colors.white : AppColors.primary,
          elevation: 0,
          side: variant == ButtonVariant.outline 
              ? const BorderSide(color: AppColors.primary, width: 1.5) 
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}