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

      setState(() {
        _eleves = eleves;
        _enseignants = enseignants;
        _temoins = temoins;
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
    print('📋 Affichage de ${items.length} $type(s)');
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun $type',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tirez vers le bas pour actualiser',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Extraire les données selon le type
        final data = _extractData(item, type);
        
        print('📄 Item $index ($type): ${data['nom']}');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorByType(type),
              child: Text(
                _getInitials(data),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
                  Text(
                    '📞 ${data['telephone']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: type == 'enseignant'
                ? ElevatedButton.icon(
                    onPressed: () => _showAssociationDialog(item),
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Associer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
            onTap: type != 'enseignant'
                ? () => _showDetails(data, type)
                : null,
          ),
        );
      },
    );
  }

  Map<String, dynamic> _extractData(dynamic item, String type) {
    // Les données peuvent être dans différents formats selon le backend
    if (item is Map<String, dynamic>) {
      // Si c'est une association parent-élève/enseignant/témoin
      if (item.containsKey('eleve')) {
        final eleve = item['eleve'];
        return {
          'nom': '${eleve['prenom'] ?? ''} ${eleve['nom_famille'] ?? ''}'.trim(),
          'email': eleve['courriel'],
          'telephone': eleve['telephone'],
          'niveau': eleve['niveau_id'],
        };
      } else if (item.containsKey('enseignant') && item['enseignant'] != null) {
        final ens = item['enseignant'];
        return {
          'nom': '${ens['prenom'] ?? ''} ${ens['nom_famille'] ?? ''}'.trim(),
          'email': ens['courriel'] ?? '',
          'telephone': ens['telephone'] ?? '',
        };
      } else if (item.containsKey('temoin') && item['temoin'] != null) {
        final tem = item['temoin'];
        return {
          'nom': '${tem['prenom'] ?? ''} ${tem['nom'] ?? ''}'.trim(),
          'email': tem['courriel'] ?? '',
          'telephone': tem['telephone'] ?? '',
        };
      } else {
        // Format direct
        return {
          'nom': item['prenom_nom'] ?? 
                 '${item['prenom'] ?? ''} ${item['nom_famille'] ?? item['nom'] ?? ''}'.trim(),
          'email': item['courriel'] ?? item['email'],
          'telephone': item['telephone'],
          'niveau': item['niveau_id'] ?? item['niveau'],
        };
      }
    }
    return {'nom': 'Inconnu', 'email': '', 'telephone': null};
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

  String _getInitials(dynamic item) {
    final name = item['prenom_nom'] ?? item['nom'] ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showDetails(dynamic item, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['prenom_nom'] ?? item['nom'] ?? 'Détails'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', type),
            _buildDetailRow('Email', item['courriel'] ?? item['email'] ?? '-'),
            if (item['telephone'] != null)
              _buildDetailRow('Téléphone', item['telephone']),
            if (item['niveau'] != null)
              _buildDetailRow('Niveau', item['niveau'].toString()),
          ],
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

  // Dialog pour associer élèves et témoin à un enseignant
  Future<void> _showAssociationDialog(dynamic enseignant) async {
    final enseignantData = enseignant['enseignant'] ?? enseignant;
    final enseignantId = enseignantData['id'];
    final enseignantNom = '${enseignantData['prenom']} ${enseignantData['nom_famille']}';

    // Sélections multiples
    List<int> selectedEleves = [];
    int? selectedTemoin;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Associer à $enseignantNom'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sélectionnez les élèves',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ..._eleves.map((eleve) {
                  final eleveData = eleve['eleve'] ?? eleve;
                  final eleveId = eleveData['id'];
                  final eleveNom = '${eleveData['prenom']} ${eleveData['nom_famille']}';
                  
                  return CheckboxListTile(
                    title: Text(eleveNom),
                    value: selectedEleves.contains(eleveId),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedEleves.add(eleveId);
                        } else {
                          selectedEleves.remove(eleveId);
                        }
                      });
                    },
                  );
                }).toList(),
                const Divider(height: 32),
                const Text(
                  'Sélectionnez un témoin (optionnel)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ..._temoins.map((temoin) {
                  final temoinData = temoin['temoin'] ?? temoin;
                  final temoinId = temoinData['id'];
                  final temoinNom = '${temoinData['prenom']} ${temoinData['nom']}';
                  
                  return RadioListTile<int>(
                    title: Text(temoinNom),
                    value: temoinId,
                    groupValue: selectedTemoin,
                    onChanged: (int? value) {
                      setDialogState(() {
                        selectedTemoin = value;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedEleves.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner au moins un élève')),
                  );
                  return;
                }

                try {
                  // Appel API pour créer l'association
                  final response = await _apiService.post('/api/associations', {
                    'enseignant_id': enseignantId,
                    'eleves': selectedEleves,
                    'temoin_id': selectedTemoin,
                  });

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Association créée avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadData(); // Recharger les données
                  } else {
                    throw Exception('Erreur lors de l\'association');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
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
