import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/core/theme/app_colors.dart';
import 'package:athar_app/features/auth/logic/auth_repository.dart';
import 'package:athar_app/features/historical_chat/logic/chat_repository.dart';
import 'package:athar_app/features/historical_chat/screens/chat_screen.dart';
import 'package:athar_app/features/historical_chat/widgets/region_story.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RawiLandingScreen extends ConsumerStatefulWidget {
  const RawiLandingScreen({super.key});

  @override
  ConsumerState<RawiLandingScreen> createState() => _RawiLandingScreenState();
}

class _RawiLandingScreenState extends ConsumerState<RawiLandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Resolved once in initState so build() never creates a new Stream/userId
  // on each keystroke — the StreamBuilder would otherwise reset to
  // ConnectionState.waiting, replacing the TextField and killing focus.
  late final Stream<List<ChatSessionModel>> _sessionsStream;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId =
        ref.read(authRepositoryProvider).currentUser?.uid ?? 'guest_user';
    _sessionsStream =
        ref.read(chatRepositoryProvider).getChatSessions(_userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatSessionModel> _filterSessions(
      List<ChatSessionModel> sessions, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sessions;
    return sessions.where((s) {
      final bucket = '${s.titleAr} ${s.titleEn} ${s.title}'.toLowerCase();
      return bucket.contains(q);
    }).toList();
  }

  String _displayTitle(
      ChatSessionModel session, bool isAr, AppLocalizations l10n) {
    dynamic region;
    for (final item in regionsData) {
      if (item.regionId == session.regionId) {
        region = item;
        break;
      }
    }

    final hasLocalizedTitle =
        session.titleAr.isNotEmpty || session.titleEn.isNotEmpty;
    final localizedTitle = session.localizedTitle(isAr ? 'ar' : 'en');
    final fallbackTitle = isAr
        ? (region != null
            ? 'سالفة عن ${region.nameAr}'
            : l10n.rawiUntitledArabic)
        : (region != null
            ? 'Story about ${region.nameEn}'
            : l10n.rawiUntitledEnglish);

    if (hasLocalizedTitle) {
      return localizedTitle.isNotEmpty ? localizedTitle : fallbackTitle;
    }

    if (region != null) {
      return fallbackTitle;
    }

    if (session.title.isNotEmpty) {
      return session.title;
    }

    return fallbackTitle;
  }

  Future<void> _openSession(ChatSessionModel session) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(existingSessionId: session.sessionId),
      ),
    );
  }

  Future<void> _renameSession(
    String userId,
    ChatSessionModel session,
    bool isAr,
    AppLocalizations l10n,
  ) async {
    var draftTitle = _displayTitle(session, isAr, l10n);

    final submitted = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawiRenameChatDialogTitle),
        content: TextFormField(
          initialValue: draftTitle,
          autofocus: true,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          onChanged: (value) => draftTitle = value,
          decoration: InputDecoration(hintText: l10n.rawiRenameChatHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.rawiCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, draftTitle.trim()),
            child: Text(l10n.rawiRenameChatSave),
          ),
        ],
      ),
    );

    final newTitle = submitted?.trim() ?? '';
    if (newTitle.isEmpty) {
      return;
    }

    await ref.read(chatRepositoryProvider).updateSessionTitles(
          userId,
          session.sessionId,
          titleAr: isAr ? newTitle : session.titleAr,
          titleEn: isAr ? session.titleEn : newTitle,
          legacyTitle: newTitle,
          lastMessageTime: session.lastMessageTime,
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.rawiChatRenamedToast)),
    );
  }

  Future<void> _confirmDeleteSession(
      String userId, ChatSessionModel session, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawiDeleteChatConfirmTitle),
        content: Text(l10n.rawiDeleteChatConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.rawiCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.rawiDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(chatRepositoryProvider)
        .deleteSession(userId, session.sessionId);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.rawiChatDeletedToast)),
    );
  }

  Future<void> _confirmDeleteAllSessions(String userId,
      List<ChatSessionModel> sessions, AppLocalizations l10n) async {
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rawiNoChatsToDelete)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawiDeleteAllChatsConfirmTitle),
        content: Text(l10n.rawiDeleteAllChatsConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.rawiCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.rawiDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(chatRepositoryProvider).deleteAllSessions(userId);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.rawiAllChatsDeletedToast)),
    );
  }

  Widget _buildStoriesRow(bool isAr) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: regionsData.length,
        itemBuilder: (context, index) {
          final region = regionsData[index];
          return GestureDetector(
            onTap: () => _showStory(context, index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(region.logoImage),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    region.getName(isAr ? 'ar' : 'en'),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(ThemeData theme, AppLocalizations l10n, bool isAr,
      String userId, List<ChatSessionModel> sessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.rawiSearchHistoryHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.sage800,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 0.9,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 0.9,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.rawiDeleteAllChats,
            onPressed: () => _confirmDeleteAllSessions(userId, sessions, l10n),
            icon: Icon(Icons.delete_sweep_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    ChatSessionModel session,
    bool isAr,
    AppLocalizations l10n,
    String userId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 0.9,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.only(
            start: 16, end: 8, top: 2, bottom: 2),
        title: Text(
          _displayTitle(session, isAr, l10n),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('yyyy/MM/dd').format(session.lastMessageTime),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        trailing: PopupMenuButton<String>(
          color: const Color(0xCC1F1F1F),
          iconColor: AppColors.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onSelected: (value) async {
            if (value == 'open') {
              await _openSession(session);
              return;
            }
            if (value == 'rename') {
              await _renameSession(userId, session, isAr, l10n);
              return;
            }
            if (value == 'delete') {
              await _confirmDeleteSession(userId, session, l10n);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'open',
              child: Text(
                l10n.rawiOpenChat,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<String>(
              value: 'rename',
              child: Text(
                l10n.rawiRenameChat,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(
                l10n.rawiDeleteChat,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        onTap: () => _openSession(session),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rawiEmptyState,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResult(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.rawiNoMatchingChats,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildStoriesRow(isAr),
            Expanded(
              child: StreamBuilder<List<ChatSessionModel>>(
                stream: _sessionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data ?? [];
                  final filtered = _filterSessions(sessions, _searchQuery);

                  return Column(
                    children: [
                      _buildSearchRow(theme, l10n, isAr, _userId, sessions),
                      Expanded(
                        child: filtered.isEmpty
                            ? (_searchQuery.isEmpty
                                ? _buildEmptyState(theme, l10n)
                                : _buildNoSearchResult(theme, l10n))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) =>
                                    _buildSessionTile(
                                  context,
                                  filtered[index],
                                  isAr,
                                  l10n,
                                  _userId,
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: Text(
          l10n.rawiNewChat,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void _showStory(BuildContext context, int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => RegionStoryScreen(initialIndex: index),
    ),
  );
}
