class LevelModel {
  final String id;
  final int numero;
  final String nom;
  final String themeId;
  final List<String> questionIds;
  final int scoreRequis;
  final bool isUnlocked;
  final bool isCompleted;
  final int etoiles; // 0-3 étoiles
  final String? recompense;

  LevelModel({
    required this.id,
    required this.numero,
    required this.nom,
    required this.themeId,
    required this.questionIds,
    this.scoreRequis = 0,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.etoiles = 0,
    this.recompense,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? '',
      numero: json['numero'] ?? 1,
      nom: json['nom'] ?? '',
      themeId: json['themeId'] ?? '',
      questionIds: List<String>.from(json['questionIds'] ?? []),
      scoreRequis: json['scoreRequis'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      etoiles: json['etoiles'] ?? 0,
      recompense: json['recompense'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'nom': nom,
      'themeId': themeId,
      'questionIds': questionIds,
      'scoreRequis': scoreRequis,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'etoiles': etoiles,
      'recompense': recompense,
    };
  }

  LevelModel copyWith({
    String? id,
    int? numero,
    String? nom,
    String? themeId,
    List<String>? questionIds,
    int? scoreRequis,
    bool? isUnlocked,
    bool? isCompleted,
    int? etoiles,
    String? recompense,
  }) {
    return LevelModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      nom: nom ?? this.nom,
      themeId: themeId ?? this.themeId,
      questionIds: questionIds ?? this.questionIds,
      scoreRequis: scoreRequis ?? this.scoreRequis,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      etoiles: etoiles ?? this.etoiles,
      recompense: recompense ?? this.recompense,
    );
  }
}
