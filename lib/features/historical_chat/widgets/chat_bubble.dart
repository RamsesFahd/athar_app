import 'package:flutter/material.dart';

/// A professional chat bubble widget designed to match the historical interface prototype.
/// It incorporates dynamic alignment, brand-specific colors, and integrated timestamps.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? characterImage;

  const ChatBubble({
    super.key, 
    required this.message, 
    required this.isUser,
    this.characterImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        // Handles alignment based on both user type and text directionality
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.asset(
                  characterImage ?? 'assets/images/athar_header_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF4A5D45) 
                    : const Color(0xFFF2F2F2),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16),
                  topEnd: const Radius.circular(16),
                  bottomStart: Radius.circular(isUser ? 16 : 0),
                  bottomEnd: Radius.circular(isUser ? 0 : 16),
                ),
              ),
              child: Column(
                // Ensures internal text alignment follows the bubble owner
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "٨:٥٠ ص", 
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser 
                         ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}