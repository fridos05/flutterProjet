import 'package:flutter/material.dart';

// =============== MODÈLE UTILISATEUR ===============
enum UserRole {
  student('Élève'),
  parent('Parent'),
  teacher('Enseignant'),
  admin('Administrateur');

  final String label;
  const UserRole(this.label);
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });
}

// =============== SERVICE MOCK ===============
class UserService {
  final List<AppUser> _users = [
    AppUser(id: 'u1', name: 'Jean Dupont', email: 'jean@edumanager.com', role: UserRole.student),
    AppUser(id: 'u2', name: 'Marie Lefevre', email: 'marie@edumanager.com', role: UserRole.parent),
    AppUser(id: 'u3', name: 'Paul Martin', email: 'paul@edumanager.com', role: UserRole.teacher),
    AppUser(id: 'u4', name: 'Sophie Renard', email: 'sophie@edumanager.com', role: UserRole.admin),
    AppUser(id: 'u5', name: 'Lucas Moreau', email: 'lucas@edumanager.com', role: UserRole.student),
  ];

  Future<List<AppUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_users);
  }

  Future<void> toggleUserStatus(String userId) async {
    final user = _users.firstWhere((u) => u.id == userId);
    // Ici, on simule la désactivation (tu peux l’étendre)
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: !user.isActive,
      );
    }
  }
}

// =============== ÉCRAN DE GESTION ===============
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<AppUser>> _futureUsers;
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _futureUsers = _userService.getUsers();
    });
  }

  List<AppUser> _filterUsers(List<AppUser> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) =>
        user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student: return Colors.blue;
      case UserRole.parent: return Colors.green;
      case UserRole.teacher: return Colors.orange;
      case UserRole.admin: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AppUser>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                final allUsers = snapshot.data ?? [];
                final filteredUsers = _filterUsers(allUsers);

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                          child: Icon(
                            _getRoleIcon(user.role),
                            color: _getRoleColor(user.role),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text('${user.email} • ${user.role.label}'),
                        trailing: Switch(
                          value: user.isActive,
                          onChanged: (value) async {
                            await _userService.toggleUserStatus(user.id);
                            _refreshUsers();
                          },
                        ),
                        onTap: () {
                          // Optionnel : ouvrir un écran de détail
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Optionnel : ajouter un utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à implémenter')),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student: return Icons.person;
      case UserRole.parent: return Icons.family_restroom;
      case UserRole.teacher: return Icons.school;
      case UserRole.admin: return Icons.admin_panel_settings;
    }
  }
}

