import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/booking_service.dart';
import '../models/user_data_model.dart';
import '../models/announcement_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // GREETING
          StreamBuilder<UserData?>(
            stream: bookingService.getUserDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Welcome!');
              final userName = snapshot.data!.firstName;
              return Text(
                'Welcome back, $userName!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 24),

          // ANNOUNCEMENT
          FutureBuilder<Announcement?>(
            future: bookingService.getActiveAnnouncement(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink(); // Hide if no announcement
              final announcement = snapshot.data!;
              return Card(
                color: Colors.amber.shade100,
                child: ListTile(
                  leading: const Icon(Icons.info, color: Colors.amber),
                  title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(announcement.message),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // MEMBERSHIP EXPIRY
          StreamBuilder<UserData?>(
            stream: bookingService.getUserDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final expiryDate = snapshot.data!.membershipExpiry;
              final daysLeft = expiryDate.difference(DateTime.now()).inDays;
              final formattedDate = DateFormat.yMMMd().format(expiryDate);
              
              bool isExpiringSoon = daysLeft <= 14;

              return Card(
                color: isExpiringSoon ? Colors.red.shade50 : null,
                child: ListTile(
                  leading: Icon(Icons.card_membership, color: isExpiringSoon ? Colors.red : Theme.of(context).colorScheme.primary),
                  title: const Text('Membership Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isExpiringSoon ? 'Expires in $daysLeft days on $formattedDate' : 'Active until $formattedDate'),
                ),
              );
            },
          ),

          // Quick Links (to demonstrate further navigation)
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // We can add buttons here later to go to specific places.
        ],
      ),
    );
  }
}