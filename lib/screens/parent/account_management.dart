import 'package:flutter/material.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/temoin_service.dart';
import 'package:edumanager/services/api_service.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  int _selectedTab = 0;
  final EleveService _eleveService = EleveService();
  final EnseignantService _enseignantService = EnseignantService();
  final TemoinService _temoinService = TemoinService();
  final ApiService _apiService = ApiService();

  List<dynamic> _eleves = [];
  List<dynamic> _enseignants = [];
  List<dynamic> _temoins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final eleves = await _eleveService.getParentEleves();
      final enseignants = await _enseignantService.getEnseignants();
      final temoins = await _temoinService.getTemoins();

      // 🔎 Debug logs
      debugPrint("== Données chargées ==");
      debugPrint("Élèves: $eleves");
      debugPrint("Enseignants: $enseignants");
      debugPrint("Témoins: $temoins");

      setState(() {
        _eleves = eleves;
        _enseignants = enseignants;
        _temoins = temoins;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint("❌ Erreur lors du chargement: $e");
      debugPrint("StackTrace: $stack");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des comptes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Actualiser',
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: const [
              Tab(text: 'Élèves', icon: Icon(Icons.school)),
              Tab(text: 'Enseignants', icon: Icon(Icons.person)),
              Tab(text: 'Témoins', icon: Icon(Icons.visibility)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: _buildTabContent(),
              ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildList(_eleves, 'élève');
      case 1:
        return _buildList(_enseignants, 'enseignant');
      case 2:
        return _buildList(_temoins, 'témoin');
      default:
        return const SizedBox();
    }
  }

  Widget _buildList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      debugPrint("⚠️ Aucun $type trouvé.");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucun $type', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Tirez vers le bas pour actualiser',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    debugPrint("✅ ${items.length} $type(s) affiché(s).");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final data = _extractData(item, type);

        debugPrint("➡️ Item $index ($type): $data");

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorByType(type),
              child: Text(
                _getInitials(data['nom']),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            title: Text(
              data['nom'] ?? 'Sans nom',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['email'] ?? 'Pas d\'email'),
                if (data['telephone'] != null)
                  Text('📞 ${data['telephone']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            trailing: type == 'enseignant'
                ? ElevatedButton.icon(
                    onPressed: () => _showAssociationDialog(item),
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Associer'),
                  )
                : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            onTap: type != 'enseignant' ? () => _showDetails(data, type) : null,
          ),
        );
      },
    );
  }

  /// Extraction sécurisée des données
 Map<String, dynamic> _extractData(dynamic item, String type) {
  Map<String, dynamic> data = {};

  if (item is Map<String, dynamic>) {
    // 🔎 Vérification de la bonne clé (API = "eleve", "enseignant", "temoin")
    dynamic obj;
    if (type == "élève") {
      obj = item["eleve"] ?? item;
    } else if (type == "enseignant") {
      obj = item["enseignant"] ?? item;
    } else if (type == "témoin") {
      obj = item["temoin"] ?? item;
    } else {
      obj = item;
    }

    debugPrint("🟢 Extraction $type depuis: $obj");

    data['nom'] = '${obj['prenom'] ?? ''} ${obj['nom_famille'] ?? obj['nom'] ?? ''}'.trim();
    data['email'] = obj['courriel'] ?? obj['email'] ?? '-';
    data['telephone'] = obj['telephone'];
    data['niveau'] = obj['niveau_id'] ?? obj['niveau'];
  }

  debugPrint("✅ Données extraites ($type): $data");
  return data;
}


  Color _getColorByType(String type) {
    switch (type) {
      case 'élève':
        return Colors.blue;
      case 'enseignant':
        return Colors.green;
      case 'témoin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showDetails(Map<String, dynamic> data, String type) {
    debugPrint("ℹ️ Détails $type: $data");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['nom'] ?? 'Détails'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', type),
            _buildDetailRow('Email', data['email'] ?? '-'),
            if (data['telephone'] != null) _buildDetailRow('Téléphone', data['telephone']),
            if (data['niveau'] != null) _buildDetailRow('Niveau', data['niveau'].toString()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Association enseignant ↔ élèves & témoin
  Future<void> _showAssociationDialog(dynamic enseignant) async {
    final data = enseignant['enseignant'] ?? enseignant;
    final enseignantId = data['id'];
    final enseignantNom = '${data['prenom']} ${data['nom_famille']}';

    List<int> selectedEleves = [];
    int? selectedTemoin;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Associer à $enseignantNom'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Sélectionnez les élèves', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._eleves.map((eleve) {
                  final eleveData = eleve['eleve'] ?? eleve;
                  final eleveId = eleveData['id'];
                  final eleveNom = '${eleveData['prenom']} ${eleveData['nom_famille']}';
                  return CheckboxListTile(
                    title: Text(eleveNom),
                    value: selectedEleves.contains(eleveId),
                    onChanged: (v) {
                      setDialogState(() {
                        v == true ? selectedEleves.add(eleveId) : selectedEleves.remove(eleveId);
                      });
                    },
                  );
                }).toList(),
                const Divider(),
                const Text('Sélectionnez un témoin (optionnel)', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._temoins.map((temoin) {
                  final t = temoin['temoin'] ?? temoin;
                  return RadioListTile<int>(
                    title: Text('${t['prenom']} ${t['nom']}'),
                    value: t['id'],
                    groupValue: selectedTemoin,
                    onChanged: (v) => setDialogState(() => selectedTemoin = v),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (selectedEleves.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Sélectionnez au moins un élève'),
                  ));
                  return;
                }
                try {
                  final body = {
                    'enseignant_id': enseignantId,
                    'eleves': selectedEleves,
                    'temoin_id': selectedTemoin,
                  };

                  debugPrint("📤 Envoi association: $body");

                  final res = await _apiService.post('/api/associations', body);

                  debugPrint("📥 Réponse serveur: ${res.statusCode} => ${res.body}");

                  if (res.statusCode == 200 || res.statusCode == 201) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Association créée avec succès !'),
                      backgroundColor: Colors.green,
                    ));
                    _loadData();
                  } else {
                    throw Exception('Erreur serveur');
                  }
                } catch (e) {
                  debugPrint("❌ Erreur association: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              },
              child: const Text('Associer'),
            ),
          ],
        ),
      ),
    );
  }
}
