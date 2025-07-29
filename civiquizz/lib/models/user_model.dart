class UserModel {
  final String uid;
  final String email;
  final String pseudo;
  final int score;
  final int niveau;
  final List<String> badges;
  final int vies;
  final DateTime? lastLifeRefresh;
  final Map<String, dynamic>? progression;

  UserModel({
    required this.uid,
    required this.email,
    required this.pseudo,
    this.score = 0,
    this.niveau = 1,
    this.badges = const [],
    this.vies = 3,
    this.lastLifeRefresh,
    this.progression,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      pseudo: json['pseudo'] ?? '',
      score: json['score'] ?? 0,
      niveau: json['niveau'] ?? 1,
      badges: List<String>.from(json['badges'] ?? []),
      vies: json['vies'] ?? 3,
      lastLifeRefresh: json['lastLifeRefresh'] != null 
          ? DateTime.parse(json['lastLifeRefresh']) 
          : null,
      progression: json['progression'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'pseudo': pseudo,
      'score': score,
      'niveau': niveau,
      'badges': badges,
      'vies': vies,
      'lastLifeRefresh': lastLifeRefresh?.toIso8601String(),
      'progression': progression,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? pseudo,
    int? score,
    int? niveau,
    List<String>? badges,
    int? vies,
    DateTime? lastLifeRefresh,
    Map<String, dynamic>? progression,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      pseudo: pseudo ?? this.pseudo,
      score: score ?? this.score,
      niveau: niveau ?? this.niveau,
      badges: badges ?? this.badges,
      vies: vies ?? this.vies,
      lastLifeRefresh: lastLifeRefresh ?? this.lastLifeRefresh,
      progression: progression ?? this.progression,
    );
  }
}
