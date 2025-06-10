import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/appt_provider.dart';
import '../../../../widgets/admin-bottom_bar.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final List<String> filters = ['today', 'upcoming', 'past'];
  int selectedIndex = 0;

  int _getTabIndex(String location) {
    const tabRoutes = [
      '/admin-dashboard',
      '/patients',
      '/admin-upload',
      '/admin-appt',
      '/setting', // fixed spelling
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
      '/setting', // fixed spelling
    ];
    context.go(tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location =
        GoRouter.of(context).routeInformationProvider.value?.location ?? '';
    final currentIndex = _getTabIndex(location);

    final selectedFilter = filters[selectedIndex];
    final appointmentsAsync = ref.watch(appointmentsProvider(selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Appointments', style: TextStyle(color: Colors.black)),
        ),
        actions: [
          // ... existing code ...
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 8),
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) => ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final date = DateTime.parse(appt.date);
                  final time = appt.time;
                  final testType = appt.testType;
                  final patientId = appt.patient.patientId;

                  return ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('$time '),
                    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$testType'),
      Text('$patientId'),
    ],
  ),
                    trailing: Text(DateFormat('MMM d').format(date)),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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

  Widget _buildTabBar() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(filters.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  filters[index][0].toUpperCase() + filters[index].substring(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
              ],
            ),
          );
        }),
      ),
    );
  }
}
