import 'package:flutter/material.dart';
import 'package:edumanager/services/parent_service.dart';
import 'package:edumanager/services/auth_service.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/temoin_service.dart';
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:edumanager/screens/parent/account_management.dart';
import 'package:edumanager/screens/parent/statistics_payments.dart';
import 'package:edumanager/screens/parent/rescheduling_screen.dart';
import 'package:edumanager/screens/parent/seances_validation_screen.dart';
import 'package:edumanager/screens/parent/rapports_screen.dart';


class ParentDashboard extends StatefulWidget {
  final dynamic currentUser;

  const ParentDashboard({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  final ParentService _parentService = ParentService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _parentService.getStats();
      setState(() {
        _stats = stats;
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

  List<Widget> get _screens => [
    _HomeTab(stats: _stats, isLoading: _isLoading, onRefresh: _loadStats),
    AccountManagementScreen(),
    const StatisticsPaymentsScreen(),
    ScheduleScreen(),
    const SeancesValidationScreen(),
    const RapportsScreen(),
  ];

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduManager',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Espace Parent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                _getUserInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 12),
                    Text('Mon profil'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context, theme),
      body: _screens[_selectedIndex],
    );
  }

  String _getUserInitials() {
    if (widget.currentUser == null) return 'U';
    final prenomNom = widget.currentUser['prenom_nom'] ?? '';
    final nomFamille = widget.currentUser['nom_famille'] ?? '';
    return '${prenomNom.isNotEmpty ? prenomNom[0] : ''}${nomFamille.isNotEmpty ? nomFamille[0] : ''}'.toUpperCase();
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getUserInitials(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.currentUser['prenom_nom'] ?? 'Parent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.currentUser['courriel'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation principale
          ListTile(
            leading: Icon(Icons.home, color: _selectedIndex == 0 ? theme.colorScheme.primary : null),
            title: const Text('Accueil'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.people, color: _selectedIndex == 1 ? theme.colorScheme.primary : null),
            title: const Text('Gestion des comptes'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.bar_chart, color: _selectedIndex == 2 ? theme.colorScheme.primary : null),
            title: const Text('Statistiques'),
            selected: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.calendar_today, color: _selectedIndex == 3 ? theme.colorScheme.primary : null),
            title: const Text('Planning'),
            selected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.check_circle, color: _selectedIndex == 4 ? theme.colorScheme.primary : null),
            title: const Text('Validations'),
            selected: _selectedIndex == 4,
            onTap: () {
              setState(() => _selectedIndex = 4);
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: Icon(Icons.description, color: _selectedIndex == 5 ? theme.colorScheme.primary : null),
            title: const Text('Rapports'),
            selected: _selectedIndex == 5,
            onTap: () {
              setState(() => _selectedIndex = 5);
              Navigator.pop(context);
            },
          ),
          
          const Divider(),
          
          // Section Création de comptes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'CRÉER UN COMPTE',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: const Text('Ajouter un élève'),
            onTap: () {
              Navigator.pop(context);
              _showCreateEleveDialog();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Ajouter un enseignant'),
            onTap: () {
              Navigator.pop(context);
              _showCreateEnseignantDialog();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.visibility, color: Colors.orange),
            title: const Text('Ajouter un témoin'),
            onTap: () {
              Navigator.pop(context);
              _showCreateTemoinDialog();
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCreateEleveDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateEleveDialog(),
    );
  }

  void _showCreateEnseignantDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateEnseignantDialog(),
    );
  }

  void _showCreateTemoinDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateTemoinDialog(),
    );
  }
}

// Dialog pour créer un élève
class _CreateEleveDialog extends StatefulWidget {
  @override
  State<_CreateEleveDialog> createState() => _CreateEleveDialogState();
}

