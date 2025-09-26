import 'user_model.dart';

class Parent extends User {
  final int? nombreEnfants;

  Parent({
    required super.id,
    required super.name,
    required super.email,
    super.role = UserRole.parent,
    super.prenom,
    super.nomFamille,
    super.createdAt,
    super.updatedAt,
    this.nombreEnfants,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      name: '${json['prenom_nom'] ?? ''} ${json['nom_famille'] ?? ''}'.trim(),
      email: json['courriel'] ?? '',
      prenom: json['prenom_nom'],
      nomFamille: json['nom_famille'],
      nombreEnfants: json['nombre_enfants'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toApiJson() {
    return {
      'prenom_nom': prenom,
      'nom_famille': nomFamille,
      'courriel': email,
      if (nombreEnfants != null) 'nombre_enfants': nombreEnfants,
    };
  }
}
