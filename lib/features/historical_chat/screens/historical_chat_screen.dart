import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import '../widgets/character_selection_card.dart';
import '../widgets/chat_bubble.dart';

class HistoricalChatScreen extends StatefulWidget {
  const HistoricalChatScreen({super.key});

  @override
  State<HistoricalChatScreen> createState() => _HistoricalChatScreenState();
}

class _HistoricalChatScreenState extends State<HistoricalChatScreen> {
  // Unique identifier to manage dynamic translation state
  String? selectedCharacterId;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  /// Handles the message submission and simulated response logic
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _messages.add({"text": _controller.text, "isUser": true});
      _controller.clear();
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "text": l10n.historicalChatSubtitle, 
            "isUser": false
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Dynamic data mapping to handle real-time language switching
    final characterData = {
      'ibnSina': {'name': l10n.ibnSina, 'role': l10n.ibnSinaRole, 'era': l10n.ibnSinaEra, 'image': 'assets/images/athar_header_logo.png'},
      'khwarizmi': {'name': l10n.khwarizmi, 'role': l10n.khwarizmiRole, 'era': l10n.khwarizmiEra, 'image': 'assets/images/athar_header_logo.png'},
      'ibnHaytham': {'name': l10n.ibnHaytham, 'role': l10n.ibnHaythamRole, 'era': l10n.ibnHaythamEra, 'image': 'assets/images/athar_header_logo.png'},
      'firnas': {'name': l10n.firnas, 'role': l10n.firnasRole, 'era': l10n.firnasEra, 'image': 'assets/images/athar_header_logo.png'},
    };

    final currentCharacter = selectedCharacterId != null ? characterData[selectedCharacterId] : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
       toolbarHeight: 56,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ensures the back button and title align based on local directionality
        centerTitle: false,
        title: selectedCharacterId == null 
            ? Text(l10n.historicalChatTitle, style: theme.textTheme.displayLarge?.copyWith(fontSize: 22))
             : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    currentCharacter!['image'] as String,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentCharacter['name'] as String, 
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        currentCharacter['role'] as String,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
        leading: selectedCharacterId != null 
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.colorScheme.primary),
                onPressed: () => setState(() {
                  selectedCharacterId = null;
                  _messages.clear();
                }),
              ) 
            : null,
      ),
      body: selectedCharacterId == null ? _buildList(theme, l10n) : _buildChat(theme, l10n, currentCharacter!['image'] as String),
    );
  }

  /// Builds the character selection menu with strict alignment to text direction
  Widget _buildList(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.historicalChatSubtitle, 
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        _buildSelectionCard('ibnSina', l10n.ibnSina, l10n.ibnSinaRole, l10n.ibnSinaEra),
        const SizedBox(height: 12),
        _buildSelectionCard('khwarizmi', l10n.khwarizmi, l10n.khwarizmiRole, l10n.khwarizmiEra),
        const SizedBox(height: 12),
        _buildSelectionCard('ibnHaytham', l10n.ibnHaytham, l10n.ibnHaythamRole, l10n.ibnHaythamEra),
        const SizedBox(height: 12),
        _buildSelectionCard('firnas', l10n.firnas, l10n.firnasRole, l10n.firnasEra),
      ],
    );
  }

  /// Helper to instantiate selection cards using identifier-based logic
  Widget _buildSelectionCard(String id, String name, String role, String era) {
    return CharacterSelectionCard(
      name: name,
      role: role,
      era: era,
      onTap: () => setState(() => selectedCharacterId = id),
    );
  }

  /// Manages the active chat session interface and message list
  Widget _buildChat(ThemeData theme, AppLocalizations l10n, String imagePath) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) => ChatBubble(
              message: _messages[index]['text'],
              isUser: _messages[index]['isUser'],
              characterImage: imagePath, 
            ),
          ),
        ),
        _buildInput(theme, l10n),
      ],
    );
  }

  /// Renders the localized input field and submission control
  Widget _buildInput(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1)))
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.grey),
            onPressed: () {}, 
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.chatInputHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), 
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3))
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5D45), 
                borderRadius: BorderRadius.circular(8), 
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.send, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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