class _CreateEleveDialogState extends State<_CreateEleveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _prenomNomController = TextEditingController();
  final _nomFamilleController = TextEditingController();
  final _courrielController = TextEditingController();
  final _telephoneController = TextEditingController();
  int _niveau = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomNomController.dispose();
    _nomFamilleController.dispose();
    _courrielController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _createEleve() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire élève échouée');
      return;
    }

    print('📝 Début de la création d\'un élève...');
    setState(() => _isLoading = true);
    
    try {
      final data = {
        'prenom': _prenomNomController.text,
        'nom_famille': _nomFamilleController.text,
        'courriel': _courrielController.text,
        'telephone': _telephoneController.text,
        'niveau_id': _niveau,
      };
      
      print('📤 Envoi des données élève: $data');
      
      final result = await EleveService().createEleve(data);
      
      print('✅ Élève créé avec succès: $result');

      if (mounted) {
        Navigator.pop(context);
        
        // Afficher le mot de passe généré
        final password = result['password'] ?? 'password';
        final email = result['email'] ?? _courrielController.text;
        print('🔑 Mot de passe généré: $password');
        print('📧 Email: $email');
        
        // Afficher un dialog avec les informations de connexion
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Élève créé !'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'L\'élève a été créé avec succès.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Informations de connexion:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              password,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (result['email_sent'] == true)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '✅ Email envoyé avec succès !',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Email non envoyé. Notez ce mot de passe !',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR lors de la création de l\'élève:');
      print('   Message: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création:\n$e'),
            duration: const Duration(seconds: 7),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('🏁 Fin de la création d\'élève');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un élève'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _prenomNomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom et nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomFamilleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de famille',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courrielController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _niveau,
                decoration: const InputDecoration(
                  labelText: 'Niveau',
                  prefixIcon: Icon(Icons.school),
                ),
                items: List.generate(12, (i) => i + 1)
                    .map((n) => DropdownMenuItem(value: n, child: Text('Niveau $n')))
                    .toList(),
                onChanged: (value) => setState(() => _niveau = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createEleve,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }
}

// Dialog pour créer un enseignant
class _CreateEnseignantDialog extends StatefulWidget {
  @override
  State<_CreateEnseignantDialog> createState() => _CreateEnseignantDialogState();
}

class _CreateEnseignantDialogState extends State<_CreateEnseignantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _prenomNomController = TextEditingController();
  final _nomFamilleController = TextEditingController();
  final _courrielController = TextEditingController();
  final _telephoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomNomController.dispose();
    _nomFamilleController.dispose();
    _courrielController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _createEnseignant() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire enseignant échouée');
      return;
    }

    print('📝 Début de la création d\'un enseignant...');
    setState(() => _isLoading = true);
    
    try {
      // Essayons différents formats pour trouver celui qui fonctionne
      final data = {
        'prenom_nom': _prenomNomController.text.trim(),
        'nom_famille': _nomFamilleController.text.trim(),
        'courriel': _courrielController.text.trim(),
        'mode_paiement': 'Mensuel',  // Avec majuscule
        'salaire': '0',
      };
      
      // Ajouter le téléphone seulement s'il n'est pas vide
      if (_telephoneController.text.trim().isNotEmpty) {
        data['telephone'] = _telephoneController.text.trim();
      }
      
      print('📤 Envoi des données enseignant (format 1): $data');
      
      try {
        final result = await EnseignantService().createEnseignant(data, envoyerEmail: false);
        print('✅ Enseignant créé avec succès: $result');
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Enseignant créé avec succès!\nMot de passe par défaut: password'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
        return;
      } catch (e1) {
        print('⚠️ Format 1 échoué: $e1');
        print('   Essai format 2 avec différentes valeurs de mode_paiement...');
        
        // Essayer différentes valeurs possibles pour mode_paiement
        final modePaiementOptions = ['Mensuel', 'mensuel', 'MENSUEL', 'Horaire', 'horaire'];
        
        for (final modePaiement in modePaiementOptions) {
          try {
            final data2 = {
              'prenom': _prenomNomController.text.trim(),
              'nom_famille': _nomFamilleController.text.trim(),
              'courriel': _courrielController.text.trim(),
              'mode_paiement': modePaiement,
              'salaire': 0,
            };
            
            if (_telephoneController.text.trim().isNotEmpty) {
              data2['telephone'] = _telephoneController.text.trim();
            }
            
            print('📤 Essai avec mode_paiement="$modePaiement": $data2');
            
            final result = await EnseignantService().createEnseignant(data2, envoyerEmail: false);
            
            print('✅ Enseignant créé avec succès (mode_paiement="$modePaiement"): $result');

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Enseignant créé avec succès!\nMode de paiement: $modePaiement\nMot de passe: password'),
                  duration: const Duration(seconds: 5),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
            return; // Succès, on sort de la fonction
          } catch (e2) {
            print('   ❌ mode_paiement="$modePaiement" échoué: $e2');
            continue; // Essayer la prochaine valeur
          }
        }
        
        // Si aucune valeur n'a fonctionné, on lance l'erreur
        throw Exception('Impossible de créer l\'enseignant. Aucune valeur de mode_paiement acceptée.');
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR lors de la création de l\'enseignant:');
      print('   Message: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création:\n$e'),
            duration: const Duration(seconds: 7),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('🏁 Fin de la création d\'enseignant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un enseignant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _prenomNomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom et nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomFamilleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de famille',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courrielController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createEnseignant,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }
}

