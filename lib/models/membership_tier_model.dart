import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipTier {
  final String title;
  final String price;
  final String description;
  final String category; // e.g., "Monthly", "Annual", "Passes"
  final int order; // To control the display order

  MembershipTier({
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.order,
  });

  factory MembershipTier.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MembershipTier(
      title: data['title'] ?? '',
      price: data['price'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      order: data['order'] ?? 99,
    );
  }
}