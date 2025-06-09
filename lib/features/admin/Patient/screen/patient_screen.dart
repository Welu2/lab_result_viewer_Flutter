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
      return patients
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    },
    orElse: () => [],
  );
});

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
      builder: (_) => EditProfileDialog(profile: profile,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRegisterDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search patients by name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Text(searchQuery.isEmpty
                        ? 'No patients found.'
                        : 'No matching patients.'),
                  )
                : ListView.separated(
                    itemCount: filteredPatients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: const Icon(Icons.person),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('ID: ${patient.patientId}'),
                            Text('DOB: ${patient.dateOfBirth}'),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 16),
                                const SizedBox(width: 4),
                                Text(patient.email),
                              ],
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () =>
                                  _showViewProfileDialog(context, patient),
                              child: Text(
                                'View Full Profile',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditProfileDialog(context, ref, patient),

                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}
