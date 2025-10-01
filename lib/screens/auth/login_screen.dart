import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:edumanager/services/auth_service.dart';
import 'package:edumanager/screens/teacher/teacher_dashboard.dart';
import 'package:edumanager/screens/parent/parent_dashboard.dart';
import 'package:edumanager/screens/temoin/temoin_dashboard.dart';
import 'package:edumanager/screens/eleve/eleve_dashboard.dart';
import 'package:edumanager/widgets/error_display.dart';
import 'package:edumanager/screens/auth/registrer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'enseignant';
  bool _isLoading = false;

  final List<String> _roles = ['enseignant', 'eleve', 'temoin', 'parent'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              // Titre
              Text(
                'EduManager',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connexion à votre compte',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Champ email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Champ mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sélection du rôle
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role == 'enseignant' ? 'Enseignant' :
                      role == 'eleve' ? 'Élève' :
                      role == 'temoin' ? 'Témoin' : 'Parent'
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Bouton de connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Se connecter'),
                ),
              ),

                const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Vous N\'avez pas de compte ? Inscrivez-vous'),
                        ),
                        const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    developer.log(
      '🔐 Tentative de connexion',
      name: 'LoginScreen',
    );
    developer.log(
      'Email: ${_emailController.text}, Rôle: $_selectedRole',
      name: 'LoginScreen',
    );

    try {
      final authService = AuthService();
      
      // Appel au backend avec les 3 paramètres requis
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      developer.log(
        '✅ Connexion réussie',
        name: 'LoginScreen',
      );
      developer.log(
        'Token: ${result['token'] != null ? "✓ Reçu" : "✗ Absent"}',
        name: 'LoginScreen',
      );
      developer.log(
        'User: ${result['user']}',
        name: 'LoginScreen',
      );

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Bienvenue ${result['user']?['prenom_nom'] ?? result['user']?['prenom'] ?? ""}!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Rediriger vers le dashboard approprié selon le rôle
      Widget dashboard;
      switch (_selectedRole) {
        case 'enseignant':
          dashboard = const TeacherDashboard();
          break;
        case 'parent':
          dashboard = ParentDashboard(currentUser: result['user']);
          break;
        case 'eleve':
          dashboard = const EleveDashboard();
          break;
        case 'temoin':
          dashboard = const TemoinDashboard();
          break;
        default:
          dashboard = ParentDashboard(currentUser: result['user']);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => dashboard),
      );
    } catch (e) {
      developer.log(
        '❌ Erreur de connexion: $e',
        name: 'LoginScreen',
      );

      if (!mounted) return;

      // Afficher l'erreur avec le widget ErrorDisplay
      context.showError(
        e,
        onRetry: _login,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}