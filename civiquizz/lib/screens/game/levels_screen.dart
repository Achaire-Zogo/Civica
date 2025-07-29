import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/game_provider.dart';
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
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.loadLevelsByTheme(widget.theme.id);
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
              Color(int.parse(widget.theme.couleur.replaceFirst('#', '0xFF'))),
              Color(int.parse(widget.theme.couleur.replaceFirst('#', '0xFF')))
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
                          widget.theme.icone,
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
                            widget.theme.nom,
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
                child: Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (gameProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (gameProvider.currentLevels.isEmpty) {
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: gameProvider.currentLevels.length,
                      itemBuilder: (context, index) {
                        final level = gameProvider.currentLevels[index];
                        return _LevelCard(
                          level: level,
                          isUnlocked: gameProvider.isLevelUnlocked(level),
                          stars: gameProvider.getLevelStars(level.id),
                          isCompleted: gameProvider.isLevelCompleted(level.id),
                          onTap: () => _startLevel(context, level, gameProvider),
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

  void _startLevel(BuildContext context, LevelModel level, GameProvider gameProvider) {
    if (!gameProvider.isLevelUnlocked(level)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complétez le niveau précédent pour débloquer celui-ci !',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF39C12),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.vies == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelModel level;
  final bool isUnlocked;
  final int stars;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LevelCard({
    Key? key,
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.isCompleted,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isUnlocked)
                const Icon(
                  Icons.lock,
                  size: 30,
                  color: Color(0xFF7F8C8D),
                )
              else ...[
                Text(
                  '${level.numero}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCompleted 
                        ? const Color(0xFF27AE60) 
                        : const Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(height: 4),
                if (isCompleted) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: index < stars 
                            ? const Color(0xFFF39C12) 
                            : const Color(0xFFBDC3C7),
                      );
                    }),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                ],
              ],
              const SizedBox(height: 4),
              Text(
                level.nom.isNotEmpty ? level.nom : 'Niveau ${level.numero}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isUnlocked 
                      ? const Color(0xFF2C3E50) 
                      : const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
