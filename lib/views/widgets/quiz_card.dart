import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/story_quiz_view_model.dart';

class QuizCard extends StatefulWidget {
  const QuizCard({super.key});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  QuizStatus _lastStatus = QuizStatus.hidden;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryQuizViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.quizStatus == QuizStatus.hidden) {
          return const SizedBox.shrink();
        }

        // Trigger shake and haptic feedback on wrong answer
        if (viewModel.quizStatus == QuizStatus.wrongAnswer && _lastStatus != QuizStatus.wrongAnswer) {
          _shakeController.forward(from: 0.0);
          HapticFeedback.vibrate();
        }
        _lastStatus = viewModel.quizStatus;

        final quiz = viewModel.quiz;
        final selected = viewModel.selectedOption;
        final isCorrect = viewModel.quizStatus == QuizStatus.correctAnswer;

        return AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            // Horizontal shake math: sin wave sweeping 4 times
            final double shakeOffset = math.sin(_shakeController.value * 4 * math.pi) * 12.0;

            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: isCorrect ? Colors.green[50] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question indicator
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green[100] : Colors.amber[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect ? Icons.emoji_emotions : Icons.quiz,
                              color: isCorrect ? Colors.green : Colors.amber[800],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isCorrect ? "Yay! You Got It!" : "Pop Quiz Time!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green[800] : Colors.amber[800],
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Question Text
                      Text(
                        quiz.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Data-driven Options List
                      Column(
                        children: List.generate(quiz.options.length, (index) {
                          final option = quiz.options[index];
                          final isSelected = selected == option;
                          final isOptionCorrect = quiz.answer == option;

                          Color buttonColor = Colors.grey[100]!;
                          Color textColor = Colors.black87;
                          BorderSide borderSide = BorderSide(color: Colors.grey[300]!);

                          if (isSelected) {
                            if (viewModel.quizStatus == QuizStatus.correctAnswer) {
                              buttonColor = Colors.green;
                              textColor = Colors.white;
                              borderSide = BorderSide.none;
                            } else if (viewModel.quizStatus == QuizStatus.wrongAnswer) {
                              buttonColor = Colors.redAccent;
                              textColor = Colors.white;
                              borderSide = BorderSide.none;
                            }
                          } else if (isCorrect && isOptionCorrect) {
                            // Highlight correct answer if they succeeded
                            buttonColor = Colors.green[100]!;
                            textColor = Colors.green[900]!;
                            borderSide = BorderSide(color: Colors.green[300]!);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isCorrect
                                    ? null // Disable taps after correct answer
                                    : () => viewModel.selectOption(option),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  side: borderSide,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  elevation: isSelected ? 2 : 0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        String.fromCharCode(65 + index), // A, B, C, D...
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (isSelected && isCorrect)
                                      const Icon(Icons.check_circle, color: Colors.white),
                                    if (isSelected && viewModel.quizStatus == QuizStatus.wrongAnswer)
                                      const Icon(Icons.cancel, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
