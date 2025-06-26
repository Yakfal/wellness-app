import 'package:flutter/material.dart';
import '../models/coach_model.dart';

class CoachCard extends StatelessWidget {
  final Coach coach;
  const CoachCard({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // The coach's profile picture
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(coach.imageUrl),
          backgroundColor: Colors.grey[200], // Shows while the image loads
        ),
        // The coach's name
        title: Text(
          coach.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        // The coach's specialty
        subtitle: Text(
          coach.specialty,
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        // An icon to suggest the card is tappable
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Later, this will navigate to the coach's detail screen
          print('Tapped on ${coach.name}');
        },
      ),
    );
  }
}