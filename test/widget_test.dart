import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:story_buddy/main.dart';
import 'package:story_buddy/viewmodels/story_quiz_view_model.dart';

void main() {
  testWidgets('Story Buddy Initial State Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StoryQuizViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Story Buddy'), findsOneWidget);
    expect(find.text('Read Me a Story'), findsOneWidget);
    expect(find.text("What colour was Pip the Robot's lost gear?"), findsNothing);
  });
}
