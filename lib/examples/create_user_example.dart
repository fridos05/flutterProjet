import 'package:flutter/material.dart';
import '../services/eleve_service.dart';
import '../services/enseignant_service.dart';
import '../services/temoin_service.dart';
import '../widgets/password_display_dialog.dart';

/// Exemples d'utilisation pour créer des utilisateurs avec envoi d'email
class CreateUserExample extends StatefulWidget {
  const CreateUserExample({Key? key}) : super(key: key);

  @override
  State<CreateUserExample> createState() => _CreateUserExampleState();
}

class _CreateUserExampleState extends State<CreateUserExample> {
  final _eleveService = EleveService();
  final _enseignantService = EnseignantService();
  final _temoinService = TemoinService();

  bool _isLoading = false;

  /// Exemple 1 : Créer un élève avec envoi d'email automatique
  Future<void> _creerEleveAvecEmail() async {
    setState(() => _isLoading = true);

    try {
      final result = await _eleveService.createEleve({
        'nom_famille': 'Martin',
        'prenom': 'Marie',
        'courriel': 'marie.martin@example.com',
        'niveau_id': 1,
      }, envoyerEmail: true); // Envoi automatique activé

      if (!mounted) return;

      // Vérifier si l'email a été envoyé
      if (result['email_envoye'] == true) {
        // Email envoyé avec succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Élève créé et email envoyé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Optionnel : Afficher quand même le mot de passe
        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['eleve']['prenom']} ${result['eleve']['nom_famille']}',
          email: result['eleve']['courriel'],
          motDePasse: result['password'],
          role: 'eleve',
          emailEnvoye: true,
        );
      } else {
        // Email non envoyé, afficher le dialog avec erreur
        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['eleve']['prenom']} ${result['eleve']['nom_famille']}',
          email: result['eleve']['courriel'],
          motDePasse: result['password'],
          role: 'eleve',
          emailEnvoye: false,
          emailErreur: result['email_erreur'],
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Exemple 2 : Créer un élève SANS envoi d'email
  Future<void> _creerEleveSansEmail() async {
    setState(() => _isLoading = true);

    try {
      final result = await _eleveService.createEleve({
        'nom_famille': 'Durand',
        'prenom': 'Paul',
        'courriel': 'paul.durand@example.com',
        'niveau_id': 2,
      }, envoyerEmail: false); // Envoi désactivé

      if (!mounted) return;

      // Afficher obligatoirement le dialog car pas d'email envoyé
      await PasswordDisplayDialog.show(
        context,
        nomComplet: '${result['eleve']['prenom']} ${result['eleve']['nom_famille']}',
        email: result['eleve']['courriel'],
        motDePasse: result['password'],
        role: 'eleve',
        emailEnvoye: false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Exemple 3 : Créer un enseignant avec envoi d'email
  Future<void> _creerEnseignantAvecEmail() async {
    setState(() => _isLoading = true);

    try {
      final result = await _enseignantService.createEnseignant({
        'prenom': 'Jean',
        'nom_famille': 'Dupont',
        'courriel': 'jean.dupont@example.com',
        'mode_paiement': 'virement',
        'salaire': 2500,
      }, envoyerEmail: true);

      if (!mounted) return;

      if (result['email_envoye'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Enseignant créé et email envoyé !'),
            backgroundColor: Colors.green,
          ),
        );

        // Afficher le dialog avec le mot de passe par défaut
        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['enseignant']['prenom']} ${result['enseignant']['nom_famille']}',
          email: result['enseignant']['courriel'],
          motDePasse: result['mot_de_passe_defaut'], // 'password'
          role: 'enseignant',
          emailEnvoye: true,
        );
      } else {
        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['enseignant']['prenom']} ${result['enseignant']['nom_famille']}',
          email: result['enseignant']['courriel'],
          motDePasse: result['mot_de_passe_defaut'],
          role: 'enseignant',
          emailEnvoye: false,
          emailErreur: result['email_erreur'],
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Exemple 4 : Créer un témoin avec envoi d'email
  Future<void> _creerTemoinAvecEmail() async {
    setState(() => _isLoading = true);

    try {
      final result = await _temoinService.createTemoin({
        'nom': 'Lefebvre',
        'prenom': 'Sophie',
        'courriel': 'sophie.lefebvre@example.com',
      }, envoyerEmail: true);

      if (!mounted) return;

      if (result['email_envoye'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Témoin créé et email envoyé !'),
            backgroundColor: Colors.green,
          ),
        );

        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['temoin']['prenom']} ${result['temoin']['nom']}',
          email: result['temoin']['courriel'],
          motDePasse: result['mot_de_passe_defaut'],
          role: 'temoin',
          emailEnvoye: true,
        );
      } else {
        await PasswordDisplayDialog.show(
          context,
          nomComplet: '${result['temoin']['prenom']} ${result['temoin']['nom']}',
          email: result['temoin']['courriel'],
          motDePasse: result['mot_de_passe_defaut'],
          role: 'temoin',
          emailEnvoye: false,
          emailErreur: result['email_erreur'],
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemples de création d\'utilisateurs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Exemples d\'utilisation',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cliquez sur un bouton pour tester la création d\'utilisateur avec envoi d\'email',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Exemple 1
                _buildExampleCard(
                  title: 'Créer un élève avec email',
                  description:
                      'Crée un élève et envoie automatiquement le mot de passe par email',
                  icon: Icons.school,
                  color: Colors.blue,
                  onPressed: _creerEleveAvecEmail,
                ),

                // Exemple 2
                _buildExampleCard(
                  title: 'Créer un élève sans email',
                  description:
                      'Crée un élève sans envoyer d\'email (affiche le mot de passe dans un dialog)',
                  icon: Icons.school_outlined,
                  color: Colors.orange,
                  onPressed: _creerEleveSansEmail,
                ),

                // Exemple 3
                _buildExampleCard(
                  title: 'Créer un enseignant avec email',
                  description:
                      'Crée un enseignant et envoie le mot de passe par défaut ("password")',
                  icon: Icons.person,
                  color: Colors.green,
                  onPressed: _creerEnseignantAvecEmail,
                ),

                // Exemple 4
                _buildExampleCard(
                  title: 'Créer un témoin avec email',
                  description:
                      'Crée un témoin et envoie le mot de passe par défaut',
                  icon: Icons.visibility,
                  color: Colors.purple,
                  onPressed: _creerTemoinAvecEmail,
                ),
              ],
            ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
