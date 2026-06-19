import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/story_quiz_view_model.dart';

class BuddyWidget extends StatefulWidget {
  const BuddyWidget({super.key});

  @override
  State<BuddyWidget> createState() => _BuddyWidgetState();
}

class _BuddyWidgetState extends State<BuddyWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  QuizStatus _lastStatus = QuizStatus.hidden;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -40.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -40.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 70),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryQuizViewModel>(
      builder: (context, viewModel, child) {
        final ttsPlaying = viewModel.ttsStatus == TtsStatus.playing;
        final quizCorrect = viewModel.quizStatus == QuizStatus.correctAnswer;

        if (viewModel.quizStatus == QuizStatus.correctAnswer && _lastStatus != QuizStatus.correctAnswer) {
          _bounceController.forward(from: 0.0);
        }
        _lastStatus = viewModel.quizStatus;

        if (ttsPlaying) {
          _floatController.duration = const Duration(seconds: 1);
          if (!_floatController.isAnimating) {
            _floatController.repeat(reverse: true);
          }
        } else {
          _floatController.duration = const Duration(seconds: 3);
          if (!_floatController.isAnimating) {
            _floatController.repeat(reverse: true);
          }
        }

        final imagePath = quizCorrect
            ? 'assets/images/buddy_happy.png'
            : 'assets/images/buddy_neutral.png';

        return AnimatedBuilder(
          animation: Listenable.merge([_floatController, _bounceController]),
          builder: (context, child) {
            final floatOffset = _floatAnimation.value;
            final bounceOffset = _bounceAnimation.value;

            double scale = 1.0;
            if (ttsPlaying) {
              scale = 1.0 + (math.sin(_floatController.value * 2 * math.pi) * 0.04);
            }

            double angle = 0.0;
            if (quizCorrect && _bounceController.isAnimating) {
              angle = math.sin(_bounceController.value * 3 * math.pi) * 0.15;
            }

            return Transform.translate(
              offset: Offset(0, floatOffset + bounceOffset),
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (quizCorrect
                                  ? Colors.amber.withOpacity(0.3)
                                  : Colors.purple.withOpacity(0.15)),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: quizCorrect ? Colors.amber[100] : Colors.blue[100],
                            alignment: Alignment.center,
                            child: Text(
                              quizCorrect ? '🤖🎉' : '🤖🎙️',
                              style: const TextStyle(fontSize: 60),
                            ),
                          );
                        },
                      ),
                    ),
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
