import 'package:flutter/material.dart';
import '../models/coach_model.dart'; // We now need the TimeSlot class

class BookingBottomSheet extends StatelessWidget {
  final List<TimeSlot> availableSlots;
  const BookingBottomSheet({super.key, required this.availableSlots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Time Slot',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: availableSlots.map((slot) {
              return ActionChip(
                label: Text(slot.time),
                // This is the key change: if the slot is booked, onPressed is null,
                // which automatically disables the chip.
                onPressed: slot.isBooked
                    ? null
                    : () {
                        Navigator.pop(context, slot);
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}