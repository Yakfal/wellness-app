import 'package:cloud_firestore/cloud_firestore.dart';

class Facility {
  final String id;
  final String name;
  final int capacity;
  final int currentOccupancy;
  final Map<String, dynamic> hourlyForecast; // Our new property

  double get density => (currentOccupancy > 0 && capacity > 0) ? (currentOccupancy / capacity).clamp(0, 1) : 0.0;

  Facility({
    required this.id,
    required this.name,
    required this.capacity,
    required this.currentOccupancy,
    required this.hourlyForecast, // Add to constructor
  });

  factory Facility.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Facility(
      id: doc.id,
      name: data['name'] ?? 'Unknown Facility',
      capacity: data['capacity'] ?? 1,
      currentOccupancy: data['currentOccupancy'] ?? 0,
      hourlyForecast: data['hourlyForecast'] ?? {}, // Read the new map
    );
  }
}