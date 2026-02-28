import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) => ChatRepository();

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessageModel>> getMessages(String userId, String regionId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(regionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveMessage(String userId, String regionId, ChatMessageModel message) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(regionId)
        .collection('messages')
        .add(message.toMap());
  }
}