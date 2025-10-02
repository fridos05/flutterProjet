import 'package:flutter/material.dart';
import 'package:edumanager/screens/teacher/schedule_screen.dart';
import 'package:edumanager/screens/teacher/students_screen.dart';
import 'package:edumanager/screens/teacher/reports_screen.dart';
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:edumanager/services/auth_service.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(Icons.calendar_month, 'Planning', 'Emploi du temps'),
    _NavigationItem(Icons.people, 'Élèves', 'Mes élèves'),
    _NavigationItem(Icons.assessment, 'Rapports', 'Mes rapports'),
    _NavigationItem(Icons.message, 'Messages', 'Communication'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userData = await authService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  String _getUserName() {
    if (_userData != null) {
      return _userData!['prenom_nom'] ?? 'Enseignant';
    }
    return 'Enseignant';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduManager',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Espace Enseignant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                _getUserName().split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mon profil'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile
                  },
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    Navigator.pop(context);
                    final authService = AuthService();
                    await authService.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.shadow.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _navigationItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == _selectedIndex;

          return Expanded( // chaque item prend une largeur égale
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8), // plus de padding horizontal
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.colorScheme.primaryContainer 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 24,
                      color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  ),
),

    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ScheduleScreen();
      case 1:
        return const StudentsScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return _MessagesScreen();
      default:
        return const ScheduleScreen();
    }
  }

  Widget _buildNavItem(_NavigationItem item, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? theme.colorScheme.primaryContainer 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String description;

  _NavigationItem(this.icon, this.label, this.description);
}

class _MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Messages',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          Text(
            'Fonctionnalité en développement',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}