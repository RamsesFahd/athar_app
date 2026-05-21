import 'package:athar_app/core/constants/region_data.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
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
    _userId = ref.read(authRepositoryProvider).currentUser?.uid ?? 'guest_user';
    _sessionsStream = ref.read(chatRepositoryProvider).getChatSessions(_userId);
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
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final extraHeight = ((textScale - 1.0).clamp(0.0, 1.0) * 34).toDouble();

    return SizedBox(
      height: 110 + extraHeight,
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
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(region.logoImage),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      region.getName(isAr ? 'ar' : 'en'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: TextField(
                controller: _searchController,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.rawiSearchHistoryHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon:
                      Icon(Icons.search, color: theme.colorScheme.primary),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 0.9,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
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
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: theme.colorScheme.primary,
            ),
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14, left: 12, right: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _openSession(session),
        contentPadding: const EdgeInsetsDirectional.only(
          start: 14,
          end: 6,
          top: 8,
          bottom: 8,
        ),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
          child: Icon(
            Icons.auto_stories_rounded,
            color: theme.colorScheme.primary,
            size: 23,
          ),
        ),
        title: Text(
          _displayTitle(session, isAr, l10n),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            DateFormat('yyyy/MM/dd').format(session.lastMessageTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: theme.colorScheme.surface,
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.primary,
          ),
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
              child: Text(l10n.rawiOpenChat),
            ),
            PopupMenuItem<String>(
              value: 'rename',
              child: Text(l10n.rawiRenameChat),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n.rawiDeleteChat),
            ),
          ],
        ),
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
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.rawiEmptyState,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(
          Icons.add_comment_rounded,
          color: theme.colorScheme.onPrimary,
        ),
        label: Text(
          l10n.rawiNewChat,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
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
