import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String? id;
  final String text;
  final String senderId; 
  final bool isUser;    
  final DateTime timestamp;

  ChatMessageModel({
    this.id,
    required this.text,
    required this.senderId,
    required this.isUser,
    required this.timestamp,
  });

  
  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatMessageModel(
      id: documentId,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      isUser: map['isUser'] ?? true,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }
}