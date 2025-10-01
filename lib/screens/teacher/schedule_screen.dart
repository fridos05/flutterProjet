import 'package:flutter/material.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/services/rapport_service.dart';
import 'package:edumanager/models/seance_model.dart';
import 'package:edumanager/screens/teacher/create_seance_dialog.dart';
import 'package:edumanager/screens/teacher/reschedule_seance_dialog.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final SeanceService _seanceService = SeanceService();
  final RapportService _rapportService = RapportService();
  List<Seance> _seances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    print('🔄 [ScheduleScreen] Début chargement des séances...');
    setState(() => _isLoading = true);
    try {
      print('📡 [ScheduleScreen] Appel API getSeances()...');
      final seances = await _seanceService.getSeances();
      print('✅ [ScheduleScreen] ${seances.length} séances reçues');
      
      setState(() {
        _seances = seances;
        _isLoading = false;
      });
      
      print('✅ [ScheduleScreen] État mis à jour avec succès');
    } catch (e, stackTrace) {
      print('❌ [ScheduleScreen] ERREUR lors du chargement des séances');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showRapportDialog(Seance seance) async {
    final contenuController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rédiger le rapport'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Séance: ${seance.matiere}'),
              Text('${seance.jourComplet} - ${seance.heureFormatee}'),
              const SizedBox(height: 16),
              TextField(
                controller: contenuController,
                decoration: const InputDecoration(
                  labelText: 'Contenu du rapport',
                  hintText: 'Décrivez le déroulement de la séance...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contenuController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez rédiger le rapport')),
                );
                return;
              }
              
              try {
                await _rapportService.creerRapportSeance(
                  seance.id,
                  contenuController.text,
                );
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport enregistré ! En attente de validation du témoin.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSeances();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget content;
    if (_seances.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune séance',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre première séance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _loadSeances,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _seances.length,
          itemBuilder: (context, index) {
            final seance = _seances[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seance.matiere,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${seance.jour} - ${seance.heure}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (seance.valideeParParent && seance.rapportId == null)
                      ElevatedButton.icon(
                        onPressed: () => _showRapportDialog(seance),
                        icon: const Icon(Icons.description, size: 16),
                        label: const Text('Rapport', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      )
                    else ...[
                      _buildStatutBadge(seance, theme),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => RescheduleSeanceDialog(seance: seance),
                          );
                          if (result == true) {
                            _loadSeances();
                          }
                        },
                        tooltip: 'Reprogrammer',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const CreateSeanceDialog(),
          );
          
          if (result == true) {
            _loadSeances(); // Recharger les séances
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
    );
  }

  Widget _buildStatutBadge(Seance seance, ThemeData theme) {
    Color color;
    String text;
    IconData icon;

    if (seance.valideeParTemoin) {
      color = Colors.green;
      text = 'Validée';
      icon = Icons.check_circle;
    } else if (seance.valideeParParent) {
      color = Colors.blue;
      text = 'Approuvée';
      icon = Icons.thumb_up;
    } else {
      color = Colors.orange;
      text = 'En attente';
      icon = Icons.pending;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(text, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
