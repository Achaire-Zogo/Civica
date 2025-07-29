enum QuestionType {
  qcm,
  vraiFaux,
  texteATrous,
}

class QuestionModel {
  final String id;
  final String texte;
  final List<String> options;
  final String reponse;
  final int niveau;
  final String theme;
  final QuestionType type;
  final int points;
  final String? explication;

  QuestionModel({
    required this.id,
    required this.texte,
    required this.options,
    required this.reponse,
    required this.niveau,
    required this.theme,
    required this.type,
    this.points = 10,
    this.explication,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      texte: json['texte'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      reponse: json['reponse'] ?? '',
      niveau: json['niveau'] ?? 1,
      theme: json['theme'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.qcm,
      ),
      points: json['points'] ?? 10,
      explication: json['explication'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texte': texte,
      'options': options,
      'reponse': reponse,
      'niveau': niveau,
      'theme': theme,
      'type': type.toString().split('.').last,
      'points': points,
      'explication': explication,
    };
  }
}
