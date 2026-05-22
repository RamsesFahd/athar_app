import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athar_app/core/models/chat/chat_message_model.dart';
import 'package:athar_app/core/models/chat/chat_session_model.dart';
import 'package:athar_app/core/models/chat/region_model.dart';

void main() {
  group('ChatSessionModel', () {
    test('UT-89: localizedTitle returns Arabic title for Arabic locale', () {
      final session = ChatSessionModel(
        sessionId: 's1',
        regionId: 'central',
        titleAr: 'Arabic Title',
        titleEn: 'English Title',
        lastMessageTime: DateTime(2025, 1, 1),
      );

      expect(session.localizedTitle('ar'), 'Arabic Title');
    });

    test('UT-90: localizedTitle falls back to non-Arabic legacy title', () {
      final session = ChatSessionModel(
        sessionId: 's1',
        regionId: 'central',
        titleAr: '',
        titleEn: '',
        title: 'Legacy English',
        lastMessageTime: DateTime(2025, 1, 1),
      );

      expect(session.localizedTitle('en'), 'Legacy English');
    });

    test('UT-91: toMap/fromMap round-trip preserves session fields', () {
      final original = ChatSessionModel(
        sessionId: 's1',
        regionId: 'western',
        titleAr: 'Arabic Title',
        titleEn: 'English Title',
        lastMessageTime: DateTime(2025, 1, 1, 10, 30),
      );

      final restored = ChatSessionModel.fromMap(original.toMap());

      expect(restored.sessionId, original.sessionId);
      expect(restored.regionId, original.regionId);
      expect(restored.titleAr, original.titleAr);
      expect(restored.titleEn, original.titleEn);
      expect(restored.lastMessageTime, original.lastMessageTime);
    });
  });

  group('ChatMessageModel', () {
    test('UT-92: fromMap converts suggested item maps and timestamp', () {
      final message = ChatMessageModel.fromMap(
        {
          'text': 'Hello',
          'senderId': 'user-1',
          'isUser': true,
          'timestamp': Timestamp.fromDate(DateTime(2025, 1, 1)),
          'suggestedItems': [
            {'id': 'item-1', 'type': 'cultural'},
          ],
        },
        'message-1',
      );

      expect(message.id, 'message-1');
      expect(message.text, 'Hello');
      expect(message.senderId, 'user-1');
      expect(message.isUser, isTrue);
      expect(message.suggestedItems, [
        {'id': 'item-1', 'type': 'cultural'},
      ]);
    });

    test('UT-93: toMap omits empty suggestedItems', () {
      final message = ChatMessageModel(
        text: 'Reply',
        senderId: 'bot',
        isUser: false,
        timestamp: DateTime(2025, 1, 1),
        suggestedItems: const [],
      );

      final map = message.toMap();

      expect(map['text'], 'Reply');
      expect(map['senderId'], 'bot');
      expect(map['isUser'], isFalse);
      expect(map['timestamp'], isA<FieldValue>());
      expect(map.containsKey('suggestedItems'), isFalse);
    });
  });

  group('RegionModel', () {
    test('UT-94: getName and getDescription return localized text', () {
      final region = RegionModel(
        regionId: 'central',
        nameAr: 'Central Ar',
        nameEn: 'Central',
        descriptionAr: 'Description Ar',
        descriptionEn: 'Description En',
        logoImage: 'logo.png',
        storyImage: 'story.png',
        systemPrompt: 'prompt',
      );

      expect(region.getName('ar'), 'Central Ar');
      expect(region.getName('en'), 'Central');
      expect(region.getDescription('ar'), 'Description Ar');
      expect(region.getDescription('en'), 'Description En');
    });
  });
}
