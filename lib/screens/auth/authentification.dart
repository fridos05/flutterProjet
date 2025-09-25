// lib/screens/auth/login_screen.dart
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

// Importe tous les dashboards (assure-toi qu’ils existent)
import 'package:edumanager/screens/admin/admin_dashboard.dart';
import 'package:edumanager/screens/parent/parent_dashboard.dart';
import 'package:edumanager/screens/teacher/teacher_dashboard.dart';
import 'package:edumanager/screens/student/student_dashboard.dart';
import 'package:edumanager/screens/witness/witness_dashboard.dart';

// Définis les rôles possibles
enum AppRole {
  admin,
  parent,
  teacher,
  student,
  witness;

  String get label {
    switch (this) {
      case AppRole.admin: return 'Administrateur';
      case AppRole.parent: return 'Parent';
      case AppRole.teacher: return 'Enseignant';
      case AppRole.student: return 'Élève';
      case AppRole.witness: return 'Témoin';
    }
  }

  Widget get dashboard {
    switch (this) {
      case AppRole.admin: return const AdminDashboard();
      case AppRole.parent: return const ParentDashboard();
      case AppRole.teacher: return const TeacherDashboard();
      case AppRole.student: return const StudentDashboard();
      case AppRole.witness: return const WitnessDashboard();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AppRole _selectedRole = AppRole.student; // Rôle par défaut

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // 🔐 ICI : tu feras l'appel à ton API Laravel plus tard
    // Pour l'instant, on simule une connexion réussie

    // ✅ Redirection vers le bon dashboard
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => _selectedRole.dashboard),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou titre
              const Text(
                'EduManager',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),

              // Sélecteur de rôle
              DropdownButtonFormField<AppRole>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez votre rôle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Champ email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Adresse e-mail',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Champ mot de passe
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Bouton de connexion
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}