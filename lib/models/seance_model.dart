class Seance {
  final int id;
  final int idEnseignant;
  final int idEleve;
  final int idTemoin;
  final int idParent;
  final int? rapportId;
  final String jour;
  final String heure;
  final String matiere;
  final String statut;
  final bool valideeParParent;
  final bool valideeParTemoin;
  final Map<String, dynamic>? rapport;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Seance({
    required this.id,
    required this.idEnseignant,
    required this.idEleve,
    required this.idTemoin,
    required this.idParent,
    this.rapportId,
    required this.jour,
    required this.heure,
    required this.matiere,
    this.statut = 'en_attente_validation',
    this.valideeParParent = false,
    this.valideeParTemoin = false,
    this.rapport,
    this.createdAt,
    this.updatedAt,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id_seance'] ?? json['id'] ?? 0,
      idEnseignant: json['id_enseignant'] ?? 0,
      idEleve: json['id_eleve'] ?? 0,
      idTemoin: json['id_temoin'] ?? 0,
      idParent: json['id_parent'] ?? 0,
      rapportId: json['rapport_id'],
      jour: json['jour'] ?? '',
      heure: json['heure'] ?? '',
      matiere: json['matiere'] ?? '',
      statut: json['statut'] ?? 'en_attente_validation',
      valideeParParent: json['validee_par_parent'] == 1 || json['validee_par_parent'] == true,
      valideeParTemoin: json['validee_par_temoin'] == 1 || json['validee_par_temoin'] == true,
      rapport: json['rapport'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_enseignant': idEnseignant,
      'id_eleve': idEleve,
      'id_temoin': idTemoin,
      'id_parent': idParent,
      'jour': jour,
      'heure': heure,
      'matiere': matiere,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'seances': [
        {
          'jour': jour,
          'heure': heure,
          'matiere': matiere,
          'eleve_id': idEleve,
          'temoin_id': idTemoin,
          'parent_id': idParent,
        }
      ]
    };
  }

  // Getter pour le jour en français
  String get jourComplet {
    switch (jour.toLowerCase()) {
      case 'monday': return 'Lundi';
      case 'tuesday': return 'Mardi';
      case 'wednesday': return 'Mercredi';
      case 'thursday': return 'Jeudi';
      case 'friday': return 'Vendredi';
      case 'saturday': return 'Samedi';
      case 'sunday': return 'Dimanche';
      default: return jour;
    }
  }

  // Getter pour l'heure formatée
  String get heureFormatee {
    return heure;
  }
}