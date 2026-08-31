import 'package:nuripazu/models/user_animal.dart';

/// アニメーション・演出サービス
/// Lottie 制御・キャラクターリアクション・効果音の統合管理
class AnimationService {
  // キャラクター個性別リアクション
  // 同じ「交流」でも性格により異なる演出を返す

  /// なつき度 Lv 昇降時のリアクションパス
  static String getAffectionReactionPath(
    String personalityTag,
    int newLevel,
    bool isIncrease,
  ) {
    if (isIncrease) {
      // なつき度上昇時のリアクション
      switch (personalityTag) {
        case 'sweetTooth': // 甘えん坊
          return 'assets/lottie/reactions/sweettooth_happy_lv$newLevel.json';
        case 'independent': // マイペース
          return 'assets/lottie/reactions/independent_cool_lv$newLevel.json';
        case 'shy': // 人見知り
          return 'assets/lottie/reactions/shy_bashful_lv$newLevel.json';
        case 'playful': // やんちゃ
          return 'assets/lottie/reactions/playful_energetic_lv$newLevel.json';
        case 'calm': // おっとり
          return 'assets/lottie/reactions/calm_peaceful_lv$newLevel.json';
        default:
          return 'assets/lottie/reactions/default_happy_lv$newLevel.json';
      }
    } else {
      // なつき度低下時のリアクション（悲しい・心配）
      switch (personalityTag) {
        case 'sweetTooth':
          return 'assets/lottie/reactions/sweettooth_sad_decline.json';
        case 'independent':
          return 'assets/lottie/reactions/independent_distant_decline.json';
        case 'shy':
          return 'assets/lottie/reactions/shy_scared_decline.json';
        case 'playful':
          return 'assets/lottie/reactions/playful_sulky_decline.json';
        case 'calm':
          return 'assets/lottie/reactions/calm_worried_decline.json';
        default:
          return 'assets/lottie/reactions/default_sad_decline.json';
      }
    }
  }

  /// 交流アクション種別（日替わり）のリアクション
  static String getInteractionReactionPath(
    String personalityTag,
    String interactionType, // 'feed' | 'pet' | 'play'
  ) {
    // interactionType と性格の組み合わせで異なるリアクション
    switch (personalityTag) {
      case 'sweetTooth': // 甘えん坊
        switch (interactionType) {
          case 'feed':
            return 'assets/lottie/interactions/sweettooth_eating_happy.json';
          case 'pet':
            return 'assets/lottie/interactions/sweettooth_nuzzle.json';
          case 'play':
            return 'assets/lottie/interactions/sweettooth_playful_excited.json';
          default:
            return 'assets/lottie/interactions/default.json';
        }
      case 'independent': // マイペース
        switch (interactionType) {
          case 'feed':
            return 'assets/lottie/interactions/independent_eating_coolly.json';
          case 'pet':
            return 'assets/lottie/interactions/independent_standoffish.json';
          case 'play':
            return 'assets/lottie/interactions/independent_aloof_play.json';
          default:
            return 'assets/lottie/interactions/default.json';
        }
      case 'shy': // 人見知り
        switch (interactionType) {
          case 'feed':
            return 'assets/lottie/interactions/shy_eating_nervously.json';
          case 'pet':
            return 'assets/lottie/interactions/shy_flinches.json';
          case 'play':
            return 'assets/lottie/interactions/shy_hesitant_play.json';
          default:
            return 'assets/lottie/interactions/default.json';
        }
      case 'playful': // やんちゃ
        switch (interactionType) {
          case 'feed':
            return 'assets/lottie/interactions/playful_gobbling.json';
          case 'pet':
            return 'assets/lottie/interactions/playful_jumpy.json';
          case 'play':
            return 'assets/lottie/interactions/playful_boundless_energy.json';
          default:
            return 'assets/lottie/interactions/default.json';
        }
      case 'calm': // おっとり
        switch (interactionType) {
          case 'feed':
            return 'assets/lottie/interactions/calm_eating_slowly.json';
          case 'pet':
            return 'assets/lottie/interactions/calm_content_purr.json';
          case 'play':
            return 'assets/lottie/interactions/calm_leisurely_play.json';
          default:
            return 'assets/lottie/interactions/default.json';
        }
      default:
        return 'assets/lottie/interactions/default.json';
    }
  }

  /// パズル完成時の祝福アニメーション
  static const String puzzleCompletionCelebration =
      'assets/lottie/completion/celebration_confetti.json';

  /// 動物出現アニメーション
  static const String animalAppear = 'assets/lottie/completion/animal_appear.json';

  /// 群れボーナスアニメーション
  static String getHerdBonusAnimation(String habitat) {
    // 生息地別の特別アニメーション
    switch (habitat) {
      case 'forest':
        return 'assets/lottie/herd_bonus/forest_celebration.json';
      case 'ocean':
        return 'assets/lottie/herd_bonus/ocean_celebration.json';
      case 'grassland':
        return 'assets/lottie/herd_bonus/grassland_celebration.json';
      case 'mountain':
        return 'assets/lottie/herd_bonus/mountain_celebration.json';
      case 'sky':
        return 'assets/lottie/herd_bonus/sky_celebration.json';
      default:
        return 'assets/lottie/herd_bonus/default_celebration.json';
    }
  }

  /// Lv4 到達時の特別ポーズアニメーション
  static String getSpecialPoseAnimation(String personalityTag) {
    // Lv4 で解放される専用ポーズ（無料特典）
    switch (personalityTag) {
      case 'sweetTooth':
        return 'assets/lottie/special_poses/sweettooth_princess.json';
      case 'independent':
        return 'assets/lottie/special_poses/independent_majestic.json';
      case 'shy':
        return 'assets/lottie/special_poses/shy_confident.json';
      case 'playful':
        return 'assets/lottie/special_poses/playful_superhero.json';
      case 'calm':
        return 'assets/lottie/special_poses/calm_zen_master.json';
      default:
        return 'assets/lottie/special_poses/default_pose.json';
    }
  }

  /// 効果音ファイルパス
  static String getSoundEffectPath(String effectType) {
    // 音声ファイル
    switch (effectType) {
      case 'tap': // タップ音
        return 'assets/sounds/ui/tap.mp3';
      case 'success': // 成功音
        return 'assets/sounds/ui/success.mp3';
      case 'failure': // 失敗音
        return 'assets/sounds/ui/failure.mp3';
      case 'level_up': // Lv上昇音
        return 'assets/sounds/affection/level_up.mp3';
      case 'level_down': // Lv低下音
        return 'assets/sounds/affection/level_down.mp3';
      case 'completion': // パズル完成音
        return 'assets/sounds/puzzle/completion.mp3';
      default:
        return '';
    }
  }

  /// 動物の鳴き声ファイルパス
  static String getAnimalVoicePath(
    String animalId,
    String interactionType, // 'happy' | 'sad' | 'neutral'
  ) {
    // 動物種ごとの個別音声
    return 'assets/sounds/animals/$animalId/${interactionType}_cry.mp3';
  }
}
