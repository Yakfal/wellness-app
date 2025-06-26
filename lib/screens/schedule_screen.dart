import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  // This is our dummy data. Later, this will come from Firebase.
  final List<Event> _events = const [
    Event(title: 'Vinyasa Yoga', time: '08:00 AM - 09:00 AM', location: 'Studio 1', type: EventType.yoga),
    Event(title: 'Beginner Calisthenics', time: '09:30 AM - 10:30 AM', location: 'Private Room A', type: EventType.calisthenics),
    Event(title: 'Lane Swimming', time: '10:00 AM - 11:00 AM', location: 'Main Pool', type: EventType.pool),
    Event(title: 'Sauna Open Hours', time: '10:00 AM - 08:00 PM', location: 'Wellness Wing', type: EventType.sauna),
    Event(title: 'Advanced Calisthenics', time: '05:00 PM - 06:30 PM', location: 'Private Room A', type: EventType.calisthenics),
    Event(title: 'Hot Yoga', time: '06:00 PM - 07:00 PM', location: 'Studio 1', type: EventType.yoga),
    Event(title: 'Team Meeting', time: '07:00 PM - 07:30 PM', location: 'Front Desk', type: EventType.general),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // An AppBar makes the screen look more complete
      appBar: AppBar(
        title: const Text("Today's Schedule"),
        centerTitle: false,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          // We use our reusable EventCard for each item in the list
          return EventCard(event: event);
        },
      ),
    );
  }
}