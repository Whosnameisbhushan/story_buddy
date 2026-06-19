import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz.dart';

enum TtsStatus { idle, loading, playing, error }
enum QuizStatus { hidden, visible, wrongAnswer, correctAnswer }

class StoryQuizViewModel extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  final String storyText = "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  final String _quizJson = '''
  {
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue"
  }
  ''';

  late Quiz quiz;
  TtsStatus _ttsStatus = TtsStatus.idle;
  QuizStatus _quizStatus = QuizStatus.hidden;
  String? _selectedOption;
  String _errorMessage = '';
  Map<String, String>? _selectedVoice;

  TtsStatus get ttsStatus => _ttsStatus;
  QuizStatus get quizStatus => _quizStatus;
  String? get selectedOption => _selectedOption;
  String get errorMessage => _errorMessage;
  Map<String, String>? get selectedVoice => _selectedVoice;

  StoryQuizViewModel() {
    _parseQuiz();
    _initTts();
  }

  void _parseQuiz() {
    try {
      final Map<String, dynamic> parsed = jsonDecode(_quizJson);
      quiz = Quiz.fromJson(parsed);
    } catch (e) {
      _errorMessage = "Failed to load quiz data.";
      _ttsStatus = TtsStatus.error;
    }
  }

  Future<void> _initTts() async {
    _flutterTts.setStartHandler(() {
      _ttsStatus = TtsStatus.playing;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _ttsStatus = TtsStatus.idle;
      _quizStatus = QuizStatus.visible;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsStatus = TtsStatus.error;
      _errorMessage = "TTS Error: $msg";
      notifyListeners();
    });

    await _setupFemaleVoice();
  }

  Future<void> _setupFemaleVoice() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.1);

      dynamic voices = await _flutterTts.getVoices;
      if (voices != null && voices is List) {
        List<Map<String, String>> enVoices = [];
        for (var voice in voices) {
          try {
            final name = voice['name']?.toString() ?? '';
            final locale = voice['locale']?.toString() ?? '';
            if (locale.startsWith('en')) {
              enVoices.add({
                'name': name,
                'locale': locale,
              });
            }
          } catch (_) {}
        }

        Map<String, String>? selectedVoice;
        for (var voice in enVoices) {
          final name = voice['name']!.toLowerCase();
          final locale = voice['locale']!.toLowerCase();
          
          if (name.contains('female') || 
              name.contains('zira') || 
              name.contains('samantha') || 
              name.contains('siri') ||
              name.contains('sfg') ||
              name.contains('ahp')) {
            selectedVoice = voice;
            break;
          }
        }

        selectedVoice ??= enVoices.firstWhere(
          (v) => v['locale']!.startsWith('en-IN'),
          orElse: () => enVoices.firstWhere(
            (v) => v['locale']!.startsWith('en-US'),
            orElse: () => enVoices.isNotEmpty ? enVoices.first : {'name': 'default', 'locale': 'en-US'},
          ),
        );

        if (selectedVoice['name'] != 'default') {
          await _flutterTts.setVoice({
            'name': selectedVoice['name']!,
            'locale': selectedVoice['locale']!,
          });
          _selectedVoice = selectedVoice;
        }
      }
    } catch (e) {
      debugPrint("Voice configuration warning: $e");
    }
  }

  Future<void> readStory() async {
    if (_ttsStatus == TtsStatus.playing) return;

    _ttsStatus = TtsStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.15);

      var result = await _flutterTts.speak(storyText);
      if (result == 0) {
        throw Exception("Could not start speech engine");
      }
    } catch (e) {
      _ttsStatus = TtsStatus.error;
      _errorMessage = "Oops! I couldn't read the story. Please check your speaker and try again.";
      notifyListeners();
    }
  }

  Future<void> stopReading() async {
    await _flutterTts.stop();
    _ttsStatus = TtsStatus.idle;
    notifyListeners();
  }

  void selectOption(String option) {
    if (_quizStatus == QuizStatus.correctAnswer) return;

    _selectedOption = option;
    if (option == quiz.answer) {
      _quizStatus = QuizStatus.correctAnswer;
    } else {
      _quizStatus = QuizStatus.wrongAnswer;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_quizStatus == QuizStatus.wrongAnswer) {
          _quizStatus = QuizStatus.visible;
          _selectedOption = null;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void resetQuiz() {
    stopReading();
    _quizStatus = QuizStatus.hidden;
    _selectedOption = null;
    _ttsStatus = TtsStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
