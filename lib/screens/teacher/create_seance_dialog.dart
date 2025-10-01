import 'package:flutter/material.dart';
import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/seance_service.dart';

class CreateSeanceDialog extends StatefulWidget {
  const CreateSeanceDialog({Key? key}) : super(key: key);

  @override
  State<CreateSeanceDialog> createState() => _CreateSeanceDialogState();
}

class _CreateSeanceDialogState extends State<CreateSeanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matiereController = TextEditingController();
  
  List<Map<String, dynamic>> _eleves = [];
  List<Map<String, dynamic>> _temoins = [];
  
  int? _selectedEleveId;
  int? _selectedTemoinId;
  String? _selectedJour;
  TimeOfDay? _selectedTime;
  
  bool _isLoading = true;
  bool _isSubmitting = false;

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
    _loadData();
  }

  Future<void> _loadData() async {
    print('🔄 [CreateSeanceDialog] Début chargement des données...');
    try {
      final enseignantService = EnseignantService();
      print('📡 [CreateSeanceDialog] Appel API getMesEleves()...');
      final data = await enseignantService.getMesEleves();
      print('✅ [CreateSeanceDialog] Données reçues: ${data.toString()}');
      
      setState(() {
        // Extraire les élèves
        if (data['eleves'] != null) {
          _eleves = (data['eleves'] as List).cast<Map<String, dynamic>>();
          print('✅ [CreateSeanceDialog] ${_eleves.length} élèves extraits');
          for (var eleve in _eleves) {
            print('   - Élève: ${eleve.toString()}');
          }
        } else {
          print('⚠️ [CreateSeanceDialog] Aucun élève dans la réponse');
        }
        
        // Extraire les témoins
        if (data['temoins'] != null) {
          _temoins = (data['temoins'] as List).cast<Map<String, dynamic>>();
          print('✅ [CreateSeanceDialog] ${_temoins.length} témoins extraits');
        } else {
          print('⚠️ [CreateSeanceDialog] Aucun témoin dans la réponse');
        }
        
        _isLoading = false;
      });

      // Vérifier si aucun élève
      if (_eleves.isEmpty && mounted) {
        print('⚠️ [CreateSeanceDialog] Aucun élève associé - fermeture du dialog');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun élève associé. Demandez au parent de vous associer des élèves.'),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [CreateSeanceDialog] ERREUR lors du chargement');
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createSeance() async {
    print('🔄 [CreateSeanceDialog] Début création de séance...');
    
    if (!_formKey.currentState!.validate()) {
      print('⚠️ [CreateSeanceDialog] Validation du formulaire échouée');
      return;
    }
    
    if (_selectedEleveId == null) {
      print('⚠️ [CreateSeanceDialog] Aucun élève sélectionné');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un élève')),
      );
      return;
    }
    
    if (_selectedJour == null) {
      print('⚠️ [CreateSeanceDialog] Aucun jour sélectionné');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un jour')),
      );
      return;
    }
    
    if (_selectedTime == null) {
      print('⚠️ [CreateSeanceDialog] Aucune heure sélectionnée');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une heure')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final seanceService = SeanceService();
      
      // Formater l'heure
      final heure = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      final data = {
        'jour': _selectedJour!,
        'heure': heure,
        'matiere': _matiereController.text,
        'eleve_id': _selectedEleveId!,
        'temoin_id': _selectedTemoinId,
      };

      print('📤 [CreateSeanceDialog] Envoi des données: $data');
      await seanceService.createSeanceByEnseignant(data);
      print('✅ [CreateSeanceDialog] Séance créée avec succès');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance créée ! En attente de validation du parent.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [CreateSeanceDialog] ERREUR lors de la création');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      
      setState(() => _isSubmitting = false);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_circle, size: 32, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text(
                        'Nouvelle séance',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          // Sélection de l'élève
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Élève *',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedEleveId,
                            items: _eleves.map((eleve) {
                              return DropdownMenuItem<int>(
                                value: eleve['eleve_id'] ?? eleve['id'],
                                child: Text(
                                  '${eleve['eleve_prenom'] ?? eleve['prenom'] ?? ''} ${eleve['eleve_nom'] ?? eleve['nom_famille'] ?? ''}'
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedEleveId = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Sélection du témoin (optionnel)
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Témoin (optionnel)',
                              prefixIcon: Icon(Icons.visibility),
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTemoinId,
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Aucun'),
                              ),
                              ..._temoins.map((temoin) {
                                return DropdownMenuItem<int>(
                                  value: temoin['temoin_id'] ?? temoin['id'],
                                  child: Text(
                                    '${temoin['temoin_prenom'] ?? temoin['prenom'] ?? ''} ${temoin['temoin_nom'] ?? temoin['nom'] ?? ''}'
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedTemoinId = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Matière
                          TextFormField(
                            controller: _matiereController,
                            decoration: const InputDecoration(
                              labelText: 'Matière *',
                              prefixIcon: Icon(Icons.book),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une matière';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Jour
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Jour *',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedJour,
                            items: _jours.map((jour) {
                              return DropdownMenuItem<String>(
                                value: jour,
                                child: Text(jour),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedJour = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Heure
                          InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Heure *',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedTime != null
                                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Sélectionner une heure',
                                style: TextStyle(
                                  color: _selectedTime != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _createSeance,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Créer la séance'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _matiereController.dispose();
    super.dispose();
  }
}
