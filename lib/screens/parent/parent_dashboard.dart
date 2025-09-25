// lib/screens/auth/login_screen.dart
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/screens/admin/admin_dashboard.dart';
import 'package:edumanager/screens/teacher/teacher_dashboard.dart';
import 'package:edumanager/screens/student/student_dashboard.dart';
import 'package:edumanager/screens/witness/witness_dashboard.dart';

enum UserRole {
  admin,
  parent,
  teacher,
  student,
  witness;

  String get label {
    switch (this) {
      case UserRole.admin: return 'Administrateur';
      case UserRole.parent: return 'Parent';
      case UserRole.teacher: return 'Enseignant';
      case UserRole.student: return 'Élève';
      case UserRole.witness: return 'Témoin';
    }
  }

  Widget get dashboard {
    switch (this) {
      case UserRole.admin: return const AdminDashboard();
      case UserRole.parent: return const ParentDashboard();
      case UserRole.teacher: return const TeacherDashboard();
      case UserRole.student: return const StudentDashboard();
      case UserRole.witness: return const WitnessDashboard();
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
  UserRole _selectedRole = UserRole.student; // rôle par défaut

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // 🔐 Ici, tu feras l'appel à ton API plus tard
    // Pour l'instant, on simule une connexion réussie

    // ✅ Redirection vers le dashboard correspondant
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
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Sélection du rôle
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values.map((role) {
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
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Champ mot de passe
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Bouton de connexion
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}