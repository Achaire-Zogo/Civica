import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/level_model.dart';
import '../../models/question_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final LevelModel level;
  final List<QuestionModel> questions;

  const QuizScreen({
    Key? key,
    required this.level,
    required this.questions,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  void _initializeQuiz() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.initializeQuiz(widget.level, widget.questions);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      quizProvider.decrementTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog();
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
            child: Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (quizProvider.isQuizCompleted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _navigateToResults();
                  });
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                final currentQuestion = quizProvider.currentQuestion;
                if (currentQuestion == null) {
                  return const Center(
                    child: Text(
                      'Aucune question disponible',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Header avec progress et timer
                    _buildHeader(quizProvider),
                    
                    // Question
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Question card
                            _buildQuestionCard(currentQuestion),
                            
                            const SizedBox(height: 24),
                            
                            // Options
                            Expanded(
                              child: _buildOptionsGrid(currentQuestion, quizProvider),
                            ),
                            
                            // Navigation buttons
                            _buildNavigationButtons(quizProvider),
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

  Widget _buildHeader(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row with back button and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  if (await _showExitDialog()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: quizProvider.timeRemaining <= 10 
                      ? Colors.red 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quizProvider.timeRemaining}s',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.level.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: quizProvider.progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${question.points} pts',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3498DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(QuestionModel question, QuizProvider quizProvider) {
    final options = [
      {'letter': 'A', 'text': question.optionA},
      {'letter': 'B', 'text': question.optionB},
      {'letter': 'C', 'text': question.optionC},
      {'letter': 'D', 'text': question.optionD},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        childAspectRatio: 4,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = _selectedAnswer == option['letter'];
        
        return _buildOptionCard(
          option['letter']!,
          option['text']!,
          isSelected,
          () {
            setState(() {
              _selectedAnswer = option['letter'];
            });
            quizProvider.answerQuestion(option['letter']!);
          },
        );
      },
    );
  }

  Widget _buildOptionCard(String letter, String text, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF3498DB).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF3498DB)
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF3498DB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF2C3E50),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(QuizProvider quizProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (quizProvider.currentQuestionIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedAnswer = quizProvider.currentQuestionAnswer;
                  });
                  quizProvider.previousQuestion();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Précédent',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          
          if (quizProvider.currentQuestionIndex > 0)
            const SizedBox(width: 16),
          
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedAnswer != null
                  ? () {
                      setState(() {
                        _selectedAnswer = null;
                      });
                      quizProvider.nextQuestion();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                quizProvider.currentQuestionIndex == quizProvider.totalQuestions - 1
                    ? 'Terminer'
                    : 'Suivant',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quitter le quiz ?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Votre progression sera perdue si vous quittez maintenant.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Continuer',
              style: GoogleFonts.poppins(color: const Color(0xFF3498DB)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Quitter',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _navigateToResults() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Submit quiz results
    quizProvider.submitQuiz(authProvider);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          level: widget.level,
          quizResults: quizProvider.getQuizResults(),
          questionResults: quizProvider.getQuestionResults(),
        ),
      ),
    );
  }
}
