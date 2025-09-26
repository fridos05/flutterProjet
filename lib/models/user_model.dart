enum UserRole {
  teacher('Enseignant'),
  student('Élève'),
  witness('Témoin'),
  parent('Parent');

  const UserRole(this.displayName);
  final String displayName;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
      case 'enseignant':
        return UserRole.teacher;
      case 'student':
      case 'eleve':
        return UserRole.student;
      case 'witness':
      case 'temoin':
        return UserRole.witness;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.parent;
    }
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? prenom;
  final String? nomFamille;
  final String? modePaiement;
  final double? salaire;
  final int? niveauId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.prenom,
    this.nomFamille,
    this.modePaiement,
    this.salaire,
    this.niveauId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // ---- FACTORIES SPÉCIFIQUES ----
  factory User.fromEnseignant(Map<String, dynamic> json) {
    final data = json['enseignant'] ?? json;
    return User(
      id: data['id'] ?? json['id_enseignant'],
      name: '${data['prenom'] ?? ''} ${data['nom_famille'] ?? ''}'.trim(),
      email: data['courriel'] ?? '',
      role: UserRole.teacher,
      prenom: data['prenom'],
      nomFamille: data['nom_famille'],
      modePaiement: data['mode_paiement'],
      salaire: data['salaire']?.toDouble(),
      status: data['status'] ?? 'actif',
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at']) : null,
    );
  }

  factory User.fromEleve(Map<String, dynamic> json) {
    final data = json['eleve'] ?? json;
    return User(
      id: data['id'] ?? json['id_eleve'],
      name: '${data['prenom'] ?? ''} ${data['nom_famille'] ?? ''}'.trim(),
      email: data['courriel'] ?? '',
      role: UserRole.student,
      prenom: data['prenom'],
      nomFamille: data['nom_famille'],
      niveauId: data['niveau_id'],
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at']) : null,
    );
  }

  factory User.fromTemoin(Map<String, dynamic> json) {
    final data = json['temoin'] ?? json;
    return User(
      id: data['id'] ?? json['id_temoin'],
      name: '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
      email: data['courriel'] ?? '',
      role: UserRole.witness,
      prenom: data['prenom'],
      nomFamille: data['nom'],
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at']) : null,
    );
  }

  factory User.fromParent(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['prenom_nom'] ?? '${json['prenom'] ?? ''} ${json['nom_famille'] ?? ''}'.trim(),
      email: json['courriel'] ?? '',
      role: UserRole.parent,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  // ---- FACTORY GÉNÉRIQUE ----
  factory User.fromJson(Map<String, dynamic> json, {String? roleHint}) {
    final role = roleHint != null ? UserRole.fromString(roleHint) : UserRole.fromString(json['role'] ?? '');

    switch (role) {
      case UserRole.teacher:
        return User.fromEnseignant(json);
      case UserRole.student:
        return User.fromEleve(json);
      case UserRole.witness:
        return User.fromTemoin(json);
      case UserRole.parent:
      default:
        return User.fromParent(json);
    }
  }

  // ---- SERIALIZATION ----
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'prenom': prenom,
      'nom_famille': nomFamille,
      'courriel': email,
      'mode_paiement': modePaiement,
      'salaire': salaire,
      'niveau_id': niveauId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    switch (role) {
      case UserRole.teacher:
        return {
          'prenom': prenom,
          'nom_famille': nomFamille,
          'courriel': email,
          if (modePaiement != null) 'mode_paiement': modePaiement,
          if (salaire != null) 'salaire': salaire,
          if (status != null) 'status': status,
        };
      case UserRole.student:
        return {
          'prenom': prenom,
          'nom_famille': nomFamille,
          'courriel': email,
          if (niveauId != null) 'niveau_id': niveauId,
        };
      case UserRole.witness:
        return {
          'prenom': prenom,
          'nom': nomFamille,
          'courriel': email,
        };
      case UserRole.parent:
        return {
          'prenom_nom': name.split(' ').first,
          'nom_famille': name.split(' ').length > 1 ? name.split(' ').last : '',
          'courriel': email,
        };
    }
  }
}
