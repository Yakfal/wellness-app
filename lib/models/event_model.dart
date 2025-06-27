import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum EventType { yoga, calisthenics, pool, sauna, general, swimming, personal, climbing }

class Event {
  final String id;
  final String title;
  final String time;
  final String location;
  final EventType type;
  final DateTime date;
  final String? userId; // Can be null for public events

  const Event({
    required this.id,
    required this.title,
    required this.time,
    required this.location,
    required this.type,
    required this.date,
    this.userId, // Added as optional
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    EventType eventType = EventType.values.firstWhere(
      (e) => e.toString() == 'EventType.${data['type']}',
      orElse: () => EventType.general,
    );

    return Event(
      id: documentId,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      type: eventType,
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] as String?, // Read the new field
    );
  }
}