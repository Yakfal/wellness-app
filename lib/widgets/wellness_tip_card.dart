import 'package:flutter/material.dart';
import '../models/wellness_tip_model.dart';

class WellnessTipCard extends StatelessWidget {
  final WellnessTip tip;
  const WellnessTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(tip.icon, size: 40, color: tip.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Focus: ${tip.title}",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: tip.color),
                  ),
                  const SizedBox(height: 4),
                  Text(tip.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}