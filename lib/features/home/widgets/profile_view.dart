import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final String name;
  final String dateOfBirth;

  final VoidCallback onRetry;
  final VoidCallback onChangeEmail;
  final VoidCallback onNotificationSetting;
  final VoidCallback onLogout;
  final VoidCallback onDelete;

  const ProfileView({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.name,
    required this.dateOfBirth,
    required this.onRetry,
    required this.onChangeEmail,
    required this.onNotificationSetting,
    required this.onLogout,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final bodyLarge = theme.textTheme.bodyLarge!;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    // Data state
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(dateOfBirth,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Actions
              _buildAction(
                  icon: Icons.mail_outline,
                  label: 'Change Email',
                  onTap: onChangeEmail,
                  primaryColor: primaryColor,
                  bodyStyle: bodyLarge),
              const Divider(),
              _buildAction(
                  icon: Icons.notifications_none,
                  label: 'Notification Setting',
                  onTap: onNotificationSetting,
                  primaryColor: primaryColor,
                  bodyStyle: bodyLarge),
              const Divider(),
              _buildAction(
                  icon: Icons.logout,
                  label: 'Log out',
                  onTap: onLogout,
                  primaryColor: primaryColor,
                  bodyStyle: bodyLarge),
              const Divider(),
              _buildAction(
                  icon: Icons.delete_outline,
                  label: 'Delete Profile',
                  onTap: onDelete,
                  primaryColor: Colors.red,
                  bodyStyle: bodyLarge,
                  showChevron: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
    required TextStyle bodyStyle,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: bodyStyle)),
            if (showChevron) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
