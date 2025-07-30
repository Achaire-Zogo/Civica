import 'question_model.dart';

class LevelModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String themeId;
  final int orderIndex;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<QuestionModel>? questions;

  LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.themeId,
    this.orderIndex = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.questions,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      themeId: json['theme_id'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      questions: json['questions'] != null 
          ? (json['questions'] as List).map((question) => QuestionModel.fromJson(question)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'theme_id': themeId,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'questions': questions?.map((question) => question.toJson()).toList(),
    };
  }

  LevelModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? themeId,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuestionModel>? questions,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      themeId: themeId ?? this.themeId,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
    );
  }
}
