import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';

// This is a mock user for demonstration purposes.
// In a real application, you would pass a real user object.
final mockUser = User(
  id: 'user_001',
  name: 'Nana Yaw',
  email: 'nana.yaw@example.com',
  role: UserRole.teacher,
);

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for a real sign-out function
    void signOut() {
      // Logic to sign out the user
      // For example: FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion réussie'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon compte'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Section
            CustomCard(
              child: Column(
                children: [
                  UserAvatar(user: mockUser, size: 100),
                  const SizedBox(height: 16),
                  Text(
                    mockUser.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mockUser.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to edit profile page
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifier le profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account Settings Section
            Text(
              'Paramètres du compte',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CustomCard(
              child: Column(
                children: [
                  _SettingsListItem(
                    icon: Icons.person,
                    label: 'Informations personnelles',
                    onTap: () {},
                  ),
                  const Divider(),
                  _SettingsListItem(
                    icon: Icons.lock,
                    label: 'Sécurité et connexion',
                    onTap: () {},
                  ),
                  const Divider(),
                  _SettingsListItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Logout Button
            CustomCard(
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Déconnexion',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget for settings list items
class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
