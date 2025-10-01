import 'package:flutter/material.dart';
import 'package:edumanager/models/seance_model.dart';
import 'package:edumanager/services/seance_service_debug.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/temoin_service.dart';

class AddSeanceDialog extends StatefulWidget {
  final VoidCallback onSeanceAdded;

  const AddSeanceDialog({super.key, required this.onSeanceAdded});

  @override
  State<AddSeanceDialog> createState() => _AddSeanceDialogState();
}

class _AddSeanceDialogState extends State<AddSeanceDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Contrôleurs
  final TextEditingController _matiereController = TextEditingController();
  
  // Valeurs sélectionnées
  String _selectedJour = 'monday';
  String _selectedHeure = '14:00';
  int? _selectedEleveId;
  int? _selectedTemoinId;
  int? _selectedParentId = 1; // À adapter selon l'utilisateur connecté
  
  // Listes
  List<Map<String, dynamic>> _eleves = [];
  List<Map<String, dynamic>> _temoins = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final eleves = await EleveService().getParentEleves();
      final temoins = await TemoinService().getTemoins();
      
      setState(() {
        _eleves = eleves;
        _temoins = temoins;
        
        // Sélectionner le premier élève et témoin par défaut
        if (_eleves.isNotEmpty) {
          final firstEleve = _eleves.first;
          final eleveData = firstEleve['eleve'] ?? firstEleve;
          _selectedEleveId = eleveData['id'] as int?;
        }
        if (_temoins.isNotEmpty) {
          final firstTemoin = _temoins.first;
          final temoinData = firstTemoin['temoin'] ?? firstTemoin;
          _selectedTemoinId = temoinData['id'] as int?;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement données: $e')),
        );
      }
    }
  }

  final List<String> _jours = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  final List<String> _heures = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', 
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
  ];

  String _getJourDisplay(String jour) {
    switch (jour) {
      case 'monday': return 'Lundi';
      case 'tuesday': return 'Mardi';
      case 'wednesday': return 'Mercredi';
      case 'thursday': return 'Jeudi';
      case 'friday': return 'Vendredi';
      case 'saturday': return 'Samedi';
      case 'sunday': return 'Dimanche';
      default: return jour;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programmer une séance'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Matière
              TextFormField(
                controller: _matiereController,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La matière est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Jour
              DropdownButtonFormField<String>(
                value: _selectedJour,
                decoration: const InputDecoration(
                  labelText: 'Jour',
                  border: OutlineInputBorder(),
                ),
                items: _jours.map((jour) {
                  return DropdownMenuItem<String>(
                    value: jour,
                    child: Text(_getJourDisplay(jour)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedJour = value!);
                },
              ),
              const SizedBox(height: 16),
              
              // Heure
              DropdownButtonFormField<String>(
                value: _selectedHeure,
                decoration: const InputDecoration(
                  labelText: 'Heure',
                  border: OutlineInputBorder(),
                ),
                items: _heures.map((heure) {
                  return DropdownMenuItem<String>(
                    value: heure,
                    child: Text(heure),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedHeure = value!);
                },
              ),
              const SizedBox(height: 16),
              
              // Élève
              DropdownButtonFormField<int?>(
                value: _selectedEleveId,
                decoration: const InputDecoration(
                  labelText: 'Élève',
                  border: OutlineInputBorder(),
                ),
                items: _eleves.map<DropdownMenuItem<int?>>((eleve) {
                  final eleveData = eleve['eleve'] ?? eleve;
                  final eleveId = eleveData['id'] as int?;
                  final prenom = eleveData['prenom'] as String? ?? '';
                  final nomFamille = eleveData['nom_famille'] as String? ?? '';
                  
                  return DropdownMenuItem<int?>(
                    value: eleveId,
                    child: Text('$prenom $nomFamille'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedEleveId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un élève';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Témoin
              DropdownButtonFormField<int?>(
                value: _selectedTemoinId,
                decoration: const InputDecoration(
                  labelText: 'Témoin',
                  border: OutlineInputBorder(),
                ),
                items: _temoins.map<DropdownMenuItem<int?>>((temoin) {
                  final temoinData = temoin['temoin'] ?? temoin;
                  final temoinId = temoinData['id'] as int?;
                  final prenom = temoinData['prenom'] as String? ?? '';
                  final nom = temoinData['nom'] as String? ?? '';
                  
                  return DropdownMenuItem<int?>(
                    value: temoinId,
                    child: Text('$prenom $nom'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedTemoinId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un témoin';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Programmer'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEleveId == null || _selectedTemoinId == null) return;

    setState(() => _isLoading = true);

    try {
      final seance = Seance(
        id: 0, // ID sera généré par le backend
        idEnseignant: 1, // À récupérer de l'utilisateur connecté
        idEleve: _selectedEleveId!,
        idTemoin: _selectedTemoinId!,
        idParent: _selectedParentId ?? 1,
        jour: _selectedJour,
        heure: _selectedHeure,
        matiere: _matiereController.text,
      );

      await SeanceServiceDebug().createSeances([seance]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Séance programmée avec succès')),
        );
        Navigator.pop(context);
        widget.onSeanceAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _matiereController.dispose();
    super.dispose();
  }
}