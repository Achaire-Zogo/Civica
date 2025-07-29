import '../models/question_model.dart';
import '../models/theme_model.dart';
import '../models/level_model.dart';

class SampleData {
  // Questions d'exemple sur la Constitution française
  static List<QuestionModel> getSampleQuestions() {
    return [
      // Questions Constitution - Niveau 1
      QuestionModel(
        id: 'const_1_1',
        texte: 'En quelle année a été adoptée la Constitution de la Ve République française ?',
        options: ['1958', '1946', '1962', '1968'],
        reponse: '1958',
        niveau: 1,
        theme: 'Constitution',
        type: QuestionType.qcm,
        points: 10,
        explication: 'La Constitution de la Ve République a été adoptée le 4 octobre 1958.',
      ),
      QuestionModel(
        id: 'const_1_2',
        texte: 'Quelle est la durée du mandat présidentiel en France ?',
        options: ['4 ans', '5 ans', '6 ans', '7 ans'],
        reponse: '5 ans',
        niveau: 1,
        theme: 'Constitution',
        type: QuestionType.qcm,
        points: 10,
        explication: 'Depuis 2000, le mandat présidentiel est de 5 ans (quinquennat).',
      ),
      QuestionModel(
        id: 'const_1_3',
        texte: 'Le Président de la République française est-il élu au suffrage universel direct ?',
        options: ['Vrai', 'Faux'],
        reponse: 'Vrai',
        niveau: 1,
        theme: 'Constitution',
        type: QuestionType.vraiFaux,
        points: 10,
        explication: 'Depuis 1962, le Président est élu au suffrage universel direct.',
      ),
      QuestionModel(
        id: 'const_1_4',
        texte: 'Combien d\'articles compte la Constitution de 1958 ?',
        options: ['89', '92', '104', '114'],
        reponse: '104',
        niveau: 1,
        theme: 'Constitution',
        type: QuestionType.qcm,
        points: 10,
        explication: 'La Constitution de 1958 compte 104 articles.',
      ),
      QuestionModel(
        id: 'const_1_5',
        texte: 'Qui nomme le Premier ministre en France ?',
        options: ['Le Parlement', 'Le Président de la République', 'Le Conseil constitutionnel', 'Le peuple'],
        reponse: 'Le Président de la République',
        niveau: 1,
        theme: 'Constitution',
        type: QuestionType.qcm,
        points: 10,
        explication: 'Le Premier ministre est nommé par le Président de la République.',
      ),

      // Questions Constitution - Niveau 2
      QuestionModel(
        id: 'const_2_1',
        texte: 'Combien de membres compte le Conseil constitutionnel ?',
        options: ['7', '9', '11', '12'],
        reponse: '9',
        niveau: 2,
        theme: 'Constitution',
        type: QuestionType.qcm,
        points: 15,
        explication: 'Le Conseil constitutionnel compte 9 membres.',
      ),
      QuestionModel(
        id: 'const_2_2',
        texte: 'L\'Assemblée nationale peut-elle renverser le gouvernement ?',
        options: ['Vrai', 'Faux'],
        reponse: 'Vrai',
        niveau: 2,
        theme: 'Constitution',
        type: QuestionType.vraiFaux,
        points: 15,
        explication: 'L\'Assemblée nationale peut renverser le gouvernement par une motion de censure.',
      ),

      // Questions Élections - Niveau 1
      QuestionModel(
        id: 'elec_1_1',
        texte: 'À partir de quel âge peut-on voter en France ?',
        options: ['16 ans', '17 ans', '18 ans', '21 ans'],
        reponse: '18 ans',
        niveau: 1,
        theme: 'Code électoral',
        type: QuestionType.qcm,
        points: 10,
        explication: 'L\'âge de la majorité électorale est fixé à 18 ans en France.',
      ),
      QuestionModel(
        id: 'elec_1_2',
        texte: 'Combien de tours peut comporter une élection présidentielle ?',
        options: ['1', '2', '3', '4'],
        reponse: '2',
        niveau: 1,
        theme: 'Code électoral',
        type: QuestionType.qcm,
        points: 10,
        explication: 'L\'élection présidentielle peut comporter au maximum 2 tours.',
      ),
    ];
  }

  // Thèmes d'exemple
  static List<ThemeModel> getSampleThemes() {
    return [
      ThemeModel(
        id: 'constitution',
        nom: 'Constitution',
        description: 'Questions sur la Constitution française',
        icone: '📜',
        couleur: '#3498db',
        sousThemes: ['Droits fondamentaux', 'Institutions', 'Révision'],
        isUnlocked: true,
      ),
      ThemeModel(
        id: 'elections',
        nom: 'Code électoral',
        description: 'Questions sur les élections et le code électoral',
        icone: '🗳️',
        couleur: '#e74c3c',
        sousThemes: ['Élections présidentielles', 'Élections législatives', 'Élections locales'],
        isUnlocked: false,
      ),
      ThemeModel(
        id: 'institutions',
        nom: 'Institutions',
        description: 'Questions sur les institutions françaises',
        icone: '🏛️',
        couleur: '#f39c12',
        sousThemes: ['Exécutif', 'Législatif', 'Judiciaire'],
        isUnlocked: false,
      ),
    ];
  }

  // Niveaux d'exemple
  static List<LevelModel> getSampleLevels() {
    return [
      // Niveaux Constitution
      LevelModel(
        id: 'const_level_1',
        numero: 1,
        nom: 'Les Bases',
        themeId: 'constitution',
        questionIds: ['const_1_1', 'const_1_2', 'const_1_3', 'const_1_4', 'const_1_5'],
        scoreRequis: 0,
        isUnlocked: true,
        isCompleted: false,
        etoiles: 0,
        recompense: 'Badge Débutant',
      ),
      LevelModel(
        id: 'const_level_2',
        numero: 2,
        nom: 'Approfondissement',
        themeId: 'constitution',
        questionIds: ['const_2_1', 'const_2_2'],
        scoreRequis: 40,
        isUnlocked: false,
        isCompleted: false,
        etoiles: 0,
        recompense: 'Badge Expert Constitution',
      ),
      
      // Niveaux Code électoral
      LevelModel(
        id: 'elec_level_1',
        numero: 1,
        nom: 'Bases électorales',
        themeId: 'elections',
        questionIds: ['elec_1_1', 'elec_1_2'],
        scoreRequis: 0,
        isUnlocked: true,
        isCompleted: false,
        etoiles: 0,
        recompense: 'Badge Citoyen',
      ),
    ];
  }

  // Méthode pour initialiser les données d'exemple dans Firebase
  static Map<String, dynamic> getFirebaseData() {
    final questions = getSampleQuestions();
    final themes = getSampleThemes();
    final levels = getSampleLevels();

    Map<String, dynamic> questionsMap = {};
    for (var question in questions) {
      questionsMap[question.id] = question.toJson();
    }

    Map<String, dynamic> themesMap = {};
    for (var theme in themes) {
      themesMap[theme.id] = theme.toJson();
    }

    Map<String, dynamic> levelsMap = {};
    for (var level in levels) {
      levelsMap[level.id] = level.toJson();
    }

    return {
      'questions': questionsMap,
      'themes': themesMap,
      'levels': levelsMap,
    };
  }
}
