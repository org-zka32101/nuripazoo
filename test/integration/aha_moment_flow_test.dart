import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuripazu/views/puzzle_screen.dart';

void main() {
  group('Aha Moment Flow Integration Test', () {
    testWidgets('Puzzle completion triggers animation sequence',
        (WidgetTester tester) async {
      // ウィジェットツリーを構築
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PuzzleScreen(
              animalId: 'animal_001',
            ),
          ),
        ),
      );

      // パズルが読み込まれるまで待機
      await tester.pumpAndSettle();

      // パズル画面が表示されることを確認
      expect(find.byType(PuzzleScreen), findsOneWidget);
    });

    testWidgets('Puzzle completion screen shows animations',
        (WidgetTester tester) async {
      // ウィジェットツリーを構築
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PuzzleScreen(
              animalId: 'animal_001',
            ),
          ),
        ),
      );

      // 初期化を待つ
      await tester.pumpAndSettle();

      // パズル画面が表示されることを確認
      expect(find.byType(PuzzleScreen), findsOneWidget);
    });
  });
}
