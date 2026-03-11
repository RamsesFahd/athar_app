
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CompanyBadge extends StatelessWidget {
  final String companyName;

  const CompanyBadge({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sage50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.sage800),
          const SizedBox(width: 4),
          Text(companyName, style: const TextStyle(fontSize: 12, color: AppColors.sage800)),
        ],
      ),
    );
  }
}