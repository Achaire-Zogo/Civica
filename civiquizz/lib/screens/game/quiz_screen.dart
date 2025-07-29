import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import '../../providers/game_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/level_model.dart';
import '../../models/question_model.dart';
import '../../widgets/custom_button.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final LevelModel level;

  const QuizScreen({Key? key, required this.level}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _questionController;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLevel();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _startLevel() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check and refresh lives first
    await authProvider.checkAndRefreshLives();
    
    // Check if user has lives
    if (authProvider.user?.vies == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vous n\'avez plus de vies ! Attendez pour en récupérer.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }
    
    bool success = await gameProvider.startLevel(widget.level);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible de charger le niveau',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Utiliser une vie
    await authProvider.useLife();
    _progressController.forward();
    _questionController.forward();
  }

  void _selectAnswer(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _isCorrect = gameProvider.answerQuestion(answer);

    // Vibration pour le feedback
    if (_isCorrect) {
      Vibration.vibrate(duration: 100);
    } else {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }

    // Attendre un peu avant de passer à la suite
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    if (gameProvider.isLastQuestion) {
      _finishQuiz();
    } else {
      gameProvider.nextQuestion();
      setState(() {
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
      });
      _questionController.reset();
      _questionController.forward();
      _progressController.animateTo(gameProvider.progressPercentage);
    }
  }

  Future<void> _finishQuiz() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Use the user's uid from the auth provider
    final userId = authProvider.user?.uid ?? '';
    final result = await gameProvider.finishLevel(userId);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            level: widget.level,
            result: result,
          ),
        ),
      );
    }
  }

  void _quitQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quitter le quiz ?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Votre progression sera perdue et vous perdrez une vie.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continuer',
              style: GoogleFonts.poppins(color: const Color(0xFF3498DB)),
            ),
          ),
          TextButton(
            onPressed: () {
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              gameProvider.quitLevel();
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(); // Retourner à l'écran précédent
            },
            child: Text(
              'Quitter',
              style: GoogleFonts.poppins(color: const Color(0xFFE74C3C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _quitQuiz();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3498DB),
                Color(0xFF2980B9),
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                final question = gameProvider.currentQuestion;
                
                if (question == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Header avec progression
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: _quitQuiz,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressController.value * 
                                            gameProvider.progressPercentage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${authProvider.user?.vies ?? 0}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Question ${gameProvider.currentQuestionIndex + 1}/${gameProvider.totalQuestions}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Question
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _questionController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    50 * (1 - _questionController.value),
                                  ),
                                  child: Opacity(
                                    opacity: _questionController.value,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            question.texte,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2C3E50),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          ...question.options.map((option) {
                                            return _AnswerButton(
                                              text: option,
                                              isSelected: _selectedAnswer == option,
                                              isCorrect: _hasAnswered && option == question.reponse,
                                              isWrong: _hasAnswered && 
                                                  _selectedAnswer == option && 
                                                  option != question.reponse,
                                              onTap: () => _selectAnswer(option),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _AnswerButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE9ECEF);
    Color textColor = const Color(0xFF2C3E50);

    if (isCorrect) {
      backgroundColor = const Color(0xFF27AE60);
      borderColor = const Color(0xFF27AE60);
      textColor = Colors.white;
    } else if (isWrong) {
      backgroundColor = const Color(0xFFE74C3C);
      borderColor = const Color(0xFFE74C3C);
      textColor = Colors.white;
    } else if (isSelected) {
      borderColor = const Color(0xFF3498DB);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  )
                else if (isWrong)
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
