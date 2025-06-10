import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../notifiers/appointment_notifier.dart';

class UserAppointmentsScreen extends ConsumerStatefulWidget {
  const UserAppointmentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends ConsumerState<UserAppointmentsScreen> {
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
    // --- NEW: Use ref.listen to react to booking status changes ---
    ref.listen<BookingStatus>(bookingStatusProvider, (previous, next) {
      if (next != BookingStatus.initial && next != BookingStatus.loading) {
        // This check ensures a dialog is currently open before trying to pop it
        if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Close the form dialog
        }
        
        // Show a result dialog based on the status
        _showResultDialog(next);
      }
    });

    // Watch the list of appointments for the main display
    final appointments = ref.watch(appointmentNotifierProvider);
    final displayList = [...appointments]
      ..sort((a, b) => _sortBy == 'name'
          ? a.testType.compareTo(b.testType)
          : a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopRow(),
            const SizedBox(height: 16),
            Expanded(
              child: ref.watch(bookingStatusProvider) == BookingStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                  ? const Center(
                      child: Text('No appointments found', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (_, idx) => _buildAppointmentCard(displayList[idx]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BookingStatus status) {
    final bool isSuccess = status == BookingStatus.success || status == BookingStatus.reschedulingSuccess;
    String title = "Operation Failed";
    if (status == BookingStatus.success) title = "Successfully Scheduled";
    if (status == BookingStatus.reschedulingSuccess) title = "Successfully Rescheduled";

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: !isSuccess ? const Text("An error occurred. Please try again.") : null,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // IMPORTANT: Reset the status so the dialog doesn't pop up again.
              ref.read(bookingStatusProvider.notifier).state = BookingStatus.initial;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  
  // _buildTopRow and _buildAppointmentCard do not need changes
  Widget _buildTopRow() {
    return Row(
      children: [
        PopupMenuButton<String>(
          icon: Icon(
          Icons.sort,
          color: Theme.of(context).colorScheme.primary,
        ),
          onSelected: (val) => setState(() => _sortBy = val),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'name', child: Text('By Name')),
            PopupMenuItem(value: 'date', child: Text('By Date')),
          ],
        ),
        const SizedBox(width: 5),
        Text('by $_sortBy', style: const TextStyle(fontSize: 13)),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => _showScheduleDialog(isReschedule: false),
          child: const Text('Book New Appointment'),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appt) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appt.testType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Chip(
                  label: Text(
                    appt.status == 'pending' ? 'Pending' : 'Scheduled',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: appt.status == 'pending' ? Colors.orange : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                Text(appt.date),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18, color: Colors.green),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showScheduleDialog(isReschedule: true, appointment: appt),
                  child: Text(
                    'Reschedule',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary
, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () => _showCancelDialog(appt.id),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog({required bool isReschedule, Appointment? appointment}) {
    String selectedTest = appointment?.testType ?? '';
    String selectedDate = appointment?.date ?? DateTime.now().toIso8601String().split('T').first;
    String selectedTime = appointment?.time ?? '';
    final testTypes = ['Ultrasound', 'CT Scan', 'MRI', 'Blood Work', 'CBC', 'Urinal Analysis', 'X-Ray'];
    final timeSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            isReschedule ? 'Reschedule Appointment' : 'Book New Appointment',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            // The content of the dialog does not need changes
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                // --- NEW: Logic is now async and uses the new provider ---
                if ((!isReschedule && selectedTest.isEmpty) || selectedTime.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Set status to loading
                final statusNotifier = ref.read(bookingStatusProvider.notifier);
                statusNotifier.state = BookingStatus.loading;
                
                try {
                  if (isReschedule && appointment != null) {
                    await ref.read(appointmentNotifierProvider.notifier)
                      .updateAppointment(appointment.id, appointment.testType, selectedDate, selectedTime);
                    statusNotifier.state = BookingStatus.reschedulingSuccess;
                  } else {
                    await ref.read(appointmentNotifierProvider.notifier)
                      .bookAppointment(selectedTest, selectedDate, selectedTime);
                    statusNotifier.state = BookingStatus.success;
                  }
                } catch (e) {
                  statusNotifier.state = BookingStatus.failure;
                }
              },
              child: Text(isReschedule ? 'Reschedule' : 'Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String id) {
    // This logic can remain as is, since it's simpler.
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
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Successfully cancelled'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
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