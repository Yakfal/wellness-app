import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // <<< ADD THIS IMPORT
import '../models/event_model.dart';
import '../services/booking_service.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AddEventScreen({super.key, required this.selectedDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  EventType _selectedType = EventType.personal;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final bookingService = Provider.of<BookingService>(context, listen: false);
      try {
        await bookingService.addUserEvent(
          title: _titleController.text,
          time: _timeController.text,
          location: _locationController.text,
          type: _selectedType,
          date: widget.selectedDate,
        );
        if (mounted) {
          // --- USE THIS SAFER METHOD TO CLOSE THE SCREEN ---
          context.pop(true); 
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add event: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      // Format the picked time and set it to our text controller
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(pickedTime);
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... The entire build method remains unchanged ...
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event for ${DateFormat.yMMMd().format(widget.selectedDate)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
             TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true, // Prevents keyboard from appearing
                onTap: _selectTime, // Show time picker when tapped
                validator: (value) => value!.isEmpty ? 'Please select a time' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                 validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save Event'),
              )
            ],
          ),
        ),
      ),
    );
  }
}