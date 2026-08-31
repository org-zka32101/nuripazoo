import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';

/// ジェムパズル画面
/// 【Aha Moment最短動線】
/// パズル完成 → 完成演出 → 動物アクション → なつき度Lv1登録
class PuzzleScreen extends ConsumerWidget {
  final String? animalId;

  const PuzzleScreen({
    Key? key,
    this.animalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleSessionProvider);
    final isCompleted = ref.watch(isPuzzleCompletedProvider);
    final progress = ref.watch(puzzleProgressProvider);
    final mistakeCount = ref.watch(mistakeCountProvider);

    // 初回起動時にパズルを開始
    if (puzzleState == null) {
      // TODO: animalIdがない場合、最初のパズルを生成
      // 固定簡単配色（必ず成功する）
      final expectedTiles = [1, 2, 3, 4, 5, 6, 7, 8]; // placeholder
      Future.microtask(() {
        ref
            .read(puzzleSessionProvider.notifier)
            .startPuzzle(animalId ?? 'animal_001', expectedTiles);
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('パズルを完成させよう'),
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
        foregroundColor: Colors.orange,
      ),
      body: isCompleted
          ? _buildCompletionScreen(context, ref, puzzleState)
          : _buildPuzzleGameScreen(context, ref, puzzleState, progress, mistakeCount),
    );
  }

  // パズルゲーム画面
  Widget _buildPuzzleGameScreen(
    BuildContext context,
    WidgetRef ref,
    PuzzleSessionState puzzleState,
    double progress,
    int mistakeCount,
  ) {
    return Column(
      children: [
        // 進捗バー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('進捗'),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    progress > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ゲームボード（簡略版）
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // パズルタイル表示（グリッド）
                Container(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: puzzleState.expectedTiles.length,
                    itemBuilder: (context, index) {
                      final isCorrect =
                          puzzleState.playerTiles[index] ==
                          puzzleState.expectedTiles[index];
                      final isEmpty = puzzleState.playerTiles[index] == 0;

                      return GestureDetector(
                        onTap: () {
                          // タイル選択ロジック（簡略版）
                          ref
                              .read(puzzleSessionProvider.notifier)
                              .setTile(index, (index + 1) % 9);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.shade100
                                : isEmpty
                                    ? Colors.grey.shade100
                                    : Colors.orange.shade50,
                            border: Border.all(
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.orange.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              puzzleState.playerTiles[index].toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ミス数表示
                Text(
                  'ミス: $mistakeCount',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 説明テキスト
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '宝石を正しい色に仕分けてください',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // 完成画面（Aha Moment）
  Widget _buildCompletionScreen(
    BuildContext context,
    WidgetRef ref,
    PuzzleSessionState puzzleState,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 完成演出（Lottie予定）
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.celebration,
                size: 80,
                color: Colors.orange,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 完成メッセージ
          const Text(
            'パズルが完成しました!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          const SizedBox(height: 16),

          // 動物が現れる演出（簡略版）
          const Text(
            '新しい動物があらわれた!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 48),

          // 次へボタン
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // なつき度 Lv1 で動物を登録（Cloud Functions）
              try {
                await ref
                    .read(
                      registerNewAnimalProvider(puzzleState.animalId).future,
                    )
                    .then((_) async {
                  // 動物数を確認してペイウォール判定
                  final animalCount = await ref
                      .read(userAnimalCountProvider.future);

                  if (context.mounted) {
                    // 2体目完成時にペイウォール表示
                    if (animalCount == 2) {
                      Navigator.of(context).pushNamed(
                        '/paywall',
                        arguments: {
                          'animalId': puzzleState.animalId,
                          'onDismiss': () {
                            Navigator.of(context)
                                .pushReplacementNamed('/home');
                          },
                        },
                      );
                    } else {
                      // 1体目またはそれ以降は通常フロー
                      Navigator.of(context)
                          .pushReplacementNamed('/home');
                    }
                  }
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('エラー: $e')),
                );
              }
            },
            child: const Text(
              '動物園へ戻る',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
