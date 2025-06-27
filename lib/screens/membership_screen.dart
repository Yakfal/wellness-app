import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/membership_tier_model.dart';
import '../services/booking_service.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, List<MembershipTier>>> _tiersFuture;

  final List<Tab> _tabs = const [
    Tab(text: 'Monthly'),
    Tab(text: 'Annual'),
    Tab(text: 'Passes'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    final bookingService = Provider.of<BookingService>(context, listen: false);
    _tiersFuture = bookingService.getMembershipTiers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memberships & Passes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      body: FutureBuilder<Map<String, List<MembershipTier>>>(
        future: _tiersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No membership tiers found.'));
          }

          final categorizedTiers = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((Tab tab) {
              final tiersForTab = categorizedTiers[tab.text!] ?? [];
              if (tiersForTab.isEmpty) {
                return Center(child: Text('No ${tab.text} plans available.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tiersForTab.length,
                itemBuilder: (context, index) {
                  return _MembershipTierCard(tier: tiersForTab[index]);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// A dedicated card widget for displaying a single tier.
class _MembershipTierCard extends StatelessWidget {
  final MembershipTier tier;
  const _MembershipTierCard({required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tier.price, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            Text(tier.description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { /* Could link to a payment URL */ },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}