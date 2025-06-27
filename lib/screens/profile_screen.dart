import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/booking_service.dart';
import '../widgets/event_card.dart';
import '../widgets/wellness_tip_card.dart';
import '../models/wellness_tip_model.dart';
import '../widgets/stat_card.dart'; // <<< ADD THIS IMPORT

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // We make it stateful to handle refreshing the appointments
  late Future<List<Event>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is first loaded
    _fetchAppointments();
  }

  void _fetchAppointments() {
    final bookingService = Provider.of<BookingService>(context, listen: false);
    setState(() {
      _appointmentsFuture = bookingService.getMyUpcomingAppointments();
    });
  }

  WellnessTip getDailyTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return wellnessTips[dayOfYear % wellnessTips.length];
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wellness Journey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              await bookingService.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchAppointments();
        },
        child: ListView( // Use ListView for scrollable content
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- USER HEADER ---
            Row(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wellness Member', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Membership: Community', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- USAGE STATS SECTION ---
            const Row(
              children: [
                StatCard(title: 'Visits This Month', value: '8', icon: Icons.login),
                SizedBox(width: 12),
                StatCard(title: 'Classes Attended', value: '3', icon: Icons.fitness_center),
              ],
            ),
            const SizedBox(height: 8),
            
            // --- LINK TO MEMBERSHIP PAGE ---
            ListTile(
              leading: const Icon(Icons.card_membership_rounded),
              title: const Text('Memberships & Passes'),
              subtitle: const Text('View tiers and renewal options'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // This is the button you were missing!
                context.push('/membership');
              },
            ),
            const Divider(),

            // --- DAILY WELLNESS TIP SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: WellnessTipCard(tip: getDailyTip()),
            ),
            
            // --- UPCOMING APPOINTMENTS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Your Upcoming Schedule', style: theme.textTheme.titleLarge),
            ),
            FutureBuilder<List<Event>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('You have no upcoming appointments.'),
                  ));
                }
                
                final appointments = snapshot.data!;
                return Column(
                  children: appointments.map((appointment) => EventCard(event: appointment, isUserEvent: true)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}