import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String firstName;
  final DateTime membershipExpiry;

  UserData({
    required this.id,
    required this.firstName,
    required this.membershipExpiry,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: doc.id,
      firstName: data['firstName'] ?? 'Member',
      membershipExpiry: (data['membershipExpiry'] as Timestamp).toDate(),
    );
  }
}