import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/coach_model.dart';
import '../models/event_model.dart';
import '../models/facility_model.dart';
import '../models/membership_tier_model.dart';
import '../models/user_data_model.dart';
import '../models/announcement_model.dart';

class BookingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- THIS IS THE CORRECTED FUNCTION SIGNATURE ---
  /// Signs up a new user with email, password, and first name.
  Future<UserCredential> signUpWithEmail(String email, String password, String firstName) async {
    try {
      // First, create the user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If the auth user is created successfully, create their user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'email': email,
          // Set a default membership expiry for new users (e.g., 1 year from now)
          'membershipExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 365))),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw Exception('The password provided is too weak.');
      if (e.code == 'email-already-in-use') throw Exception('An account already exists for that email.');
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

  /// Returns a live stream of the current user's data document.
  Stream<UserData?> getUserDataStream() {
    if (currentUserId == null) return Stream.value(null);
    return _firestore.collection('users').doc(currentUserId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserData.fromFirestore(doc);
    });
  }

  /// Fetches the most recent active announcement.
  Future<Announcement?> getActiveAnnouncement() async {
    final snapshot = await _firestore
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Announcement.fromFirestore(snapshot.docs.first);
  }

  /// Returns a live stream of all facilities.
  Stream<List<Facility>> getFacilitiesStream() {
    return _firestore.collection('facilities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList();
    });
  }

  /// Fetches all membership tiers and organizes them by category.
  Future<Map<String, List<MembershipTier>>> getMembershipTiers() async {
    final snapshot = await _firestore.collection('membershipTiers').orderBy('order').get();
    
    final tiers = snapshot.docs
        .map((doc) => MembershipTier.fromFirestore(doc))
        .toList();

    final categorizedTiers = <String, List<MembershipTier>>{
      'Monthly': [], 'Annual': [], 'Passes': [],
    };

    for (var tier in tiers) {
      if (categorizedTiers.containsKey(tier.category)) {
        categorizedTiers[tier.category]!.add(tier);
      }
    }
    
    return categorizedTiers;
  }
  
  // All other database functions below remain unchanged and will work correctly
  // with the real user ID once a user is logged in.

  Future<List<Coach>> getCoaches() async {
    final snapshot = await _firestore.collection('coaches').get();
    return snapshot.docs.map((doc) => Coach.fromFirestore(doc.data(), doc.id)).toList();
  }
  
  Future<void> addUserEvent({required String title, required String time, required String location, required EventType type, required DateTime date}) async {
    if (currentUserId == null) throw Exception("User not logged in");
    await _firestore.collection('events').add({
      'title': title, 'time': time, 'location': location, 'type': type.name, 
      'date': Timestamp.fromDate(date), 'userId': currentUserId,
    });
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    if (currentUserId == null) return [];
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final publicEventsQuery = _firestore.collection('events').where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay).where('userId', isEqualTo: null).get();
    final userEventsQuery = _firestore.collection('events').where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay).where('userId', isEqualTo: currentUserId).get();
    final results = await Future.wait([publicEventsQuery, userEventsQuery]);
    final publicEvents = results[0].docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();
    final userEvents = results[1].docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();
    return [...publicEvents, ...userEvents];
  }

  Future<List<Event>> getMyUpcomingAppointments() async {
    if (currentUserId == null) return [];
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final userEventsQuery = await _firestore.collection('events').where('userId', isEqualTo: currentUserId).where('date', isGreaterThanOrEqualTo: today).get();
    final myEvents = userEventsQuery.docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();
    final coachesQuery = await _firestore.collection('coaches').get();
    final myBookedSessions = <Event>[];
    for (var coachDoc in coachesQuery.docs) {
      final coach = Coach.fromFirestore(coachDoc.data(), coachDoc.id);
      for (var slot in coach.availableSlots) {
        if (slot.isBooked && slot.bookedBy == currentUserId) {
          myBookedSessions.add(Event(id: '${coach.id}-${slot.time}', title: 'Session with ${coach.name}', time: slot.time, location: coach.specialty, type: EventType.personal, date: today));
        }
      }
    }
    final allAppointments = [...myEvents, ...myBookedSessions];
    allAppointments.sort((a, b) => a.date.compareTo(b.date));
    return allAppointments;
  }
  
  Future<void> bookSlot(String coachId, TimeSlot selectedSlot) async {
    if (currentUserId == null) throw Exception("User not logged in");
    final coachDocRef = _firestore.collection('coaches').doc(coachId);
    final docSnapshot = await coachDocRef.get();
    if (!docSnapshot.exists) throw Exception('Coach not found!');
    final coach = Coach.fromFirestore(docSnapshot.data()!, docSnapshot.id);
    final updatedSlots = coach.availableSlots.map((slot) {
      if (slot.time == selectedSlot.time) return {'time': slot.time, 'isBooked': true, 'bookedBy': currentUserId};
      return {'time': slot.time, 'isBooked': slot.isBooked, 'bookedBy': slot.bookedBy};
    }).toList();
    await coachDocRef.update({'availableSlots': updatedSlots});
  }
  
  Future<void> deleteUserEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}