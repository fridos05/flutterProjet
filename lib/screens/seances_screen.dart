import 'package:edumanager/widgets/add_seance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/models/seance_model.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/services/auth_service.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/temoin_service.dart';
import 'package:edumanager/widgets/common/custom_card.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  List<Seance> _seances = [];
  List<Seance> _filteredSeances = [];
  Map<String, dynamic> _userInfo = {};
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedFilter = 'toutes';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Charger les informations utilisateur
      final authService = AuthService();
      _userInfo = await authService.getUserRoleAndId();
      
      // Charger les séances selon le rôle
      final seanceService = SeanceService();
      _seances = await seanceService.getSeancesByUserRole();
      
      // Calculer les statistiques
      _stats = _calculateStats(_seances);
      
      setState(() {
        _filteredSeances = _seances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Map<String, dynamic> _calculateStats(List<Seance> seances) {
    final now = DateTime.now();
    
    final seancesPassees = seances.where((seance) {
      final seanceDate = _parseSeanceDateTime(seance);
      return seanceDate.isBefore(now);
    }).toList();

    final seancesAVenir = seances.where((seance) {
      final seanceDate = _parseSeanceDateTime(seance);
      return seanceDate.isAfter(now);
    }).toList();

    return {
      'total': seances.length,
      'passees': seancesPassees.length,
      'a_venir': seancesAVenir.length,
      'prochaine': seancesAVenir.isNotEmpty ? seancesAVenir.first : null,
    };
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();
      
      switch (filter) {
        case 'passees':
          _filteredSeances = _seances.where((seance) {
            final seanceDate = _parseSeanceDateTime(seance);
            return seanceDate.isBefore(now);
          }).toList();
          break;
        case 'a_venir':
          _filteredSeances = _seances.where((seance) {
            final seanceDate = _parseSeanceDateTime(seance);
            return seanceDate.isAfter(now);
          }).toList();
          break;
        case 'cette_semaine':
          _filteredSeances = _seances.where((seance) {
            final seanceDate = _parseSeanceDateTime(seance);
            final weekFromNow = now.add(const Duration(days: 7));
            return seanceDate.isAfter(now) && seanceDate.isBefore(weekFromNow);
          }).toList();
          break;
        default:
          _filteredSeances = _seances;
      }
    });
  }

  DateTime _parseSeanceDateTime(Seance seance) {
    final jours = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7
    };
    
    final weekday = jours[seance.jour.toLowerCase()] ?? 1;
    final timeParts = seance.heure.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final now = DateTime.now();
    final daysUntilNext = (weekday - now.weekday) % 7;
    final nextDate = now.add(Duration(days: daysUntilNext));

    return DateTime(
      nextDate.year, nextDate.month, nextDate.day, hour, minute
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = _userInfo['role'] as String? ?? 'parent';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Séances'),
        actions: [
          if (userRole == 'enseignant')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddSeanceDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // En-tête avec informations utilisateur
                _UserHeader(
                  userRole: userRole,
                  stats: _stats,
                ),

                // Filtres
                _SeancesFilter(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: _applyFilter,
                ),

                // Liste des séances
                Expanded(
                  child: _SeancesList(
                    seances: _filteredSeances,
                    userRole: userRole,
                    onRefresh: _loadData,
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddSeanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSeanceDialog(
        onSeanceAdded: _loadData,
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final String userRole;
  final Map<String, dynamic> stats;

  const _UserHeader({
    required this.userRole,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoleIcon(userRole),
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getUserRoleDisplay(userRole),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      _getUserDescription(userRole),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatsRow(stats: stats),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'enseignant': return Icons.school;
      case 'eleve': return Icons.person;
      case 'temoin': return Icons.visibility;
      case 'parent': return Icons.family_restroom;
      default: return Icons.person;
    }
  }

  String _getUserRoleDisplay(String role) {
    switch (role) {
      case 'enseignant': return 'Enseignant';
      case 'eleve': return 'Élève';
      case 'temoin': return 'Témoin';
      case 'parent': return 'Parent';
      default: return role;
    }
  }

  String _getUserDescription(String role) {
    switch (role) {
      case 'enseignant':
        return 'Gestion de vos séances programmées';
      case 'eleve':
        return 'Vos séances de cours';
      case 'temoin':
        return 'Séances où vous êtes témoin';
      case 'parent':
        return 'Séances de vos enfants';
      default:
        return 'Vos séances';
    }
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          value: stats['total']?.toString() ?? '0',
          label: 'Total',
          color: theme.colorScheme.primary,
        ),
        _StatItem(
          value: stats['passees']?.toString() ?? '0',
          label: 'Passées',
          color: Colors.grey,
        ),
        _StatItem(
          value: stats['a_venir']?.toString() ?? '0',
          label: 'À venir',
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _SeancesFilter extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _SeancesFilter({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Toutes',
              selected: selectedFilter == 'toutes',
              onSelected: () => onFilterChanged('toutes'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'À venir',
              selected: selectedFilter == 'a_venir',
              onSelected: () => onFilterChanged('a_venir'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Passées',
              selected: selectedFilter == 'passees',
              onSelected: () => onFilterChanged('passees'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Cette semaine',
              selected: selectedFilter == 'cette_semaine',
              onSelected: () => onFilterChanged('cette_semaine'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      checkmarkColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
      ),
    );
  }
}

class _SeancesList extends StatelessWidget {
  final List<Seance> seances;
  final String userRole;
  final VoidCallback onRefresh;

  const _SeancesList({
    required this.seances,
    required this.userRole,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (seances.isEmpty) {
      return _EmptySeances(userRole: userRole);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: seances.length,
        itemBuilder: (context, index) {
          final seance = seances[index];
          return _SeanceCard(
            seance: seance,
            userRole: userRole,
            onDelete: () => _deleteSeance(context, seance),
          );
        },
      ),
    );
  }

  void _deleteSeance(BuildContext context, Seance seance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer la séance de ${seance.matiere} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SeanceService().deleteSeance(seance.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séance supprimée avec succès')),
        );
        onRefresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

class _SeanceCard extends StatelessWidget {
  final Seance seance;
  final String userRole;
  final VoidCallback onDelete;

  const _SeanceCard({
    required this.seance,
    required this.userRole,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = _isSeancePast(seance);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: isPast 
          ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
          : null,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: isPast ? Colors.grey : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seance.matiere,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey : null,
                      ),
                    ),
                    if (userRole == 'enseignant')
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: onDelete,
                            child: const Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Text(
                  '${seance.jourComplet} à ${seance.heureFormatee}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isPast ? Colors.grey : theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                _SeanceParticipants(seance: seance, userRole: userRole),
                if (isPast)
                  Text(
                    'Terminée',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSeancePast(Seance seance) {
    final seanceDate = _parseSeanceDateTime(seance);
    return seanceDate.isBefore(DateTime.now());
  }

  DateTime _parseSeanceDateTime(Seance seance) {
    final jours = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7
    };
    
    final weekday = jours[seance.jour.toLowerCase()] ?? 1;
    final timeParts = seance.heure.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final now = DateTime.now();
    final daysUntilNext = (weekday - now.weekday) % 7;
    final nextDate = now.add(Duration(days: daysUntilNext));

    return DateTime(
      nextDate.year, nextDate.month, nextDate.day, hour, minute
    );
  }
}

class _SeanceParticipants extends StatelessWidget {
  final Seance seance;
  final String userRole;

  const _SeanceParticipants({
    required this.seance,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userRole == 'parent' || userRole == 'enseignant')
          Text(
            'Élève ID: ${seance.idEleve}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        if (userRole == 'parent' || userRole == 'enseignant' || userRole == 'eleve')
          Text(
            'Témoin ID: ${seance.idTemoin}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        if (userRole == 'enseignant')
          Text(
            'Parent ID: ${seance.idParent}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}

class _EmptySeances extends StatelessWidget {
  final String userRole;

  const _EmptySeances({required this.userRole});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String message;
    String subtitle;

    switch (userRole) {
      case 'enseignant':
        message = 'Aucune séance programmée';
        subtitle = 'Commencez par programmer vos premières séances';
        break;
      case 'eleve':
        message = 'Aucune séance planifiée';
        subtitle = 'Vos séances apparaîtront ici';
        break;
      case 'temoin':
        message = 'Aucune séance en tant que témoin';
        subtitle = 'Les séances où vous êtes témoin apparaîtront ici';
        break;
      case 'parent':
        message = 'Aucune séance pour vos enfants';
        subtitle = 'Les séances de vos enfants apparaîtront ici';
        break;
      default:
        message = 'Aucune séance';
        subtitle = 'Les séances apparaîtront ici';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}