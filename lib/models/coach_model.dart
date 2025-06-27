class TimeSlot {
  final String time;
  bool isBooked;
  final String? bookedBy; // New nullable property

  TimeSlot({
    required this.time,
    this.isBooked = false,
    this.bookedBy, // Add to constructor
  });

  // Update the factory to read the new field from Firestore
  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      time: map['time'] as String,
      isBooked: map['isBooked'] as bool,
      bookedBy: map['bookedBy'] as String?, // Read the new field
    );
  }
}

// ... the Coach class and fromFirestore constructor remain unchanged ...

class Coach {
  final String id; // Add ID to hold the document ID from Firestore
  final String name;
  final String specialty;
  final String imageUrl;
  final List<TimeSlot> availableSlots;

  const Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.availableSlots,
  });

  // Factory constructor to create a Coach instance from a Firestore document
  factory Coach.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Coach(
      id: documentId,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      // We need to convert the list of maps from Firestore into a list of TimeSlot objects
      availableSlots: (data['availableSlots'] as List<dynamic>? ?? [])
          .map((slotData) => TimeSlot.fromMap(slotData as Map<String, dynamic>))
          .toList(),
    );
  }
}