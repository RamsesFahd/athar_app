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
    // معالجة الـ Timestamp لتجنب الكراش إذا كانت القيمة null مؤقتاً
    dynamic timestampData = map['timestamp'];
    DateTime processedDate;

    if (timestampData is Timestamp) {
      processedDate = timestampData.toDate();
    } else {
      // إذا كان الوقت لم يصل بعد من السيرفر، نستخدم وقت الجهاز الحالي كاحتياط
      processedDate = DateTime.now();
    }

    return ChatMessageModel(
      id: documentId,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      isUser: map['isUser'] ?? true,
      timestamp: processedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'isUser': isUser,
      // نستخدم serverTimestamp لضمان ترتيب موحد لكل المستخدمين
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }
}