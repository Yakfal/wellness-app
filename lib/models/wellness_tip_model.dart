import 'package:flutter/material.dart';

class WellnessTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const WellnessTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Create our list of the 8 Health Principles
final List<WellnessTip> wellnessTips = [
  WellnessTip(title: 'Nutrition', description: 'Nourish your body with a balanced, plant-based diet for optimal energy and health.', icon: Icons.restaurant_rounded, color: Colors.green),
  WellnessTip(title: 'Exercise', description: 'Regular physical activity strengthens your body and mind. Find a routine you enjoy!', icon: Icons.fitness_center_rounded, color: Colors.orange),
  WellnessTip(title: 'Water', description: 'Stay hydrated. Water is essential for every bodily function and boosts your overall vitality.', icon: Icons.water_drop_rounded, color: Colors.blue),
  WellnessTip(title: 'Sunlight', description: 'Spend some time in the sun each day to get vital Vitamin D and improve your mood.', icon: Icons.wb_sunny_rounded, color: Colors.yellow.shade700),
  WellnessTip(title: 'Temperance', description: 'Practice moderation and balance in all things for a sustainable, healthy lifestyle.', icon: Icons.hourglass_empty_rounded, color: Colors.purple),
  WellnessTip(title: 'Air', description: 'Breathe deeply. Fresh, clean air invigorates your lungs and clarifies your thoughts.', icon: Icons.air_rounded, color: Colors.lightBlue),
  WellnessTip(title: 'Rest', description: 'Adequate sleep and rest are crucial for recovery, mental clarity, and physical repair.', icon: Icons.hotel_rounded, color: Colors.indigo),
  WellnessTip(title: 'Trust', description: 'Nurture your spiritual health. Trust in a higher power can provide peace and reduce stress.', icon: Icons.volunteer_activism_rounded, color: Colors.pink),
];