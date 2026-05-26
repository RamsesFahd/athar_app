import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athar_app/core/models/events/event_model.dart';

final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('events')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => EventModel.fromMap(d.data(), d.id))
          .toList());
});

final upcomingEventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('events')
      .where('eventDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
      .orderBy('eventDate')
      .snapshots()
      .map((s) => s.docs
          .map((d) => EventModel.fromMap(d.data(), d.id))
          .toList());
});

Future<void> deleteEvent(String eventId) =>
    FirebaseFirestore.instance.collection('events').doc(eventId).delete();

Future<void> updateEventFields(String eventId, Map<String, dynamic> fields) =>
    FirebaseFirestore.instance.collection('events').doc(eventId).update(fields);
