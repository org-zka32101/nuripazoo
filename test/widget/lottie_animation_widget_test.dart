import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuripazu/widgets/lottie_animation_widget.dart';

void main() {
  group('LottieAnimationWidget', () {
    testWidgets('Renders with specified dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimationWidget(
              assetPath: 'assets/lottie/reactions/playful_energetic_lv2.json',
              width: 250,
              height: 250,
              repeat: false,
              autoplay: true,
            ),
          ),
        ),
      );

      // SizedBox を検索（LottieAnimationWidget が SizedBox でラップされているため）
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Calls onComplete callback when animation finishes',
        (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimationWidget(
              assetPath: 'assets/lottie/reactions/playful_energetic_lv2.json',
              width: 200,
              height: 200,
              repeat: false,
              autoplay: true,
              duration: const Duration(milliseconds: 100),
              onComplete: () {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      // アニメーション完了時間を待つ
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // コールバックが呼ばれたことを確認
      expect(callbackCalled, isTrue);
    });

    testWidgets('Respects autoplay parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimationWidget(
              assetPath: 'assets/lottie/reactions/playful_energetic_lv2.json',
              autoplay: false,
            ),
          ),
        ),
      );

      // ウィジェットが構築されることを確認
      expect(find.byType(LottieAnimationWidget), findsOneWidget);
    });

    testWidgets('Respects repeat parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimationWidget(
              assetPath: 'assets/lottie/reactions/playful_energetic_lv2.json',
              repeat: true,
              autoplay: true,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimationWidget), findsOneWidget);
    });
  });

  group('AnimationSequence', () {
    testWidgets('Displays first animation in sequence',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimationSequence(
              animationPaths: [
                'assets/lottie/completion/celebration_confetti.json',
                'assets/lottie/completion/animal_appear.json',
              ],
              durations: const [
                Duration(seconds: 2),
                Duration(seconds: 1),
              ],
            ),
          ),
        ),
      );

      // LottieAnimationWidget が表示されていることを確認
      expect(find.byType(LottieAnimationWidget), findsOneWidget);
    });

    testWidgets('Calls onSequenceComplete when all animations finish',
        (WidgetTester tester) async {
      bool sequenceComplete = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimationSequence(
              animationPaths: [
                'assets/lottie/completion/celebration_confetti.json',
                'assets/lottie/completion/animal_appear.json',
              ],
              durations: const [
                Duration(milliseconds: 100),
                Duration(milliseconds: 100),
              ],
              onSequenceComplete: () {
                sequenceComplete = true;
              },
            ),
          ),
        ),
      );

      // 両方のアニメーション時間を待つ
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(sequenceComplete, isTrue);
    });

    testWidgets('Renders empty widget after sequence completes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimationSequence(
              animationPaths: [
                'assets/lottie/completion/celebration_confetti.json',
              ],
              durations: const [
                Duration(milliseconds: 50),
              ],
            ),
          ),
        ),
      );

      // アニメーション完了を待つ
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // SizedBox.shrink（空のウィジェット）が表示されることを確認
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
