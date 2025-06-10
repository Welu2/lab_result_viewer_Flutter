import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/appointments_view.dart';
import '../notifiers/appointment_notifier.dart';
import '../models/appointment.dart';

class UserAppointmentsScreen extends ConsumerStatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  ConsumerState<UserAppointmentsScreen> createState() =>
      _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState
    extends ConsumerState<UserAppointmentsScreen> {
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentNotifierProvider.notifier).loadUserAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppointmentsView(
          appointments: appointments,
          sortBy: _sortBy,
          onSortSelected: (val) => setState(() => _sortBy = val),
          onBookNew: () => _showScheduleDialog(isReschedule: false),
          onReschedule: (appt) =>
              _showScheduleDialog(isReschedule: true, appointment: appt),
          onCancel: (id) => _showCancelDialog(id),
        ),
      ),
    );
  }

  void _showScheduleDialog({required bool isReschedule, Appointment? appointment}) {
    final notifier = ref.read(appointmentNotifierProvider.notifier);
    String selectedTest = appointment?.testType ?? '';
    String selectedDate = appointment?.date ?? DateTime.now().toIso8601String().split('T').first;
    String selectedTime = appointment?.time ?? '';
    final testTypes = ['Ultrasound', 'CT Scan', 'MRI', 'Blood Work', 'CBC', 'Urinal Analysis', 'X-Ray'];
    final timeSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            isReschedule ? 'Reschedule Appointment' : 'Book New Appointment',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isReschedule) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Test Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    items: testTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => selectedTest = v ?? ''),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Test Type',
                    ),
                    value: selectedTest.isEmpty ? null : selectedTest,
                  ),
                  const SizedBox(height: 16),
                ],
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Preferred Date', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.parse(selectedDate),
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) setState(() => selectedDate = picked.toIso8601String().split('T').first);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(selectedDate),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Available Time Slots', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlots.map((slot) => ChoiceChip(
                    label: Text(slot),
                    selected: selectedTime == slot,
                    onSelected: (_) => setState(() => selectedTime = slot),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(color: selectedTime == slot ? Colors.white : null),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                if (isReschedule && appointment != null && selectedDate == appointment.date && selectedTime == appointment.time) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error Rescheduling'),
                      content: const Text('Please select a different date or time.'),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to rescheduling options'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                if ((!isReschedule && selectedTest.isEmpty) || selectedDate.isEmpty || selectedTime.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(isReschedule ? 'Rescheduling failed' : 'Scheduling failed'),
                      content: Text(isReschedule
                          ? 'Could not reschedule appointment.'
                          : 'Could not schedule appointment.'),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: Text(isReschedule ? 'Back to rescheduling options' : 'Back to scheduling options'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                final success = isReschedule && appointment != null
                    ? await notifier.updateAppointment(appointment.id, appointment.testType, selectedDate, selectedTime)
                    : await notifier.bookAppointment(selectedTest, selectedDate, selectedTime);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(isReschedule
                        ? 'Successfully rescheduled'
                        : 'Successfully scheduled'),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Home'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(isReschedule ? 'Reschedule Appointment' : 'Schedule Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String id) {
    final notifier = ref.read(appointmentNotifierProvider.notifier);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure you want to cancel this appointment?', style: TextStyle(fontWeight: FontWeight.bold)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await notifier.deleteAppointment(id);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Successfully cancelled'),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes, cancel appointment'),
          )
        ],
      ),
    );
  }
}
