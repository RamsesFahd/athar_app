import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSessionModel {
  final String sessionId;
  final String regionId;
  final String title;
  final DateTime lastMessageTime;

  ChatSessionModel({
    required this.sessionId,
    required this.regionId,
    required this.title,
    required this.lastMessageTime,
  });

  // Convert model to Firestore document [cite: 3, 13]
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'regionId': regionId,
      'title': title,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }

  // Create model from Firestore document [cite: 3, 13]
  factory ChatSessionModel.fromMap(Map<String, dynamic> map) {
    return ChatSessionModel(
      sessionId: map['sessionId'] ?? '',
      regionId: map['regionId'] ?? '',
      title: map['title'] ?? 'New Chat',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
    );
  }
}
