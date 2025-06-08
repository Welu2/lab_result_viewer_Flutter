import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/approval_notifier.dart';

class AppointmentsApprovalScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentNotifierProvider);
    final notifier = ref.read(appointmentNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
        title: const Text('Appointments Approval'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appointments) {
          final pending =
              appointments.where((a) => a.status == 'pending').toList();

          if (pending.isEmpty) {
            return const Center(child: Text('No pending appointments found'));
          }

          return ListView.builder(
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final appointment = pending[index];
              return ListTile(
                title: Text('${appointment.patient.patientId}'),
                subtitle: Text('${appointment.date}  ${appointment.time}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => notifier.approve(appointment.id),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF81C784),
                      ),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => notifier.decline(appointment.id),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE57373),
                      ),
                      child: const Text('Decline'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
