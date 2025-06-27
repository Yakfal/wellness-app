import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coach_model.dart';
import '../services/booking_service.dart';
import '../widgets/coach_card.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Coaches'),
        centerTitle: false,
        elevation: 1,
      ),
      // FutureBuilder handles displaying data that hasn't arrived yet.
      body: FutureBuilder<List<Coach>>(
        future: bookingService.getCoaches(), // This is the function we want to run
        builder: (context, snapshot) {
          // 1. While waiting for data, show a loading spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. If there was an error, show an error message.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // 3. If the data is empty or null, show a message.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No coaches found.'));
          }

          // 4. If we have data, store it and build our list.
          final coaches = snapshot.data!;
          return ListView.builder(
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return CoachCard(coach: coach);
            },
          );
        },
      ),
    );
  }
}