import 'package:flutter/material.dart';
import '../models/facility_model.dart';
import 'forecast_bar_chart.dart';

class FacilityStatusCard extends StatelessWidget {
  final Facility facility;

  const FacilityStatusCard({super.key, required this.facility});

  // Helper function to determine the status text and color based on density
  Map<String, dynamic> _getStatus(double density) {
    if (density < 0.5) {
      return {'text': 'Not Busy', 'color': Colors.green};
    } else if (density < 0.8) {
      return {'text': 'Getting Crowded', 'color': Colors.orange};
    } else {
      return {'text': 'Very Busy', 'color': Colors.red};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _getStatus(facility.density);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Facility Name and Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  facility.name,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  statusText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Middle Row: The Custom Progress Bar ---
            // LayoutBuilder gives us the width of the parent widget
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // The background of the progress bar
                    Container(
                      height: 12,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // The foreground (filled) part of the progress bar
                    Container(
                      height: 12,
                      width: constraints.maxWidth * facility.density,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // --- Bottom Row: Occupancy Numbers ---
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${facility.currentOccupancy} / ${facility.capacity} people',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
             const Divider(height: 32),
            Text(
              'Hourly Forecast',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (facility.hourlyForecast.isNotEmpty)
              ForecastBarChart(forecastData: facility.hourlyForecast)
            else
              const Text('No forecast data available.'),
          ],
        ),
      ),
    );
  }
}