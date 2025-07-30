import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/theme_model.dart';
import '../../models/level_model.dart';
import 'quiz_screen.dart';

class LevelsScreen extends StatefulWidget {
  final ThemeModel theme;

  const LevelsScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.loadThemeLevels(widget.theme.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(int.parse(widget.theme.color.replaceFirst('#', '0xFF'))),
              Color(int.parse(widget.theme.color.replaceFirst('#', '0xFF')))
                  .withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.theme.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.theme.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Choisissez un niveau',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Grille des niveaux
              Expanded(
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    if (themeProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (themeProvider.currentLevels.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.construction,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Niveaux en construction',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Revenez bientôt !',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: themeProvider.currentLevels.length,
                      itemBuilder: (context, index) {
                        final level = themeProvider.currentLevels[index];
                        return _LevelCard(
                          level: level,
                          onTap: () => _startLevel(level, themeProvider),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLevel(LevelModel level, ThemeProvider themeProvider) async {
    final BuildContext mainContext = context; // context du State principal
    debugPrint('[CIVIQUIZZ] _startLevel called, mounted: '
        '[32m[1m$mounted[0m, context: $mainContext');
    if (!level.isActive) {
      if (!mounted) {
        debugPrint(
            '[CIVIQUIZZ] Widget not mounted (level inactive), abort navigation.');
        return;
      }
      ScaffoldMessenger.of(mainContext).showSnackBar(
        SnackBar(
          content: Text(
            'Ce niveau n\'est pas encore débloqué.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // Check if user has lives
    final authProvider = Provider.of<AuthProvider>(mainContext, listen: false);
    if (authProvider.user?.vies == 0) {
      if (!mounted) {
        debugPrint(
            '[CIVIQUIZZ] Widget not mounted (no lives), abort navigation.');
        return;
      }
      ScaffoldMessenger.of(mainContext).showSnackBar(
        SnackBar(
          content: Text(
            'Vous n\'avez plus de vies ! Attendez qu\'elles se rechargent.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // Load questions for this level and navigate to quiz
    debugPrint('Starting to load questions for level: ${level.id}');
    try {
      await themeProvider.loadLevelQuestions(level.id);

      if (!mounted) {
        debugPrint(
            '[CIVIQUIZZ] Widget not mounted after loading questions, abort navigation.');
        return;
      }

      debugPrint('[CIVIQUIZZ] Questions loaded, count: '
          '\u001b[34m\u001b[1m${themeProvider.currentQuestions.length}\u001b[0m');

      if (themeProvider.currentQuestions.isNotEmpty) {
        debugPrint('[CIVIQUIZZ] Navigating to QuizScreen with '
            '${themeProvider.currentQuestions.length} questions, mounted: $mounted');

        Navigator.of(mainContext).push(
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              level: level,
              questions: themeProvider.currentQuestions,
            ),
          ),
        );
      } else {
        debugPrint(
            '[CIVIQUIZZ] No questions available, showing error message, mounted: $mounted');
        if (!mounted) return;
        ScaffoldMessenger.of(mainContext).showSnackBar(
          SnackBar(
            content: Text(
              'Aucune question disponible pour ce niveau.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } catch (e) {
      debugPrint('[CIVIQUIZZ] Error loading questions: $e, mounted: $mounted');
      if (!mounted) return;
      ScaffoldMessenger.of(mainContext).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des questions: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }
}

class _LevelCard extends StatelessWidget {
  final LevelModel level;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color:
                level.isActive ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!level.isActive)
                  const Icon(
                    Icons.lock,
                    size: 30,
                    color: Color(0xFF7F8C8D),
                  )
                else ...[
                  Icon(
                    _getDifficultyIcon(level.difficulty),
                    size: 32,
                    color: _getDifficultyColor(level.difficulty),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.difficulty.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getDifficultyColor(level.difficulty),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.quiz;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF27AE60);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'hard':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF3498DB);
    }
  }
}
