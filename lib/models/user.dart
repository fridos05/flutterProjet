class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatar;
  final String? phone;
  final String? address;
  final String? city;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.address,
    this.city,
    this.isActive = true,
  });
}

enum UserRole {
  parent('Parent'),
  teacher('Enseignant'),
  student('Élève'),
  witness('Témoin'),
  admin('Administrateur');

  const UserRole(this.displayName);
  final String displayName;
}

class Student extends User {
  final int age;
  final String grade;
  final String school;
  final List<String> subjects;

  const Student({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.city,
    required this.age,
    required this.grade,
    required this.school,
    required this.subjects,
  }) : super(role: UserRole.student);
}

class Teacher extends User {
  final List<String> subjects;
  final double hourlyRate;
  final int experience;
  final String qualification;
  final List<String> teachingDays; // Jours d'enseignement
  final String? bankAccount; // Pour les paiements

  const Teacher({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.city,
    required this.subjects,
    required this.hourlyRate,
    required this.experience,
    required this.qualification,
    this.teachingDays = const [],
    this.bankAccount,
  }) : super(role: UserRole.teacher);
}

class Parent extends User {
  final List<String> childrenIds; // IDs des enfants (élèves)
  final String? witnessId; // ID du témoin associé si nécessaire
  final String? preferredPaymentMethod;

  const Parent({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.city,
    required this.childrenIds,
    this.witnessId,
    this.preferredPaymentMethod,
  }) : super(role: UserRole.parent);
}

class Witness extends User {
  final List<String> observedStudentIds; // IDs des élèves observés
  final String relationship; // Relation avec l'élève (grand-parent, oncle, etc.)
  final bool canReceiveReports; // Peut recevoir les rapports

  const Witness({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.city,
    required this.observedStudentIds,
    required this.relationship,
    this.canReceiveReports = true,
  }) : super(role: UserRole.witness);
}

class Admin extends User {
  final String department;
  final List<String> permissions;
  final DateTime? lastLogin;

  const Admin({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.city,
    required this.department,
    required this.permissions,
    this.lastLogin,
  }) : super(role: UserRole.admin);
}