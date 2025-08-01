import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/level_model.dart';
import '../../models/question_model.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final LevelModel level;
  final Map<String, dynamic> quizResults;
  final List<Map<String, dynamic>> questionResults;
  final List<QuestionModel> questions;

  const QuizResultScreen({
    super.key,
    required this.level,
    required this.quizResults,
    required this.questionResults,
    required this.questions,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserStats();
    });
  }

  void _updateUserStats() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final percentage = widget.quizResults['percentage'] ?? 0;
    final score = widget.quizResults['score'] ?? 0;

    // Mettre à jour seulement en cas de succès (>= 50%)
    if (percentage >= 50) {
      // Ajouter les points
      authProvider.updateScore(score);

      // Augmenter le niveau de l'utilisateur si c'est un excellent score
      if (percentage >= 80) {
        final currentLevel = authProvider.user?.niveau ?? 1;
        authProvider.updateLevel(currentLevel + 1);
      }

      // Ajouter des badges selon les performances
      if (percentage == 100) {
        authProvider.addBadge('Parfait');
      }
      if (percentage >= 80) {
        authProvider.addBadge('Excellent');
      }
      if (percentage >= 70) {
        authProvider.addBadge('Très Bien');
      }
      if (widget.level.difficulty == 'easy' && percentage >= 70) {
        authProvider.addBadge('Premier Niveau');
      }

      debugPrint(
          '[CIVIQUIZZ] User stats updated: score +$score, percentage: $percentage%');
    } else {
      debugPrint(
          '[CIVIQUIZZ] No user stats update (percentage < 50%): $percentage%');
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.quizResults['score'] ?? 0;
    final correctAnswers = widget.quizResults['correctAnswers'] ?? 0;
    final totalQuestions = widget.quizResults['totalQuestions'] ?? 0;
    final percentage = widget.quizResults['percentage'] ?? 0;
    final grade = widget.quizResults['grade'] ?? 'F';

    return WillPopScope(
      onWillPop: () async {
        // Rediriger vers la page d'accueil
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        return false; // Empêcher le comportement par défaut
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: percentage >= 50
                  ? [
                      const Color(0xFF27AE60),
                      const Color(0xFF2ECC71),
                    ]
                  : [
                      const Color(0xFFE74C3C),
                      const Color(0xFFC0392B),
                    ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header avec icône de résultat
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: percentage >= 50
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (percentage >= 50
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFFE74C3C))
                              .withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      percentage >= 50
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre principal
                  Text(
                    percentage >= 50 ? 'Félicitations !' : 'Dommage !',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    percentage >= 50
                        ? 'Vous avez réussi le niveau ${widget.level.title} !'
                        : 'Continuez à vous entraîner !',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Carte de note principale
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Grade badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getGradeColor(grade),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            grade,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Score principal
                        Text(
                          '$percentage%',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          'de réussite',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grille de statistiques
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ResultStat(
                                icon: Icons.quiz_outlined,
                                label: 'Questions',
                                value: '$correctAnswers/$totalQuestions',
                                color: const Color(0xFF3498DB),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _ResultStat(
                                icon: Icons.star_outline,
                                label: 'Score',
                                value: '$score pts',
                                color: const Color(0xFFF39C12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home_outlined),
                              const SizedBox(width: 8),
                              Text(
                                'Retour à l\'accueil',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (percentage < 50) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              // Recommencer la partie avec les mêmes questions
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    level: widget.level,
                                    questions: widget.questions,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE74C3C),
                              side: const BorderSide(color: Color(0xFFE74C3C)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  'Réessayer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF27AE60);
      case 'B':
        return const Color(0xFF3498DB);
      case 'C':
        return const Color(0xFFF39C12);
      case 'D':
        return const Color(0xFFE67E22);
      case 'F':
      default:
        return const Color(0xFFE74C3C);
    }
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
