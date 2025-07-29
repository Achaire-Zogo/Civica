class ThemeModel {
  final String id;
  final String nom;
  final String description;
  final String icone;
  final String couleur;
  final List<String> sousThemes;
  final bool isUnlocked;

  ThemeModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.icone,
    required this.couleur,
    this.sousThemes = const [],
    this.isUnlocked = false,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      icone: json['icone'] ?? '',
      couleur: json['couleur'] ?? '#3498db',
      sousThemes: List<String>.from(json['sousThemes'] ?? []),
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'icone': icone,
      'couleur': couleur,
      'sousThemes': sousThemes,
      'isUnlocked': isUnlocked,
    };
  }
}
