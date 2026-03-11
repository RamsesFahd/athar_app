import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 
import 'package:athar_app/generated/l10n/app_localizations.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep; 

  const CustomStepper({super.key, required this.currentStep});

 @override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!; 
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildStep(1, l10n.trip),     
      _buildLine(),
      _buildStep(2, l10n.details),   
      _buildLine(),
      _buildStep(3, l10n.guide),     
      _buildLine(),
      _buildStep(4, l10n.confirm),   
    ],
  );
}

  Widget _buildStep(int step, String title) {
    bool isActive = step <= currentStep;
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive ? AppColors.sage500 : Colors.grey[300],
          child: Text("$step", style: const TextStyle(color: Colors.white)),
        ),
        Text(title, style: TextStyle(fontSize: 10, color: isActive ? AppColors.sage500 : Colors.grey)),
      ],
    );
  }

  Widget _buildLine() => Container(width: 30, height: 2, color: Colors.grey[300], margin: const EdgeInsets.only(bottom: 15));
}