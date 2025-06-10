import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../model/patient_profile.dart";
import '../provider/patient_provider.dart';
import 'register_create_profile_dialog.dart';
import 'view_profile_dialog.dart';
import 'edit_profile_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import "../../../../widgets/admin-bottom_bar.dart";
import 'package:go_router/go_router.dart';
import '../../dashboard/provider/dashboard_provider.dart';
import '../../Upload/provider/lab_result_providers.dart';

// Provider to hold search query text
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to filter patients based on search query
final filteredPatientsProvider = Provider<List<PatientProfile>>((ref) {
  final patientsAsync = ref.watch(fetchAllPatientsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return patientsAsync.maybeWhen(
    data: (patients) {
      if (query.isEmpty) {
        return patients;
      }
      return patients.where((p) => 
        p.name.toLowerCase().contains(query) ||
        p.patientId.toLowerCase().contains(query) ||
        p.email.toLowerCase().contains(query) ||
        p.dateOfBirth.contains(query)
      ).toList();
    },
    orElse: () => [],
  );
});

class PatientCard extends StatelessWidget {
  final PatientProfile patient;
  final VoidCallback onEdit;
  final VoidCallback onViewProfile;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.onEdit,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${patient.patientId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'DOB: ${patient.dateOfBirth}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  patient.email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            TextButton(
              onPressed: onViewProfile,
              child: const Text('View Full Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientScreen extends ConsumerWidget {
  const PatientScreen({Key? key}) : super(key: key);

  int _getTabIndex(String location) {
    const tabRoutes = [
      '/admin-dashboard',
      '/patients',
      '/admin-upload',
      '/admin-appt',
      '/setting',
    ];
    final index = tabRoutes.indexWhere((route) => location.startsWith(route));
    return index != -1 ? index : 0;
  }

  void _handleTabTap(BuildContext context, int index) {
    const tabRoutes = [
      '/admin-dashboard',
      '/patients',
      '/admin-upload',
      '/admin-appt',
      '/setting',
    ];
    context.go(tabRoutes[index]);
  }

  void _showRegisterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => RegisterCreateProfileDialog(
        onProfileCreated: () {
          ref.invalidate(fetchAllPatientsProvider);
          ref.invalidate(dashboardProvider);
          ref.invalidate(labResultsProvider);
        },
      ),
    );
  }

  void _showViewProfileDialog(BuildContext context, PatientProfile profile) {
    showDialog(
      context: context,
      builder: (_) => ViewProfileDialog(profile: profile),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, PatientProfile profile) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        profile: profile,
        onProfileUpdated: () {
          ref.invalidate(fetchAllPatientsProvider);
          ref.invalidate(dashboardProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location =
        GoRouter.of(context).routeInformationProvider.value?.location ?? '';
    final currentIndex = _getTabIndex(location);

    final searchQuery = ref.watch(searchQueryProvider);
    final filteredPatients = ref.watch(filteredPatientsProvider);
    final patientsAsync = ref.watch(fetchAllPatientsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Patients', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRegisterDialog(context, ref),
          ),
        ],
      ),
      body: patientsAsync.when(
        data: (_) {
          if (filteredPatients.isEmpty) {
            return Center(
              child: Text(
                searchQuery.isEmpty ? 'No patients found.' : 'No matching patients.',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search patients…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filteredPatients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return PatientCard(
                      patient: patient,
                      onEdit: () => _showEditProfileDialog(context, ref, patient),
                      onViewProfile: () => _showViewProfileDialog(context, patient),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}
