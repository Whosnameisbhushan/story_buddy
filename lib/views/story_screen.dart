import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/story_quiz_view_model.dart';
import 'widgets/buddy_widget.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/quiz_card.dart';
import 'widgets/story_card.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1F0FF), // Extremely soft pastel indigo
              Color(0xFFFFF9E6), // Extremely soft pastel yellow/cream
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content scrollable view
              Consumer<StoryQuizViewModel>(
                builder: (context, viewModel, child) {
                  final isQuizVisible = viewModel.quizStatus != QuizStatus.hidden;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Custom App Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PEBLO",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.purple[400],
                                    letterSpacing: 2,
                                  ),
                                ),
                                const Text(
                                  "Story Buddy",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.purple, size: 28),
                              tooltip: "Reset Story",
                              onPressed: () => viewModel.resetQuiz(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Center AI Buddy character
                        const BuddyWidget(),
                        const SizedBox(height: 24),

                        // Story display and narration trigger
                        const StoryCard(),
                        const SizedBox(height: 20),

                        // Animated reveal of the Quiz
                        AnimatedSize(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutBack,
                          child: AnimatedOpacity(
                            opacity: isQuizVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: isQuizVisible 
                                ? const QuizCard() 
                                : const SizedBox.shrink(),
                          ),
                        ),
                        
                        // Buffer space at bottom so contents aren't blocked by success dialog
                        const SizedBox(height: 120),
                      ],
                    ),
                  );
                },
              ),

              // Full screen confetti & success card overlay
              const CelebrationOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
