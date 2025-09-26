class Rapport {
  final int id;
  final int parentId;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String contenu;

  Rapport({
    required this.id,
    required this.parentId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.contenu,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) => Rapport(
        id: json['id'],
        parentId: json['parent_id'],
        date: json['date'],
        heureDebut: json['heure_debut'],
        heureFin: json['heure_fin'],
        contenu: json['contenu'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'parent_id': parentId,
        'date': date,
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'contenu': contenu,
      };
}