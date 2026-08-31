import 'package:nuripazu/models/index.dart';

/// なつき度育成システムを管理するサービス層
///
/// 【段階】Lv1(出会う)→Lv2(慣れる)→Lv3(なつく)→Lv4(絆MAX・専用ポーズ解放)
/// 【上昇条件】1日1回のタップ交流（エサ/なでる/遊ぶを日替わりでランダム提示）
/// 【下降条件】3日未交流でLv1段階分低下（放置ペナルティ＝復帰ナッジの根拠）
/// 【Lv4特典】専用ポーズがホーム画面に固定表示（育成実績の可視化資産）※無料機能として提供
class AffectionService {
  /// 最大なつき度レベル
  static const int maxAffectionLevel = 4;

  /// 最小なつき度レベル
  static const int minAffectionLevel = 1;

  /// なつき度が低下するまでの日数（未交流）
  static const int daysToDecline = 3;

  /// なつき度を1段階上昇させる
  ///
  /// 条件: 1日1回の交流まで効果あり
  /// 戻り値: 上昇後のレベル
  static int increaseAffectionLevel(int currentLevel) {
    final newLevel = (currentLevel + 1).clamp(minAffectionLevel, maxAffectionLevel);
    return newLevel;
  }

  /// なつき度を1段階低下させる
  ///
  /// 条件: 3日未交流でこの関数が呼ばれる
  /// 戻り値: 低下後のレベル
  static int decreaseAffectionLevel(int currentLevel) {
    final newLevel = (currentLevel - 1).clamp(minAffectionLevel, maxAffectionLevel);
    return newLevel;
  }

  /// 未交流期間から低下判定を行う
  ///
  /// 戻り値: true ならば低下対象（3日以上未交流）
  static bool shouldDeclineAffection(DateTime lastInteractedAt) {
    final now = DateTime.now();
    final daysDifference = now.difference(lastInteractedAt).inDays;
    return daysDifference >= daysToDecline;
  }

  /// 本日の交流済みかどうかを判定
  ///
  /// 戻り値: true ならば本日既に交流実績あり（1日1回制限チェック用）
  static bool hasInteractedToday(DateTime lastInteractedAt) {
    final now = DateTime.now();
    return now.year == lastInteractedAt.year &&
        now.month == lastInteractedAt.month &&
        now.day == lastInteractedAt.day;
  }

  /// なつき度レベルの説明を取得
  static String getAffectionLevelDescription(int level) {
    switch (level) {
      case 1:
        return '出会う';
      case 2:
        return '慣れる';
      case 3:
        return 'なつく';
      case 4:
        return '絆MAX';
      default:
        return '不明';
    }
  }

  /// Lv4 到達時に専用ポーズが解放されるか判定
  static bool isSpecialPoseUnlocked(int affectionLevel) {
    return affectionLevel >= maxAffectionLevel;
  }

  /// 動物の個性に基づいた交流リアクションの選択
  ///
  /// 注: 実装時には Lottie アニメーション ID を返すようにする
  static String getReactionByPersonality(
    PersonalityTag personality,
    String interactionType, // 'feed', 'pet', 'play'
  ) {
    // 個性タグごとにリアクション演出を分岐
    // 例: sweetTooth × feed = 喜ぶ演出
    // 例: shy × pet = 恥ずかしがる演出
    //
    // 詳細は petit_ai 生成 Lottie に依存
    return 'reaction_${personality.name}_$interactionType';
  }

  /// デバッグ用: 全レベル情報を取得
  static Map<String, dynamic> debugAffectionState(UserAnimal userAnimal) {
    return {
      'currentLevel': userAnimal.affectionLevel,
      'lastInteractedAt': userAnimal.lastInteractedAt,
      'daysSinceInteraction': DateTime.now().difference(userAnimal.lastInteractedAt).inDays,
      'shouldDecline': shouldDeclineAffection(userAnimal.lastInteractedAt),
      'hasInteractedToday': hasInteractedToday(userAnimal.lastInteractedAt),
      'isLv4': isSpecialPoseUnlocked(userAnimal.affectionLevel),
    };
  }
}
