import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isUserEvent; // Flag to know if this is the user's event
  final VoidCallback? onDelete; // Callback function for when delete is pressed

  const EventCard({
    super.key,
    required this.event,
    this.isUserEvent = false, // Default to false
    this.onDelete,
  });

  // Helper function to get styling based on event type
  Map<String, dynamic> _getEventStyling(EventType type) {
    // Give personal events a distinct look
    if (type == EventType.personal || type == EventType.swimming) {
      return {'icon': Icons.person, 'color': Colors.blue};
    }

    if (type == EventType.climbing) {
      return {'icon': Icons.hardware_rounded, 'color': Colors.brown};
    }

    switch (type) {
      case EventType.yoga:
        return {'icon': Icons.self_improvement, 'color': Colors.purple};
      case EventType.calisthenics:
        return {'icon': Icons.fitness_center, 'color': Colors.orange};
      case EventType.pool:
        return {'icon': Icons.pool, 'color': Colors.teal};
      case EventType.sauna:
        return {'icon': Icons.hot_tub, 'color': Colors.red};
      default:
        return {'icon': Icons.calendar_today, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final styling = _getEventStyling(event.type);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: isUserEvent
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (styling['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(styling['icon'], color: styling['color'], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(event.time, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(event.location, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ),
            // Conditionally show the delete button
            if (isUserEvent)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete, // Trigger the callback when pressed
              ),
          ],
        ),
      ),
    );
  }
}