import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coach_model.dart';
import '../models/event_model.dart';
import '../models/facility_model.dart';
import '../models/membership_tier_model.dart';

class BookingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current logged-in user's ID, or null if logged out.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Signs up a new user with email and password.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception('An error occurred during sign up. Please try again.');
    }
  }

  /// Signs in a user with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      }
      throw Exception('An error occurred during sign in. Please try again.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// Returns a live stream of all facilities.
  Stream<List<Facility>> getFacilitiesStream() {
    return _firestore.collection('facilities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList();
    });
  }

  /// Fetches the list of all coaches from the Firestore database.
  Future<List<Coach>> getCoaches() async {
    final snapshot = await _firestore.collection('coaches').get();
    return snapshot.docs.map((doc) => Coach.fromFirestore(doc.data(), doc.id)).toList();
  }
  
  /// Adds a new event document to Firestore for the current logged-in user.
  Future<void> addUserEvent(
      {required String title,
      required String time,
      required String location,
      required EventType type,
      required DateTime date}) async {
    if (currentUserId == null) throw Exception("User not logged in");
    await _firestore.collection('events').add({
      'title': title,
      'time': time,
      'location': location,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'userId': currentUserId, // Uses the real ID
    });
  }

  /// Fetches events for a specific day, including both public events and events for the current user.
  Future<List<Event>> getEventsForDate(DateTime date) async {
    if (currentUserId == null) return []; // Return empty if no user

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final publicEventsQuery = _firestore.collection('events').where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay).where('userId', isEqualTo: null).get();
    final userEventsQuery = _firestore.collection('events').where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay).where('userId', isEqualTo: currentUserId).get();
    
    final results = await Future.wait([publicEventsQuery, userEventsQuery]);

    final publicEvents = results[0].docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();
    final userEvents = results[1].docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();

    return [...publicEvents, ...userEvents];
  }

  /// Fetches all upcoming events and booked coach sessions for the current user.
  Future<List<Event>> getMyUpcomingAppointments() async {
    if (currentUserId == null) return []; // Return empty if no user

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final userEventsQuery = await _firestore.collection('events').where('userId', isEqualTo: currentUserId).where('date', isGreaterThanOrEqualTo: today).get();
    final myEvents = userEventsQuery.docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();

    final coachesQuery = await _firestore.collection('coaches').get();
    final myBookedSessions = <Event>[];

    for (var coachDoc in coachesQuery.docs) {
      final coach = Coach.fromFirestore(coachDoc.data(), coachDoc.id);
      for (var slot in coach.availableSlots) {
        if (slot.isBooked && slot.bookedBy == currentUserId) {
          myBookedSessions.add(
            Event(
              id: '${coach.id}-${slot.time}',
              title: 'Session with ${coach.name}',
              time: slot.time,
              location: coach.specialty,
              type: EventType.personal,
              date: today,
            ),
          );
        }
      }
    }

    final allAppointments = [...myEvents, ...myBookedSessions];
    allAppointments.sort((a, b) => a.date.compareTo(b.date));

    return allAppointments;
  }
  
   /// Fetches all membership tiers and organizes them by category.
  Future<Map<String, List<MembershipTier>>> getMembershipTiers() async {
    final snapshot = await _firestore.collection('membershipTiers').orderBy('order').get();
    
    final tiers = snapshot.docs
        .map((doc) => MembershipTier.fromFirestore(doc))
        .toList();

    // Organize into a map
    final categorizedTiers = <String, List<MembershipTier>>{
      'Monthly': [],
      'Annual': [],
      'Passes': [],
    };

    for (var tier in tiers) {
      if (categorizedTiers.containsKey(tier.category)) {
        categorizedTiers[tier.category]!.add(tier);
      }
    }
    
    return categorizedTiers;
  }

  /// Books a time slot with a coach for the current user.
  Future<void> bookSlot(String coachId, TimeSlot selectedSlot) async {
    if (currentUserId == null) throw Exception("User not logged in");
    
    final coachDocRef = _firestore.collection('coaches').doc(coachId);
    final docSnapshot = await coachDocRef.get();
    if (!docSnapshot.exists) throw Exception('Coach not found!');

    final coach = Coach.fromFirestore(docSnapshot.data()!, docSnapshot.id);

    final updatedSlots = coach.availableSlots.map((slot) {
      if (slot.time == selectedSlot.time) {
        return {'time': slot.time, 'isBooked': true, 'bookedBy': currentUserId};
      } else {
        return {'time': slot.time, 'isBooked': slot.isBooked, 'bookedBy': slot.bookedBy};
      }
    }).toList();

    await coachDocRef.update({'availableSlots': updatedSlots});
  }
  
  /// Deletes a specific event document from Firestore.
  Future<void> deleteUserEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}