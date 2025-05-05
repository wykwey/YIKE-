// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:yiclass/main.dart';
import 'package:yiclass/states/schedule_state.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScheduleState()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify app title is shown
    expect(find.text('课程表'), findsOneWidget);
    
    // Verify week view navigation buttons exist
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}

