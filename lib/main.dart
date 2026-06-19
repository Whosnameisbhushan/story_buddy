import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/story_quiz_view_model.dart';
import 'views/story_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryQuizViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFFFB74D),
          background: const Color(0xFFFCF9F2),
        ),
        fontFamily: 'Outfit',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
          bodyLarge: TextStyle(color: Colors.black87),
        ),
      ),
      home: const StoryScreen(),
    );
  }
}
