import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String title;
  final String message;

  Announcement({required this.title, required this.message});

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Announcement(
      title: data['title'] ?? 'Announcement',
      message: data['message'] ?? 'No details available.',
    );
  }
}