// Dialog pour créer un témoin
class _CreateTemoinDialog extends StatefulWidget {
  @override
  State<_CreateTemoinDialog> createState() => _CreateTemoinDialogState();
}

class _CreateTemoinDialogState extends State<_CreateTemoinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _prenomNomController = TextEditingController();
  final _nomFamilleController = TextEditingController();
  final _courrielController = TextEditingController();
  final _telephoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomNomController.dispose();
    _nomFamilleController.dispose();
    _courrielController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _createTemoin() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire témoin échouée');
      return;
    }

    print('📝 Début de la création d\'un témoin...');
    setState(() => _isLoading = true);
    
    try {
      final data = {
        'prenom': _prenomNomController.text,
        'nom': _nomFamilleController.text,
        'courriel': _courrielController.text,
        'telephone': _telephoneController.text,
      };
      
      print('📤 Envoi des données témoin: $data');
      
      final result = await TemoinService().createTemoin(data);
      
      print('✅ Témoin créé avec succès: $result');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Témoin créé avec succès!\nMot de passe par défaut: password'),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR lors de la création du témoin:');
      print('   Message: $e');
      print('   Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création:\n$e'),
            duration: const Duration(seconds: 7),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('🏁 Fin de la création de témoin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un témoin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _prenomNomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom et nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomFamilleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de famille',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courrielController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTemoin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }
}


class _HomeTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _HomeTab({
    required this.stats,
    required this.isLoading,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Détermine le nombre de colonnes en fonction de la largeur
    int calculateCrossAxisCount(double width) {
      if (width >= 900) return 4;
      if (width >= 600) return 3;
      return 2; // mobile
    }

    final mainStatsCrossAxis = calculateCrossAxisCount(screenWidth);
    final sessionStatsCrossAxis = calculateCrossAxisCount(screenWidth);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Titre
          Text(
            'Tableau de bord',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Statistiques principales
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildResponsiveStatCard(
                context,
                'Enseignants',
                '${stats['enseignants'] ?? 0}',
                Icons.person,
                Colors.blue,
                theme,
                mainStatsCrossAxis,
              ),
              _buildResponsiveStatCard(
                context,
                'Élèves',
                '${stats['eleves'] ?? 0}',
                Icons.school,
                Colors.green,
                theme,
                mainStatsCrossAxis,
              ),
              _buildResponsiveStatCard(
                context,
                'Témoins',
                '${stats['temoins'] ?? 0}',
                Icons.visibility,
                Colors.orange,
                theme,
                mainStatsCrossAxis,
              ),
              _buildResponsiveStatCard(
                context,
                'Séances totales',
                '${stats['seances'] ?? 0}',
                Icons.calendar_today,
                Colors.purple,
                theme,
                mainStatsCrossAxis,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Statistiques des séances
          Text(
            'État des séances',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildResponsiveStatCard(
                context,
                'En attente',
                '${stats['seances_en_attente'] ?? 0}',
                Icons.pending,
                Colors.orange,
                theme,
                sessionStatsCrossAxis,
              ),
              _buildResponsiveStatCard(
                context,
                'Confirmées',
                '${stats['seances_confirmees'] ?? 0}',
                Icons.thumb_up,
                Colors.blue,
                theme,
                sessionStatsCrossAxis,
              ),
              _buildResponsiveStatCard(
                context,
                'Validées',
                '${stats['seances_validees'] ?? 0}',
                Icons.check_circle,
                Colors.green,
                theme,
                sessionStatsCrossAxis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatCard(
    BuildContext context, // <- context ajouté
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    int columns,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0; // ListView padding
    final spacing = 12.0; // Wrap spacing
    final width = (screenWidth - padding * 2 - spacing * (columns - 1)) / columns;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}