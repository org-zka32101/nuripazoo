/// ジェムパズルエンジンの基本ロジック
///
/// タップ仕分け → ピクセルアート完成
/// 実装詳細は petit_core を参照予定
class PuzzleEngineService {
  /// 最初のパズルは必ず成功する簡単配色
  static const bool firstPuzzleIsAlwaysEasy = true;

  /// 完成判定の検証
  ///
  /// 戻り値: true ならば正しく完成
  static bool validateCompletion(List<int> playerTiles, List<int> expectedTiles) {
    if (playerTiles.length != expectedTiles.length) return false;
    for (int i = 0; i < playerTiles.length; i++) {
      if (playerTiles[i] != expectedTiles[i]) return false;
    }
    return true;
  }

  /// パズル難易度を判定（初回は簡単）
  static bool isEasyDifficulty(bool isFirstPuzzle) {
    return isFirstPuzzle && firstPuzzleIsAlwaysEasy;
  }

  /// ミス回数をカウント（パフォーマンス計測用）
  static void recordMistake(int currentMistakes) {
    // Firebase Analytics に記録
    // analyticsService.logPuzzleMistake(currentMistakes);
  }

  /// Aha Moment イベント: 初回パズル完成時に動物がアクションを起こす
  ///
  /// 最短経路: 起動→パズル→完成→動物1アクション = 3タップ以内・60秒以内
  static Future<void> triggerAhaMomentAnimation(String animalId) async {
    // 動物種ごとの Lottie アニメーション再生
    // 例: 'aha_moment_$animalId' または
    // 例: 'aha_moment_cry', 'aha_moment_blink'
    //
    // petit_ai生成アニメーションをここで統合予定
    await Future.delayed(const Duration(milliseconds: 500)); // アニメーション時間
  }

  /// オフライン時のパズルロジック（ローカル検証）
  static Map<String, dynamic> getOfflinePuzzleData(String animalId) {
    return {
      'animalId': animalId,
      'tiles': [],
      'expectedTiles': [],
      'isOffline': true,
    };
  }
}
