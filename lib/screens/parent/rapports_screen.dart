import 'package:flutter/material.dart';
import 'package:edumanager/services/rapport_service.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({Key? key}) : super(key: key);

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  final RapportService _rapportService = RapportService();
  List<Map<String, dynamic>> _rapports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRapports();
  }

  Future<void> _loadRapports() async {
    print('[RapportsScreen-Parent] Chargement des rapports...');
    setState(() => _isLoading = true);
    try {
      final rapports = await _rapportService.getRapportsValides();
      print('[RapportsScreen-Parent] ${rapports.length} rapports reçus');
      setState(() {
        _rapports = rapports;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('[RapportsScreen-Parent] Erreur: $e');
      print('[RapportsScreen-Parent] StackTrace: $stackTrace');
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
      appBar: AppBar(
        title: const Text('Rapports de séances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRapports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rapports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun rapport disponible',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les rapports validés apparaîtront ici',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
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
    );
  }

  Widget _buildRapportCard(Map<String, dynamic> rapport, ThemeData theme) {
    final eleveNom = rapport['eleve_nom'] ?? '';
    final elevePrenom = rapport['eleve_prenom'] ?? '';
    final enseignantNom = rapport['enseignant_nom'] ?? '';
    final enseignantPrenom = rapport['enseignant_prenom'] ?? '';
    final matiere = rapport['matiere'] ?? '';
    final jour = rapport['jour'] ?? '';
    final contenu = rapport['contenu'] ?? '';
    final dateRapport = rapport['date_rapport'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showRapportDetails(rapport),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matiere,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$jour - $dateRapport',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Informations
              _buildInfoRow(Icons.person, 'Élève', '$elevePrenom $eleveNom'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.school, 'Enseignant', '$enseignantPrenom $enseignantNom'),
              const SizedBox(height: 12),
              
              // Aperçu du contenu
              Text(
                'Rapport :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contenu.length > 100 ? '${contenu.substring(0, 100)}...' : contenu,
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  void _showRapportDetails(Map<String, dynamic> rapport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Expanded(child: Text('Détails du rapport')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Matière', rapport['matiere'] ?? ''),
              _buildDetailRow('Jour', rapport['jour'] ?? ''),
              _buildDetailRow('Date', rapport['date_rapport'] ?? ''),
              _buildDetailRow('Élève', '${rapport['eleve_prenom']} ${rapport['eleve_nom']}'),
              _buildDetailRow('Enseignant', '${rapport['enseignant_prenom']} ${rapport['enseignant_nom']}'),
              const Divider(height: 24),
              const Text(
                'Contenu du rapport :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rapport['contenu'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
