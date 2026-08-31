import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/services/puzzle_engine_service.dart';
import 'package:nuripazu/models/index.dart';
import 'user_provider.dart';

/// パズルセッション状態
class PuzzleSessionState {
  final String sessionId;
  final String animalId;
  final DateTime startedAt;
  final List<int> playerTiles;
  final List<int> expectedTiles;
  final int mistakeCount;

  PuzzleSessionState({
    required this.sessionId,
    required this.animalId,
    required this.startedAt,
    required this.playerTiles,
    required this.expectedTiles,
    required this.mistakeCount,
  });

  bool get isCompleted => PuzzleEngineService.validateCompletion(
        playerTiles,
        expectedTiles,
      );

  PuzzleSessionState copyWith({
    List<int>? playerTiles,
    int? mistakeCount,
  }) {
    return PuzzleSessionState(
      sessionId: sessionId,
      animalId: animalId,
      startedAt: startedAt,
      playerTiles: playerTiles ?? this.playerTiles,
      expectedTiles: expectedTiles,
      mistakeCount: mistakeCount ?? this.mistakeCount,
    );
  }
}

/// パズルセッション（StateNotifierProvider）
final puzzleSessionProvider =
    StateNotifierProvider<PuzzleSessionNotifier, PuzzleSessionState?>((ref) {
  return PuzzleSessionNotifier(ref);
});

class PuzzleSessionNotifier extends StateNotifier<PuzzleSessionState?> {
  final Ref _ref;

  PuzzleSessionNotifier(this._ref) : super(null);

  /// 新規パズルセッションを開始
  void startPuzzle(String animalId, List<int> expectedTiles) {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    state = PuzzleSessionState(
      sessionId: sessionId,
      animalId: animalId,
      startedAt: DateTime.now(),
      playerTiles: List.filled(expectedTiles.length, 0),
      expectedTiles: expectedTiles,
      mistakeCount: 0,
    );
  }

  /// タイルをセット
  void setTile(int index, int value) {
    if (state == null) return;

    final newPlayerTiles = [...state!.playerTiles];
    final previousValue = newPlayerTiles[index];
    newPlayerTiles[index] = value;

    // 間違っていたら mistakeCount をインクリメント
    int newMistakeCount = state!.mistakeCount;
    if (previousValue != 0 && value != state!.expectedTiles[index]) {
      newMistakeCount++;
    }

    state = state!.copyWith(
      playerTiles: newPlayerTiles,
      mistakeCount: newMistakeCount,
    );
  }

  /// パズルを完成させる
  void completePuzzle() {
    if (state == null || !state!.isCompleted) return;
    // 完成状態は外側で处理（Aha Moment演出等）
  }

  /// パズルセッションをリセット
  void resetPuzzle() {
    state = null;
  }
}

/// パズル完成判定
final isPuzzleCompletedProvider = Provider<bool>((ref) {
  final puzzleState = ref.watch(puzzleSessionProvider);
  return puzzleState != null && puzzleState.isCompleted;
});

/// 現在のパズル進捗（%）
final puzzleProgressProvider = Provider<double>((ref) {
  final puzzleState = ref.watch(puzzleSessionProvider);
  if (puzzleState == null) return 0.0;

  final correctTiles = puzzleState.playerTiles
      .asMap()
      .entries
      .where((e) => e.value == puzzleState.expectedTiles[e.key])
      .length;

  return correctTiles / puzzleState.expectedTiles.length;
});

/// ミス回数
final mistakeCountProvider = Provider<int>((ref) {
  final puzzleState = ref.watch(puzzleSessionProvider);
  return puzzleState?.mistakeCount ?? 0;
});
