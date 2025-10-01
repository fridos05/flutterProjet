import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog pour afficher le mot de passe généré après création d'un utilisateur
class PasswordDisplayDialog extends StatelessWidget {
  final String nomComplet;
  final String email;
  final String motDePasse;
  final String role;
  final bool emailEnvoye;
  final String? emailErreur;

  const PasswordDisplayDialog({
    Key? key,
    required this.nomComplet,
    required this.email,
    required this.motDePasse,
    required this.role,
    this.emailEnvoye = false,
    this.emailErreur,
  }) : super(key: key);

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'eleve':
        return 'Élève';
      case 'enseignant':
        return 'Enseignant';
      case 'temoin':
        return 'Témoin';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            emailEnvoye ? Icons.check_circle : Icons.warning,
            color: emailEnvoye ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          const Text('Compte créé'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message de statut email
            if (emailEnvoye)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le mot de passe a été envoyé par email à $email',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              )
            else if (emailErreur != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'L\'email n\'a pas pu être envoyé',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Veuillez transmettre le mot de passe manuellement',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Informations utilisateur
            _buildInfoRow('Nom', nomComplet),
            _buildInfoRow('Rôle', roleLabel),
            _buildInfoRow('Email', email),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Mot de passe
            const Text(
              'Mot de passe temporaire',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      motDePasse,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: motDePasse));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mot de passe copié !'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Avertissement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Important',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Notez ce mot de passe maintenant\n'
                    '• L\'utilisateur devra le changer à sa première connexion\n'
                    '• Ne partagez jamais ce mot de passe par des moyens non sécurisés',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Copier les informations complètes
            final info = 'Email: $email\nMot de passe: $motDePasse';
            Clipboard.setData(ClipboardData(text: info));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Informations copiées !'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Copier tout'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Méthode statique pour afficher facilement le dialog
  static Future<void> show(
    BuildContext context, {
    required String nomComplet,
    required String email,
    required String motDePasse,
    required String role,
    bool emailEnvoye = false,
    String? emailErreur,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit cliquer sur Fermer
      builder: (context) => PasswordDisplayDialog(
        nomComplet: nomComplet,
        email: email,
        motDePasse: motDePasse,
        role: role,
        emailEnvoye: emailEnvoye,
        emailErreur: emailErreur,
      ),
    );
  }
}
