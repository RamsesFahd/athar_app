import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart'; // Import the new model

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) => ChatRepository();

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get messages for a specific session
  Stream<List<ChatMessageModel>> getMessages(String userId, String sessionId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions') // Changed from chats to sessions
        .doc(sessionId)         // Use unique sessionId
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Save message to a specific session
  Future<void> saveMessage(String userId, String sessionId, ChatMessageModel message) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add(message.toMap());
  }

  // Create a new session document in Firestore
  Future<void> createSession(String userId, ChatSessionModel session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(session.sessionId)
        .set(session.toMap());
  }
  // Get all chat sessions for a specific user to display in history
  Stream<List<ChatSessionModel>> getChatSessions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('lastMessageTime', descending: true) // Newest sessions first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSessionModel.fromMap(doc.data()))
            .toList());
  }
}