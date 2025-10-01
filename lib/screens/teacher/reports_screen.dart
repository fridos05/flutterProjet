import 'package:flutter/material.dart';
import 'package:edumanager/services/rapport_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final RapportService _rapportService = RapportService();
  List<Map<String, dynamic>> _rapports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRapports();
  }

  Future<void> _loadRapports() async {
    setState(() => _isLoading = true);
    try {
      final rapports = await _rapportService.getMesRapports();
      setState(() {
        _rapports = rapports;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assessment,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes rapports',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Suivi et évaluations',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rapports.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadRapports,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rapports.length,
                          itemBuilder: (context, index) {
                            final rapport = _rapports[index];
                            return _buildRapportCard(rapport, theme);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun rapport',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos rapports apparaîtront ici',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRapportCard(Map<String, dynamic> rapport, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.description,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          '${rapport['enseignant_prenom']} ${rapport['enseignant_nom']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${rapport['date_rapport']} • ${rapport['heure_debut']} - ${rapport['heure_fin']}'),
            if (rapport['eleves'] != null)
              Text(
                'Élèves: ${rapport['eleves']}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: () {
          _showRapportDetails(rapport);
        },
      ),
    );
  }

  void _showRapportDetails(Map<String, dynamic> rapport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rapport du ${rapport['date_rapport']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enseignant:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${rapport['enseignant_prenom']} ${rapport['enseignant_nom']}'),
              const SizedBox(height: 12),
              Text(
                'Horaire:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${rapport['heure_debut']} - ${rapport['heure_fin']}'),
              const SizedBox(height: 12),
              if (rapport['eleves'] != null) ...[
                Text(
                  'Élèves:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(rapport['eleves']),
                const SizedBox(height: 12),
              ],
              Text(
                'Contenu:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(rapport['contenu'] ?? 'Aucun contenu'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
