import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/services/animation_service.dart';

/// アニメーション・演出の Riverpod プロバイダ群
/// Lottie ファイルパス・状態・制御を一元管理

/// 性格タグごとのリアクションアニメーション取得
final personalityReactionProvider =
    Provider.family<String, (String personalityTag, int level, bool isIncrease)>(
  (ref, params) {
    final (personalityTag, level, isIncrease) = params;
    return AnimationService.getAffectionReactionPath(
      personalityTag,
      level,
      isIncrease,
    );
  },
);

/// 交流アクション別のリアクションアニメーション取得
final interactionReactionProvider =
    Provider.family<String, (String personalityTag, String interactionType)>(
  (ref, params) {
    final (personalityTag, interactionType) = params;
    return AnimationService.getInteractionReactionPath(
      personalityTag,
      interactionType,
    );
  },
);

/// パズル完成演出アニメーション
final puzzleCompletionAnimationProvider = Provider<String>((ref) {
  return AnimationService.puzzleCompletionCelebration;
});

/// 動物出現アニメーション
final animalAppearAnimationProvider = Provider<String>((ref) {
  return AnimationService.animalAppear;
});

/// 群れボーナスアニメーション（生息地別）
final herdBonusAnimationProvider =
    Provider.family<String, String>((ref, habitat) {
  return AnimationService.getHerdBonusAnimation(habitat);
});

/// Lv4 特別ポーズアニメーション
final specialPoseAnimationProvider =
    Provider.family<String, String>((ref, personalityTag) {
  return AnimationService.getSpecialPoseAnimation(personalityTag);
});

/// 効果音ファイルパス
final soundEffectProvider =
    Provider.family<String, String>((ref, effectType) {
  return AnimationService.getSoundEffectPath(effectType);
});

/// 動物の鳴き声ファイルパス
final animalVoiceProvider =
    Provider.family<String, (String animalId, String interactionType)>(
  (ref, params) {
    final (animalId, interactionType) = params;
    return AnimationService.getAnimalVoicePath(animalId, interactionType);
  },
);

/// アニメーション再生状態管理
class AnimationPlaybackState {
  final bool isPlaying;
  final String? currentAnimationPath;
  final double progress; // 0.0 - 1.0

  AnimationPlaybackState({
    this.isPlaying = false,
    this.currentAnimationPath,
    this.progress = 0.0,
  });

  AnimationPlaybackState copyWith({
    bool? isPlaying,
    String? currentAnimationPath,
    double? progress,
  }) {
    return AnimationPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentAnimationPath:
          currentAnimationPath ?? this.currentAnimationPath,
      progress: progress ?? this.progress,
    );
  }
}

/// アニメーション再生状態プロバイダ
final animationPlaybackProvider =
    StateNotifierProvider<AnimationPlaybackNotifier, AnimationPlaybackState>(
  (ref) => AnimationPlaybackNotifier(),
);

class AnimationPlaybackNotifier
    extends StateNotifier<AnimationPlaybackState> {
  AnimationPlaybackNotifier()
      : super(AnimationPlaybackState());

  void startAnimation(String animationPath) {
    state = state.copyWith(
      isPlaying: true,
      currentAnimationPath: animationPath,
      progress: 0.0,
    );
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void stopAnimation() {
    state = state.copyWith(
      isPlaying: false,
      progress: 0.0,
    );
  }

  void completeAnimation() {
    state = state.copyWith(
      isPlaying: false,
      progress: 1.0,
    );
  }
}

/// サウンド有効/無効 設定
final soundEnabledProvider =
    StateNotifierProvider<SoundSettingNotifier, bool>(
  (ref) => SoundSettingNotifier(true),
);

class SoundSettingNotifier extends StateNotifier<bool> {
  SoundSettingNotifier(bool initialValue) : super(initialValue);

  void toggle() {
    state = !state;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

/// BGM 有効/無効 設定
final bgmEnabledProvider =
    StateNotifierProvider<BGMSettingNotifier, bool>(
  (ref) => BGMSettingNotifier(true),
);

class BGMSettingNotifier extends StateNotifier<bool> {
  BGMSettingNotifier(bool initialValue) : super(initialValue);

  void toggle() {
    state = !state;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}

/// 現在再生中のBGMパス
final currentBGMProvider = StateNotifierProvider<CurrentBGMNotifier, String?>(
  (ref) => CurrentBGMNotifier(null),
);

class CurrentBGMNotifier extends StateNotifier<String?> {
  CurrentBGMNotifier(String? initialPath) : super(initialPath);

  void setBGM(String bgmPath) {
    state = bgmPath;
  }

  void stopBGM() {
    state = null;
  }
}

/// ハプティクス有効/無効設定
final hapticEnabledProvider =
    StateNotifierProvider<HapticSettingNotifier, bool>(
  (ref) => HapticSettingNotifier(true),
);

class HapticSettingNotifier extends StateNotifier<bool> {
  HapticSettingNotifier(bool initialValue) : super(initialValue);

  void toggle() {
    state = !state;
  }

  void setEnabled(bool enabled) {
    state = enabled;
  }
}
