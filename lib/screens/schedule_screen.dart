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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  void _fetchEvents() {
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
        _fetchEvents();
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
    final currentUserId = Provider.of<BookingService>(context, listen: false).currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Andreasen Center Schedule"),
        centerTitle: false,
        elevation: 1,
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
          // This function now has its full code restored
          _buildDateSelector(),
          const SizedBox(height: 8),
          Expanded(
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
        ],
      ),
    );
  }

  // --- THIS IS THE CORRECT, FULL CODE FOR THE DATE SELECTOR ---
  Widget _buildDateSelector() {
    return Container(
      height: 90,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7, // Show the next 7 days
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              // When a date is tapped, update the state to trigger a rebuild
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
                  // Day of the week (e.g., "Fri")
                  Text(
                    DateFormat.E().format(date), // E = Abbreviated day name
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day number (e.g., "27")
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