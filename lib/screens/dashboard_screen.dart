import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility_model.dart';
import '../services/booking_service.dart';
import '../widgets/facility_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Facility Usage'),
      ),
      body: StreamBuilder<List<Facility>>(
        stream: bookingService.getFacilitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No facilities found.'));
          }

          final facilities = snapshot.data!;
          
          // --- THIS IS THE UPDATED UI ---
          // We use a ListView to show our new custom cards
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final facility = facilities[index];
              // Replace the old ListTile with our new widget
              return FacilityStatusCard(facility: facility);
            },
          );
        },
      ),
    );
  }
}