import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/story_quiz_view_model.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryQuizViewModel>(
      builder: (context, viewModel, child) {
        final ttsStatus = viewModel.ttsStatus;
        final hasError = ttsStatus == TtsStatus.error;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: Colors.purple,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Pip's Big Story",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.storyText,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (ttsStatus == TtsStatus.playing) {
                            viewModel.stopReading();
                          } else {
                            viewModel.readStory();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(ttsStatus),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildButtonContent(ttsStatus),
                        ),
                      ),
                      if (hasError) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                                onPressed: () => viewModel.readStory(),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getButtonColor(TtsStatus status) {
    switch (status) {
      case TtsStatus.playing:
        return Colors.redAccent;
      case TtsStatus.loading:
        return Colors.indigoAccent;
      case TtsStatus.error:
        return Colors.amber[800]!;
      case TtsStatus.idle:
      default:
        return Colors.purple;
    }
  }

  List<Widget> _buildButtonContent(TtsStatus status) {
    switch (status) {
      case TtsStatus.playing:
        return [
          const Icon(Icons.stop, size: 24),
          const SizedBox(width: 8),
          const Text(
            "Stop Reading",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ];
      case TtsStatus.loading:
        return [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Preparing Story...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ];
      case TtsStatus.idle:
      case TtsStatus.error:
      default:
        return [
          const Icon(Icons.volume_up, size: 24),
          const SizedBox(width: 8),
          const Text(
            "Read Me a Story",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ];
    }
  }
}
