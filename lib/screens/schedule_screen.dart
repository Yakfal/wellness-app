import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/booking_service.dart';
import '../widgets/event_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // --- THIS IS THE FIX ---
    // We call _fetchEvents() directly here. It's safe because the function
    // below uses 'listen: false', which is allowed inside initState.
    // This ensures _eventsFuture is initialized before the build method runs.
    _fetchEvents();
  }

  void _fetchEvents() {
    // We use 'listen: false' here because we are not rebuilding the widget
    // based on a Provider change, but rather calling a function on the service.
    final bookingService = Provider.of<BookingService>(context, listen: false);
    setState(() {
      _eventsFuture = bookingService.getEventsForDate(_selectedDate);
    });
  }

  Future<void> _handleDelete(String eventId) async {
    final bookingService = Provider.of<BookingService>(context, listen: false);

    final bool didRequestDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this event?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (didRequestDelete) {
      try {
        await bookingService.deleteUserEvent(eventId);
        _fetchEvents(); // Re-fetch to show the updated list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete event: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = Provider.of<BookingService>(context, listen: false);
    // Use the null-aware operator '??' to provide a default value if not logged in
    final currentUserId = bookingService.currentUserId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Andreasen Center Schedule"),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>('/add-event', extra: _selectedDate);
          if (result == true) {
            _fetchEvents();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchEvents(),
              child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No events for this day.'));
                  }

                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isUserEvent = event.userId == currentUserId;

                      return EventCard(
                        event: event,
                        isUserEvent: isUserEvent,
                        onDelete: isUserEvent ? () => _handleDelete(event.id) : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 90,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _fetchEvents();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}