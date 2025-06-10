import 'package:flutter/material.dart';
import '../models/appointment.dart';

/// A stateless view of the appointments list, with sorting and book-new button.
class AppointmentsView extends StatelessWidget {
  final List<Appointment> appointments;
  final String sortBy;
  final ValueChanged<String> onSortSelected;
  final VoidCallback onBookNew;
  final ValueChanged<Appointment> onReschedule;
  final ValueChanged<String> onCancel;

  const AppointmentsView({
    super.key,
    required this.appointments,
    required this.sortBy,
    required this.onSortSelected,
    required this.onBookNew,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Make a sorted copy
    final displayList = [...appointments]
      ..sort((a, b) => sortBy == 'name'
          ? a.testType.compareTo(b.testType)
          : a.date.compareTo(b.date));

    return Column(
      children: [
        // Top Row
        Row(
          children: [
            PopupMenuButton<String>(
              key: const Key('sort_menu'),
              icon: Icon(Icons.sort,
                  color: Theme.of(context).colorScheme.primary),
              onSelected: onSortSelected,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'name', child: Text('By Name')),
                PopupMenuItem(value: 'date', child: Text('By Date')),
              ],
            ),
            const SizedBox(width: 8),
            Text('by $sortBy', key: const Key('sort_label')),
            const Spacer(),
            ElevatedButton(
              key: const Key('book_button'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: onBookNew,
              child: const Text('Book New Appointment'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: displayList.isEmpty
              ? const Center(
                  child: Text('No appointments found',
                      key: Key('empty'), style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  key: const Key('list'),
                  itemCount: displayList.length,
                  itemBuilder: (_, idx) {
                    final appt = displayList[idx];
                    return Card(
                      key: Key('card_${appt.id}'),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + status
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(appt.testType,
                                    key: Key('title_${appt.id}'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Chip(
                                  key: Key('chip_${appt.id}'),
                                  label: Text(
                                    appt.status == 'pending'
                                        ? 'Pending'
                                        : 'Scheduled',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: appt.status == 'pending'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Date & time row
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(appt.date,
                                    key: Key('date_${appt.id}')),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    size: 18, color: Colors.green),
                                const SizedBox(width: 6),
                                Text(appt.time,
                                    key: Key('time_${appt.id}')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Reschedule / Cancel
                            Row(
                              children: [
                                GestureDetector(
                                  key: Key('reschedule_${appt.id}'),
                                  onTap: () => onReschedule(appt),
                                  child: Text('Reschedule',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 24),
                                GestureDetector(
                                  key: Key('cancel_${appt.id}'),
                                  onTap: () => onCancel(appt.id),
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
