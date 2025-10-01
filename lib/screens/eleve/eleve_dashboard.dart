import 'package:flutter/material.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/services/auth_service.dart';
import 'package:edumanager/models/seance_model.dart';
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:intl/intl.dart';

class EleveDashboard extends StatefulWidget {
  const EleveDashboard({Key? key}) : super(key: key);

  @override
  State<EleveDashboard> createState() => _EleveDashboardState();
}

class _EleveDashboardState extends State<EleveDashboard> {
  final SeanceService _seanceService = SeanceService();
  List<Seance> _seances = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  final List<String> _jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    setState(() => _isLoading = true);
    try {
      final seances = await _seanceService.getSeancesEleve();
      setState(() {
        _seances = seances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  List<Seance> _getSeancesByJour(String jour) {
    return _seances.where((s) => s.jourComplet == jour).toList();
  }

  List<Seance> _getProchainsCours() {
    // Retourne les séances validées par parent (approuvées)
    return _seances.where((s) => s.valideeParParent).toList();
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
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EduManager', style: TextStyle(fontSize: 16)),
                Text('Espace Élève', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildEmploiDuTemps()
              : _buildProchainsCours(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_view_week),
            selectedIcon: Icon(Icons.calendar_view_week, color: theme.colorScheme.primary),
            label: 'Emploi du temps',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${_getProchainsCours().length}'),
              isLabelVisible: _getProchainsCours().isNotEmpty,
              child: const Icon(Icons.event),
            ),
            selectedIcon: Badge(
              label: Text('${_getProchainsCours().length}'),
              isLabelVisible: _getProchainsCours().isNotEmpty,
              child: Icon(Icons.event, color: theme.colorScheme.primary),
            ),
            label: 'Cours à venir',
          ),
        ],
      ),
    );
  }

  Widget _buildEmploiDuTemps() {
    if (_seances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre emploi du temps apparaîtra ici',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeances,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jours.length,
        itemBuilder: (context, index) {
          final jour = _jours[index];
          final seancesJour = _getSeancesByJour(jour);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: seancesJour.isEmpty
                    ? Colors.grey.shade300
                    : Colors.blue.shade100,
                child: Text(
                  jour.substring(0, 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: seancesJour.isEmpty
                        ? Colors.grey.shade600
                        : Colors.blue.shade900,
                  ),
                ),
              ),
              title: Text(
                jour,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                seancesJour.isEmpty
                    ? 'Aucune séance'
                    : '${seancesJour.length} séance${seancesJour.length > 1 ? 's' : ''}',
              ),
              children: seancesJour.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Pas de cours ce jour',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ]
                  : seancesJour.map((seance) {
                      return ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: Colors.blue.shade700,
                        ),
                        title: Text(seance.matiere),
                        subtitle: Text('${seance.heureFormatee}'),
                        trailing: _buildStatutBadge(seance),
                      );
                    }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProchainsCours() {
    final prochainsCours = _getProchainsCours();

    if (prochainsCours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours à venir',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les cours approuvés apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeances,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prochainsCours.length,
        itemBuilder: (context, index) {
          final seance = prochainsCours[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.book,
                  color: Colors.blue.shade700,
                ),
              ),
              title: Text(
                seance.matiere,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(seance.jourComplet),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(seance.heureFormatee),
                    ],
                  ),
                ],
              ),
              trailing: _buildStatutBadge(seance),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatutBadge(Seance seance) {
    Color color;
    String text;
    IconData icon;

    if (seance.valideeParTemoin) {
      color = Colors.green;
      text = 'Validée';
      icon = Icons.check_circle;
    } else if (seance.valideeParParent) {
      color = Colors.blue;
      text = 'Confirmée';
      icon = Icons.thumb_up;
    } else {
      color = Colors.orange;
      text = 'En attente';
      icon = Icons.pending;
    }

    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(text, style: TextStyle(color: color, fontSize: 11)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
