import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ForecastBarChart extends StatelessWidget {
  final Map<String, dynamic> forecastData;

  const ForecastBarChart({super.key, required this.forecastData});

  @override
  Widget build(BuildContext context) {
    // Sort the hours and take the next few for the chart
    final sortedHours = forecastData.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final List<BarChartGroupData> barGroups = [];

    // Create a BarChartGroupData for each hour in our forecast
    for (var hour in sortedHours) {
      final occupancy = forecastData[hour]?.toDouble() ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: int.parse(hour),
          barRods: [
            BarChartRodData(
              toY: occupancy,
              color: Colors.teal.withOpacity(0.6),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    if(barGroups.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 2.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100, // Percentage
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  // Display hour on the bottom axis
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${value.toInt()}:00'),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
          ),
          gridData: const FlGridData(show: true, verticalInterval: 1),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}