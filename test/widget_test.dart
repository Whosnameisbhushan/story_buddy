import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:story_buddy/main.dart';
import 'package:story_buddy/viewmodels/story_quiz_view_model.dart';

void main() {
  testWidgets('Story Buddy Initial State Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StoryQuizViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the title "Story Buddy" exists.
    expect(find.text('Story Buddy'), findsOneWidget);

    // Verify that "Read Me a Story" button exists.
    expect(find.text('Read Me a Story'), findsOneWidget);

    // Verify that the Quiz question is NOT visible initially
    expect(find.text("What colour was Pip the Robot's lost gear?"), findsNothing);
  });
}
