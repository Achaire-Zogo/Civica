import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final LevelModel level;
  final Map<String, dynamic> result;

  const QuizResultScreen({
    Key? key,
    required this.level,
    required this.result,
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
    if (widget.result['success'] == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Ajouter les points
      authProvider.updateScore(widget.result['score'] ?? 0);
      
      // Ajouter des badges selon les performances
      final percentage = widget.result['percentage'] ?? 0;
      final etoiles = widget.result['etoiles'] ?? 0;
      
      if (percentage == 100) {
        authProvider.addBadge('Parfait');
      }
      if (etoiles == 3) {
        authProvider.addBadge('Trois Étoiles');
      }
      if (widget.level.numero == 1) {
        authProvider.addBadge('Premier Niveau');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final success = widget.result['success'] == true;
    final etoiles = widget.result['etoiles'] ?? 0;
    final score = widget.result['score'] ?? 0;
    final correctAnswers = widget.result['correctAnswers'] ?? 0;
    final totalQuestions = widget.result['totalQuestions'] ?? 0;
    final percentage = widget.result['percentage'] ?? 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: success
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Animation de résultat
                ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
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
                      success ? Icons.check : Icons.close,
                      size: 60,
                      color: success 
                          ? const Color(0xFF27AE60) 
                          : const Color(0xFFE74C3C),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

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
                    success ? 'Félicitations !' : 'Dommage !',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: Text(
                    success
                        ? 'Vous avez réussi le niveau ${widget.level.numero} !'
                        : 'Continuez à vous entraîner !',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

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
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        // Étoiles
                        if (success) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: index < etoiles
                                      ? const Color(0xFFF39C12)
                                      : const Color(0xFFBDC3C7),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Statistiques
                        Row(
                          children: [
                            Expanded(
                              child: _ResultStat(
                                icon: Icons.quiz,
                                label: 'Questions',
                                value: '$correctAnswers/$totalQuestions',
                                color: const Color(0xFF3498DB),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                        const SizedBox(height: 16),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ResultStat(
                                icon: Icons.emoji_events,
                                label: 'Étoiles',
                                value: '$etoiles/3',
                                color: const Color(0xFF27AE60),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

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
                    children: [
                      CustomButton(
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
                      const SizedBox(height: 12),
                      if (!success)
                        CustomButton(
                          text: 'Réessayer',
                          icon: Icons.refresh,
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFFE74C3C),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }
}
