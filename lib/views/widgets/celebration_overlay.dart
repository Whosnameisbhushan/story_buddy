import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/story_quiz_view_model.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _confettiController;
  QuizStatus _lastStatus = QuizStatus.hidden;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryQuizViewModel>(
      builder: (context, viewModel, child) {
        final isCorrect = viewModel.quizStatus == QuizStatus.correctAnswer;

        // Trigger confetti when transition to correctAnswer happens
        if (isCorrect && _lastStatus != QuizStatus.correctAnswer) {
          _confettiController.play();
        } else if (!isCorrect && _lastStatus == QuizStatus.correctAnswer) {
          _confettiController.stop();
        }
        _lastStatus = viewModel.quizStatus;

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Center Top Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                ],
                numberOfParticles: 35,
                gravity: 0.15,
              ),
            ),

            // Success dialog box overlay
            if (isCorrect)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.amber[300]!, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber[900]!.withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "🎉 Master Story Solver! 🎉",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.purple,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "You helped Pip find his shiny blue gear! You are amazing!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => viewModel.resetQuiz(),
                              icon: const Icon(Icons.replay),
                              label: const Text(
                                "Play Again",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
