import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/temoin_service.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'add_user_bottom_sheet.dart';
import 'edit_user_bottom_sheet.dart';
import 'user_details_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  UserRole? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<User> users = [];

  List<User> get filteredUsers {
    var filtered = users;
    if (_selectedFilter != null) {
      filtered = filtered.where((u) => u.role == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<User> result = [];
    try {
      // Enseignants
      final enseignants = await EnseignantService().getEnseignants();
      result.addAll(enseignants.map((e) => User.fromEnseignant(e)));

      // Élèves
      final eleves = await EleveService().getParentEleves();

      result.addAll(eleves.map((e) => User.fromEleve(e)));

      // Témoins
      final temoins = await TemoinService().getTemoins();
      result.addAll(temoins.map((t) => User.fromTemoin(t)));

      setState(() => users = result);
    } catch (e) {
      debugPrint("❌ Erreur chargement utilisateurs: $e");
    }
  }

  void _addNewUser() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddUserBottomSheet(),
    );
    if (result == true) _loadUsers();
  }

  void _editUser(User user) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditUserBottomSheet(user: user),
    );
    if (result == true) _loadUsers();
  }

  void _deleteUser(User user) async {
    try {
      switch (user.role) {
        case UserRole.teacher:
          // TODO: await EnseignantService().delete(user.id);
          break;
        case UserRole.student:
          // TODO: await EleveService().delete(user.id);
          break;
        case UserRole.witness:
          // TODO: await TemoinService().delete(user.id);
          break;
        case UserRole.parent:
          // TODO: await ParentService().delete(user.id);
          break;
      }
      // Après suppression → rechargement
      _loadUsers();
    } catch (e) {
      debugPrint("❌ Erreur suppression utilisateur: $e");
    }
  }

  void _viewUserDetails(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserDetailsScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilter(theme),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _UserManagementCard(
                  user: user,
                  onEdit: () => _editUser(user),
                  onDelete: () => _deleteUser(user),
                  onViewDetails: () => _viewUserDetails(user),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', null),
                const SizedBox(width: 8),
                _buildFilterChip('Enseignants', UserRole.teacher),
                const SizedBox(width: 8),
                _buildFilterChip('Élèves', UserRole.student),
                const SizedBox(width: 8),
                _buildFilterChip('Témoins', UserRole.witness),
                const SizedBox(width: 8),
                _buildFilterChip('Parents', UserRole.parent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, UserRole? role) {
    final isSelected = _selectedFilter == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? role : null;
        });
      },
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const _UserManagementCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(user: user, size: 60, showStatus: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(user.role.displayName),
                    Text(user.email, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.visibility),
                label: const Text('Détails'),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Modifier'),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Supprimer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
