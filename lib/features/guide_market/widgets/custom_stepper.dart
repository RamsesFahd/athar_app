import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;

  const CustomStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // سحب الأخضر الغامق من الثيم (Primary)
    final Color activeColor = theme.colorScheme.primary; 
    // لون رمادي فاتح جداً للخطوات غير النشطة
    final Color inactiveColor = theme.colorScheme.primary.withOpacity(0.1);
    final Color inactiveTextColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          // الخطوة 1: التفاصيل
          _buildStep(l10n.details, currentStep >= 1, activeColor,
              inactiveColor, inactiveTextColor),
          const SizedBox(width: 12),
          // الخطوة 2: التأكيد
          _buildStep(l10n.confirm, currentStep >= 2, activeColor,
              inactiveColor, inactiveTextColor),
        ],
      ),
    );
  }

  Widget _buildStep(String title, bool isActive, Color activeColor,
      Color inactiveColor, Color inactiveTextColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : inactiveTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
