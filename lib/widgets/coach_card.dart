import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(coach.imageUrl),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          coach.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          coach.specialty,
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        trailing: const Icon(Icons.chevron_right),
        //... inside the ListTile
        onTap: () {
          // Navigate using the coach's unique document ID
          context.go('/coaches/details/${coach.id}');
        },
//...
      ),
    );
  }
}