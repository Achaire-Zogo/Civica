import 'level_model.dart';

class ThemeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<LevelModel>? levels;

  ThemeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.levels,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#3498DB',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      levels: json['levels'] != null 
          ? (json['levels'] as List).map((level) => LevelModel.fromJson(level)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'levels': levels?.map((level) => level.toJson()).toList(),
    };
  }

  ThemeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LevelModel>? levels,
  }) {
    return ThemeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      levels: levels ?? this.levels,
    );
  }
}
