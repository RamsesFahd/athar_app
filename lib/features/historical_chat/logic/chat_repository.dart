import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart'; // Import the new model

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepository();

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('sessions');
  }

  // Get messages for a specific session
  Stream<List<ChatMessageModel>> getMessages(String userId, String sessionId) {
    return _sessionsRef(userId)
        .doc(sessionId) // Use unique sessionId
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Save message to a specific session
  Future<void> saveMessage(
      String userId, String sessionId, ChatMessageModel message) async {
    await _sessionsRef(userId)
        .doc(sessionId)
        .collection('messages')
        .add(message.toMap());
  }

  // Create a new session document in Firestore
  Future<void> createSession(String userId, ChatSessionModel session) async {
    await _sessionsRef(userId).doc(session.sessionId).set(session.toMap());
  }

  Future<void> upsertSession(String userId, ChatSessionModel session) async {
    await _sessionsRef(userId)
        .doc(session.sessionId)
        .set(session.toMap(), SetOptions(merge: true));
  }

  Future<void> updateSessionTitles(
    String userId,
    String sessionId, {
    String? titleAr,
    String? titleEn,
    String? legacyTitle,
    DateTime? lastMessageTime,
  }) async {
    final data = <String, dynamic>{};
    if (titleAr != null) {
      data['titleAr'] = titleAr;
    }
    if (titleEn != null) {
      data['titleEn'] = titleEn;
    }
    if (legacyTitle != null) {
      data['title'] = legacyTitle;
    }
    if (lastMessageTime != null) {
      data['lastMessageTime'] = Timestamp.fromDate(lastMessageTime);
    }

    if (data.isEmpty) {
      return;
    }

    await _sessionsRef(userId)
        .doc(sessionId)
        .set(data, SetOptions(merge: true));
  }

  Future<List<ChatMessageModel>> getRecentMessages(
    String userId,
    String sessionId, {
    int limit = 8,
  }) async {
    final snapshot = await _sessionsRef(userId)
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<ChatSessionModel?> getSession(String userId, String sessionId) async {
    final doc = await _sessionsRef(userId).doc(sessionId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ChatSessionModel.fromMap(doc.data()!);
  }

  Stream<ChatSessionModel?> watchSession(String userId, String sessionId) {
    return _sessionsRef(userId).doc(sessionId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ChatSessionModel.fromMap(doc.data()!);
    });
  }

  Future<void> deleteSession(String userId, String sessionId) async {
    final messages =
        await _sessionsRef(userId).doc(sessionId).collection('messages').get();
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }
    await _sessionsRef(userId).doc(sessionId).delete();
  }

  Future<void> deleteAllSessions(String userId) async {
    final sessions = await _sessionsRef(userId).get();
    for (final session in sessions.docs) {
      await deleteSession(userId, session.id);
    }
  }

  Future<List<ChatSessionModel>> searchSessions(
    String userId,
    String query, {
    List<ChatSessionModel>? cachedSessions,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return cachedSessions ?? <ChatSessionModel>[];
    }

    final sessions = cachedSessions ??
        await _sessionsRef(userId)
            .orderBy('lastMessageTime', descending: true)
            .get()
            .then((snapshot) => snapshot.docs
                .map((doc) => ChatSessionModel.fromMap(doc.data()))
                .toList());

    final matches = <ChatSessionModel>[];

    for (final session in sessions!) {
      final titleBucket =
          '${session.titleAr} ${session.titleEn} ${session.title}'
              .toLowerCase();
      if (titleBucket.contains(normalizedQuery)) {
        matches.add(session);
        continue;
      }

      final messages = await _sessionsRef(userId)
          .doc(session.sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(40)
          .get();

      final containsQuery = messages.docs.any((doc) {
        final text = (doc.data()['text'] ?? '').toString().toLowerCase();
        return text.contains(normalizedQuery);
      });

      if (containsQuery) {
        matches.add(session);
      }
    }

    return matches;
  }

  // Get all chat sessions for a specific user to display in history
  Stream<List<ChatSessionModel>> getChatSessions(String userId) {
    return _sessionsRef(userId)
        .orderBy('lastMessageTime', descending: true) // Newest sessions first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSessionModel.fromMap(doc.data()))
            .toList());
  }
}
