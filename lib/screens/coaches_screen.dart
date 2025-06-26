import 'package:flutter/material.dart';
import '../models/coach_model.dart';
import '../widgets/coach_card.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});

  // Dummy data for coaches. We'll use placeholder images.
  final List<Coach> _coaches = const [
    Coach(
      name: 'Alex Morgan',
      specialty: 'Yoga & Meditation',
      imageUrl: 'https://images.pexels.com/photos/416809/pexels-photo-416809.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
    Coach(
      name: 'Ben Carter',
      specialty: 'Calisthenics & Strength',
      imageUrl: 'https://images.pexels.com/photos/927451/pexels-photo-927451.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
    Coach(
      name: 'Chloe Davis',
      specialty: 'Swimming & Aqua Fitness',
      imageUrl: 'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
    Coach(
      name: 'David Rodriguez',
      specialty: 'General Fitness',
      imageUrl: 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Coaches'),
        centerTitle: false,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: _coaches.length,
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          // Use our reusable CoachCard widget
          return CoachCard(coach: coach);
        },
      ),
    );
  }
}