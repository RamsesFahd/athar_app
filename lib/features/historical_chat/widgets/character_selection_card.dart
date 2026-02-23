import 'package:flutter/material.dart';

/// A card widget to display and select a historical figure for interaction.
class CharacterSelectionCard extends StatelessWidget {
  final String name, role, era;
  final VoidCallback onTap;

  const CharacterSelectionCard({
    super.key, 
    required this.name, 
    required this.role, 
    required this.era, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Character avatar container with structured branding alignment
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    'assets/images/athar_header_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Core identity and historical context details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    role, 
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  // Capsule-styled container for historical era visualization
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      era, 
                      style: const TextStyle(
                        color: Color(0xFF4A5D45),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Navigation indicator with directional awareness
            Icon(
              Icons.chevron_right, 
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}