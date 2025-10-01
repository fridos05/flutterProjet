import 'package:flutter/material.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/models/seance_model.dart';

class SeancesValidationScreen extends StatefulWidget {
  const SeancesValidationScreen({Key? key}) : super(key: key);

  @override
  State<SeancesValidationScreen> createState() => _SeancesValidationScreenState();
}

class _SeancesValidationScreenState extends State<SeancesValidationScreen> {
  final SeanceService _seanceService = SeanceService();
  List<Seance> _seancesEnAttente = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeancesEnAttente();
  }

  Future<void> _loadSeancesEnAttente() async {
    setState(() => _isLoading = true);
    try {
      final seances = await _seanceService.getSeancesEnAttente();
      setState(() {
        _seancesEnAttente = seances;
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
      await _seanceService.validerSeance(seance.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance approuvée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSeancesEnAttente(); // Recharger la liste
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _refuserSeance(Seance seance) async {
    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la séance ?'),
        content: const Text('Êtes-vous sûr de vouloir refuser cette séance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _seanceService.refuserSeance(seance.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance refusée'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadSeancesEnAttente(); // Recharger la liste
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_seancesEnAttente.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance en attente',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les séances proposées par les enseignants apparaîtront ici',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSeancesEnAttente,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _seancesEnAttente.length,
        itemBuilder: (context, index) {
          final seance = _seancesEnAttente[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec matière et badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          seance.matiere,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: const Text('En attente'),
                        backgroundColor: Colors.orange.shade100,
                        labelStyle: TextStyle(color: Colors.orange.shade900),
                        avatar: const Icon(Icons.pending, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Informations de la séance
                  _buildInfoRow(Icons.calendar_today, 'Jour', seance.jourComplet),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, 'Heure', seance.heureFormatee),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Élève', 'ID: ${seance.idEleve}'),
                  if (seance.idTemoin > 0) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.visibility, 'Témoin', 'ID: ${seance.idTemoin}'),
                  ],
                  
                  const Divider(height: 24),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _refuserSeance(seance),
                          icon: const Icon(Icons.close),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _validerSeance(seance),
                          icon: const Icon(Icons.check),
                          label: const Text('Approuver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
