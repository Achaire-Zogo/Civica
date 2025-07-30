class QuestionModel {
  final String id;
  final String levelId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // A, B, C, or D
  final String? explanation;
  final int points;
  final int orderIndex;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuestionModel({
    required this.id,
    required this.levelId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
    this.points = 10,
    this.orderIndex = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      levelId: json['level_id'] ?? '',
      questionText: json['question_text'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctAnswer: json['correct_answer'] ?? 'A',
      explanation: json['explanation'],
      points: json['points'] ?? 10,
      orderIndex: json['order_index'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'points': points,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to get options as a list
  List<String> get options => [optionA, optionB, optionC, optionD];

  // Helper method to get the correct option text
  String get correctOptionText {
    switch (correctAnswer.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return optionA;
    }
  }

  QuestionModel copyWith({
    String? id,
    String? levelId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
    int? points,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
