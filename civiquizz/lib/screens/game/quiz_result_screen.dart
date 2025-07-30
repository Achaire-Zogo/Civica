import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final LevelModel level;
  final Map<String, dynamic> quizResults;
  final List<Map<String, dynamic>> questionResults;

  const QuizResultScreen({
    Key? key,
    required this.level,
    required this.quizResults,
    required this.questionResults,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
      _updateUserStats();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  void _updateUserStats() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ajouter les points
    authProvider.updateScore(widget.quizResults['score'] ?? 0);

    // Ajouter des badges selon les performances
    final percentage = widget.quizResults['percentage'] ?? 0;

    if (percentage == 100) {
      authProvider.addBadge('Parfait');
    }
    if (percentage >= 80) {
      authProvider.addBadge('Excellent');
    }
    if (widget.level.difficulty == 'easy' && percentage >= 70) {
      authProvider.addBadge('Premier Niveau');
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.quizResults['score'] ?? 0;
    final correctAnswers = widget.quizResults['correctAnswers'] ?? 0;
    final totalQuestions = widget.quizResults['totalQuestions'] ?? 0;
    final percentage = widget.quizResults['percentage'] ?? 0;
    final grade = widget.quizResults['grade'] ?? 'F';

    return Scaffold(
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
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    40, // padding
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Animation de résultat
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _scaleController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          percentage >= 50 ? Icons.check : Icons.close,
                          size: 50,
                          color: percentage >= 50
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFE74C3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre du résultat
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      )),
                      child: Text(
                        percentage >= 50 ? 'Félicitations !' : 'Dommage !',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          percentage >= 50
                              ? 'Vous avez réussi le niveau ${widget.level.title} !'
                              : 'Continuez à vous entraîner !',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Carte des résultats
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.8),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      )),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Grade
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _getGradeColor(grade).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: _getGradeColor(grade)),
                              ),
                              child: Text(
                                'Note: $grade',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getGradeColor(grade),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Statistiques
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _ResultStat(
                                        icon: Icons.quiz,
                                        label: 'Questions',
                                        value:
                                            '$correctAnswers/$totalQuestions',
                                        color: const Color(0xFF3498DB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ResultStat(
                                        icon: Icons.percent,
                                        label: 'Précision',
                                        value: '$percentage%',
                                        color: const Color(0xFF9B59B6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ResultStat(
                                        icon: Icons.star,
                                        label: 'Score',
                                        value: '$score',
                                        color: const Color(0xFFF39C12),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _ResultStat(
                                        icon: Icons.emoji_events,
                                        label: 'Étoiles',
                                        value:
                                            '${widget.questionResults.where((q) => q['isCorrect'] == true).length}/3',
                                        color: const Color(0xFF27AE60),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Spacer flexible
                    const SizedBox(height: 16),

                    // Boutons d'action
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      )),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Continuer',
                              icon: Icons.arrow_forward,
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                          if (percentage < 50) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Réessayer',
                                icon: Icons.refresh,
                                backgroundColor: Colors.white,
                                textColor: const Color(0xFFE74C3C),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

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
