import 'package:flutter/material.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/services/auth_service.dart';
import 'package:edumanager/models/seance_model.dart';
import 'package:edumanager/screens/auth/login_screen.dart';

class TemoinDashboard extends StatefulWidget {
  const TemoinDashboard({Key? key}) : super(key: key);

  @override
  State<TemoinDashboard> createState() => _TemoinDashboardState();
}

class _TemoinDashboardState extends State<TemoinDashboard> with SingleTickerProviderStateMixin {
  final SeanceService _seanceService = SeanceService();
  List<Seance> _seancesAValider = [];
  List<Seance> _seancesValidees = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSeances();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSeances() async {
    setState(() => _isLoading = true);
    try {
      final seancesAValider = await _seanceService.getSeancesAValiderTemoin();
      final toutesSeances = await _seanceService.getSeancesTemoin();
      
      setState(() {
        _seancesAValider = seancesAValider;
        _seancesValidees = toutesSeances.where((s) => s.valideeParTemoin).toList();
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

  Future<void> _validerSeance(Seance seance) async {
    try {
      await _seanceService.validerSeanceTemoin(seance.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance validée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSeances(); // Recharger la liste
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Témoin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${_seancesAValider.length}'),
                isLabelVisible: _seancesAValider.isNotEmpty,
                child: const Icon(Icons.pending_actions),
              ),
              text: 'À valider',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Validées',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSeancesAValider(),
                _buildSeancesValidees(),
              ],
            ),
    );
  }

  Widget _buildSeancesAValider() {
    if (_seancesAValider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance à valider',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les séances approuvées par les parents apparaîtront ici',
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
        itemCount: _seancesAValider.length,
        itemBuilder: (context, index) {
          final seance = _seancesAValider[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
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
                          seance.matiere,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: const Text('Approuvée'),
                        backgroundColor: Colors.blue.shade100,
                        labelStyle: TextStyle(color: Colors.blue.shade900),
                        avatar: const Icon(Icons.thumb_up, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today, 'Jour', seance.jourComplet),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, 'Heure', seance.heureFormatee),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Élève', 'ID: ${seance.idEleve}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.school, 'Enseignant', 'ID: ${seance.idEnseignant}'),
                  const Divider(height: 24),
                  // Afficher le rapport
                  if (seance.rapport != null) ...[
                    const Text(
                      'Rapport de l\'enseignant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        seance.rapport!['contenu'] ?? 'Aucun contenu',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _validerSeance(seance),
                      icon: const Icon(Icons.check),
                      label: const Text('Valider la séance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeancesValidees() {
    if (_seancesValidees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance validée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeances,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seancesValidees.length,
        itemBuilder: (context, index) {
          final seance = _seancesValidees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.check, color: Colors.green.shade700),
              ),
              title: Text(seance.matiere),
              subtitle: Text('${seance.jourComplet} - ${seance.heureFormatee}'),
              trailing: Chip(
                label: const Text('Validée'),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(color: Colors.green.shade900, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(value),
      ],
    );
  }
}
