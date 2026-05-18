import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String? id;
  final String text;
  final String senderId;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? suggestedItems;

  ChatMessageModel({
    this.id,
    required this.text,
    required this.senderId,
    required this.isUser,
    required this.timestamp,
    this.suggestedItems,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    dynamic timestampData = map['timestamp'];
    DateTime processedDate;

    if (timestampData is Timestamp) {
      processedDate = timestampData.toDate();
    } else {
      processedDate = DateTime.now();
    }

    List<Map<String, dynamic>>? suggestedItems;
    final rawItems = map['suggestedItems'];
    if (rawItems is List && rawItems.isNotEmpty) {
      suggestedItems = rawItems
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.fromEntries(
                e.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)),
              ))
          .toList();
    }

    return ChatMessageModel(
      id: documentId,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      isUser: map['isUser'] ?? true,
      timestamp: processedDate,
      suggestedItems: suggestedItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
      if (suggestedItems != null && suggestedItems!.isNotEmpty)
        'suggestedItems': suggestedItems,
    };
  }
}
