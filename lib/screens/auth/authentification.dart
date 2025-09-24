import 'package:edumanager/models/user.dart';

class AuthenticationResult {
  final bool success;
  final String message;
  final User? user;

  AuthenticationResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthService {
  Future<AuthenticationResult> authenticateUser(String email, String password) async {
    // Simulation d'authentification - À remplacer par votre API
    await Future.delayed(const Duration(seconds: 2));

    // Vérification des identifiants de démonstration
    final demoAccounts = {
      'parent@edumanager.com': UserRole.parent,
      'teacher@edumanager.com': UserRole.teacher,
      'student@edumanager.com': UserRole.student,
      'witness@edumanager.com': UserRole.witness,
      'admin@edumanager.com': UserRole.admin,
    };

    if (demoAccounts.containsKey(email) && password == 'password123') {
      return AuthenticationResult(
        success: true,
        message: 'Connexion réussie',
        user: User(
          id: '1',
          email: email,
          role: demoAccounts[email]!,
          name: 'Utilisateur Demo',
        ),
      );
    }

    return AuthenticationResult(
      success: false,
      message: 'Email ou mot de passe incorrect',
    );
  }
}