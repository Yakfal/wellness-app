import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coach_model.dart';
import '../services/booking_service.dart';
import '../widgets/booking_bottom_sheet.dart';

class CoachDetailScreen extends StatelessWidget {
  // It now receives the document ID, not the whole object
  final String coachId;

  const CoachDetailScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);

    // StreamBuilder listens for LIVE changes to a single document
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('coaches').doc(coachId).snapshots(),
      builder: (context, snapshot) {
        // Handle loading and error states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Coach not found.')));
        }

        // If we have data, convert it to our Coach object
        final coach = Coach.fromFirestore(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
        final theme = Theme.of(context);

        // The rest of the UI is the same, but it's now inside the StreamBuilder
        return Scaffold(
          appBar: AppBar(title: Text(coach.name)),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 80, backgroundImage: NetworkImage(coach.imageUrl)),
                  const SizedBox(height: 24),
                  Text(coach.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(coach.specialty, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                  const Divider(height: 48),
                  Text('About Me', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Lorem ipsum dolor sit amet...', textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Book a Session'),
                    onPressed: () async {
                      final selectedSlot = await showModalBottomSheet<TimeSlot>(
                        context: context,
                        builder: (BuildContext context) {
                          return BookingBottomSheet(availableSlots: coach.availableSlots);
                        },
                      );

                      if (selectedSlot != null) {
                        // Call the booking method on our service with the coach's ID
                        await bookingService.bookSlot(coach.id, selectedSlot);
                        
                        // Show confirmation message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Booked session with ${coach.name} at ${selectedSlot.time}!'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}