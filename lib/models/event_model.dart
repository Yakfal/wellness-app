import 'package:flutter/material.dart';

// An enum to define the type of event, which helps in styling.
enum EventType { yoga, calisthenics, pool, sauna, general }

class Event {
  final String title;
  final String time;
  final String location;
  final EventType type;

  const Event({
    required this.title,
    required this.time,
    required this.location,
    required this.type,
  });
}