# Phase 6: Lottie + Visual Polish（ロッティ・ビジュアル強化）- 実装開始

## 概要

Phase 6では、ゲームに Lottie アニメーション・効果音・ハプティクスを統合し、没入感を高める演出システムを実装します。

**目標**: 各操作に一貫した感覚フィードバックを与え、ゲーム内「愛着」を加速させる

---

## 実装進行状況

### Phase 6A: Animation Framework ✅ 完了

**AnimationService** (`lib/services/animation_service.dart`)
- 性格タグ別のリアクションパス管理
- Lottie ファイルの一元化
- 動物種別の音声ファイルパス管理

**LottieAnimationWidget** (`lib/widgets/lottie_animation_widget.dart`)
- Lottie ファイルの統一レンダリング
- アニメーション再生制御
- AnimationSequence（複数アニメーション順序実行）

**animation_provider** (`lib/viewmodels/animation_provider.dart`)
- Riverpod での Lottie リソース管理
- アニメーション再生状態トラッキング
- サウンド・BGM・ハプティクス設定

### Phase 6B: Personality-Based Reactions 🔄 実装予定

個性タグごとの異なるリアクション実装：

```
personalityTag | interactionType | Result
===============================================
sweetTooth     | feed           | eating_happy.json
(甘えん坊)     | pet            | nuzzle.json
               | play           | playful_excited.json

independent    | feed           | eating_coolly.json
(マイペース)   | pet            | standoffish.json
               | play           | aloof_play.json

shy            | feed           | eating_nervously.json
(人見知り)     | pet            | flinches.json
               | play           | hesitant_play.json

playful        | feed           | gobbling.json
(やんちゃ)     | pet            | jumpy.json
               | play           | boundless_energy.json

calm           | feed           | eating_slowly.json
(おっとり)     | pet            | content_purr.json
               | play           | leisurely_play.json
```

**実装ファイル構成** (`assets/lottie/`):
```
lottie/
├── reactions/
│   ├── sweettooth_happy_lv1.json
│   ├── sweettooth_happy_lv2.json
│   ├── sweettooth_happy_lv3.json
│   ├── sweettooth_happy_lv4.json
│   ├── sweettooth_sad_decline.json
│   ├── independent_cool_lv1.json
│   ├── independent_cool_lv2.json
│   ├── independent_cool_lv3.json
│   ├── independent_cool_lv4.json
│   ├── independent_distant_decline.json
│   ├── shy_bashful_lv1.json
│   ├── shy_bashful_lv2.json
│   ├── shy_bashful_lv3.json
│   ├── shy_bashful_lv4.json
│   ├── shy_scared_decline.json
│   ├── playful_energetic_lv1.json
│   ├── playful_energetic_lv2.json
│   ├── playful_energetic_lv3.json
│   ├── playful_energetic_lv4.json
│   ├── playful_sulky_decline.json
│   ├── calm_peaceful_lv1.json
│   ├── calm_peaceful_lv2.json
│   ├── calm_peaceful_lv3.json
│   ├── calm_peaceful_lv4.json
│   ├── calm_worried_decline.json
│   └── default_*.json (fallbacks)
│
├── interactions/
│   ├── sweettooth_eating_happy.json
│   ├── sweettooth_nuzzle.json
│   ├── sweettooth_playful_excited.json
│   ├── independent_eating_coolly.json
│   ├── independent_standoffish.json
│   ├── independent_aloof_play.json
│   ├── shy_eating_nervously.json
│   ├── shy_flinches.json
│   ├── shy_hesitant_play.json
│   ├── playful_gobbling.json
│   ├── playful_jumpy.json
│   ├── playful_boundless_energy.json
│   ├── calm_eating_slowly.json
│   ├── calm_content_purr.json
│   ├── calm_leisurely_play.json
│   └── default.json
│
├── completion/
│   ├── celebration_confetti.json
│   └── animal_appear.json
│
├── herd_bonus/
│   ├── forest_celebration.json
│   ├── ocean_celebration.json
│   ├── grassland_celebration.json
│   ├── mountain_celebration.json
│   ├── sky_celebration.json
│   └── default_celebration.json
│
└── special_poses/
    ├── sweettooth_princess.json
    ├── independent_majestic.json
    ├── shy_confident.json
    ├── playful_superhero.json
    ├── calm_zen_master.json
    └── default_pose.json
```

### Phase 6C: Sound Design 🔄 実装予定

**SE（効果音）** (`assets/sounds/ui/`):
- `tap.mp3` - UI ボタンタップ音
- `success.mp3` - 成功（パズル完成）
- `failure.mp3` - 失敗（バッドアニメーション）
- `level_up.mp3` - なつき度 Lv 上昇
- `level_down.mp3` - なつき度 Lv 低下

**動物音声** (`assets/sounds/animals/`):
- `<animalId>/happy_cry.mp3` - 喜び（交流時）
- `<animalId>/sad_cry.mp3` - 悲しみ（Lv低下時）
- `<animalId>/neutral_cry.mp3` - ニュートラル（図鑑表示時）

**BGM** (`assets/sounds/bgm/`):
- `zoo_ambient_loop.mp3` - 動物園環境音（全画面共通）

### Phase 6D: Haptic Feedback 🔄 実装予定

```dart
// タップ時の軽いバイブレーション
HapticFeedback.lightImpact();

// 成功時の強いバイブレーション
HapticFeedback.mediumImpact();

// Lv4到達時の複合パターン
HapticFeedback.heavyImpact();
Future.delayed(Duration(ms: 200));
HapticFeedback.mediumImpact();
```

---

## Riverpod Integration

### アニメーションパス取得

```dart
// 性格別Lv昇降リアクション
final reactionPath = ref.watch(
  personalityReactionProvider(
    ('playful', 2, true) // personalityTag, level, isIncrease
  )
); // → 'assets/lottie/reactions/playful_energetic_lv2.json'

// 交流アクション別リアクション
final interactionPath = ref.watch(
  interactionReactionProvider(
    ('shy', 'pet') // personalityTag, interactionType
  )
); // → 'assets/lottie/interactions/shy_flinches.json'

// 群れボーナス演出
final herdPath = ref.watch(
  herdBonusAnimationProvider('forest')
); // → 'assets/lottie/herd_bonus/forest_celebration.json'

// Lv4特別ポーズ
final posePath = ref.watch(
  specialPoseAnimationProvider('independent')
); // → 'assets/lottie/special_poses/independent_majestic.json'
```

### サウンド制御

```dart
// SE 再生
final tapSound = ref.watch(soundEffectProvider('tap'));
// → 'assets/sounds/ui/tap.mp3'

// 動物音声
final animalVoice = ref.watch(
  animalVoiceProvider(('animal_001', 'happy'))
);
// → 'assets/sounds/animals/animal_001/happy_cry.mp3'

// BGM 再生状態
final bgmEnabled = ref.watch(bgmEnabledProvider);
final currentBGM = ref.watch(currentBGMProvider);
```

### 設定管理

```dart
// サウンド有効/無効
ref.read(soundEnabledProvider.notifier).toggle();

// BGM 制御
ref.read(bgmEnabledProvider.notifier).setEnabled(false);

// ハプティクス設定
ref.read(hapticEnabledProvider.notifier).toggle();
```

---

## 画面別の演出設定

### AnimalDetailScreen
- **ボタンタップ**: `tap.mp3` + 軽いハプティクス
- **交流実行時**: interactionReaction + animalVoice + mediumHaptic
- **Lv昇降**: levelReaction + levelSE + mediumHaptic
- **Lv低下警告**: warningAnimation

### PuzzleScreen
- **タイル選択**: `tap.mp3` + lightHaptic
- **パズル完成**: completionCelebration + `success.mp3` + heavyHaptic
- **動物出現**: animalAppear + animalVoice

### HomeScreen
- **BGM 常時再生**: `zoo_ambient_loop.mp3` (ループ)
- **ボタンタップ**: `tap.mp3` + lightHaptic

### HerdSceneScreen
- **群れ演出**: herdBonusAnimation(habitat) + celebrationSE + complexHaptic

---

## 技術実装パターン

### Lottie 統合（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter
  lottie: ^3.0.0  # Dart/Flutter Lottie Package
```

### アニメーション再生フロー

```dart
// 1. Riverpod で animation path 取得
final animationPath = ref.watch(
  personalityReactionProvider(('playful', 2, true))
);

// 2. LottieAnimationWidget で再生
LottieAnimationWidget(
  assetPath: animationPath,
  width: 200,
  height: 200,
  repeat: false,
  autoplay: true,
  onComplete: () {
    // アニメーション完了後処理
    ref.refresh(userAnimalProvider(animalId));
  },
)

// 3. 音声再生（平行）
final audioPlayer = AudioPlayer(); // audioplayers package
await audioPlayer.play(
  AssetSource(ref.watch(soundEffectProvider('success')))
);

// 4. ハプティクス（平行）
if (ref.watch(hapticEnabledProvider)) {
  HapticFeedback.mediumImpact();
}
```

### AnimationSequence（複数アニメーション順序実行）

```dart
// 例: パズル完成時
AnimationSequence(
  animationPaths: [
    ref.watch(puzzleCompletionAnimationProvider), // celebrationConfetti
    ref.watch(animalAppearAnimationProvider),     // animalAppear
  ],
  durations: [
    Duration(seconds: 2),
    Duration(seconds: 1),
  ],
  onSequenceComplete: () {
    // 全アニメーション完了後 → 「動物園へ戻る」ボタン表示
  },
)
```

---

## ファイル構成確認

### 新規ファイル
- ✅ `lib/services/animation_service.dart` - Lottie & Sound パス管理
- ✅ `lib/widgets/lottie_animation_widget.dart` - Lottie UI ウィジェット
- ✅ `lib/viewmodels/animation_provider.dart` - Riverpod 統合

### 更新予定ファイル
- 🔄 `lib/views/animal_detail_screen.dart` - リアクション Lottie 表示
- 🔄 `lib/views/puzzle_screen.dart` - 完成演出 Lottie
- 🔄 `lib/views/home_screen.dart` - BGM 再生制御
- 🔄 `lib/views/herd_scene_screen.dart` - 群れ演出 Lottie

### assets ディレクトリ
- 📁 `assets/lottie/` - Lottie ファイル (37個予定)
- 📁 `assets/sounds/ui/` - UI SE (5個)
- 📁 `assets/sounds/animals/` - 動物音声（動物種 × 3タイプ）
- 📁 `assets/sounds/bgm/` - BGM (1個)

---

## 次ステップ（Phase 6B-D）

### 優先度順

1. **Phase 6B**: AnimalDetailScreen に交流リアクション統合
   - 性格別Lottie 条件分岐
   - 動物音声再生
   - ハプティクスフィードバック

2. **Phase 6C**: PuzzleScreen 完成演出強化
   - AnimationSequence で celebrationConfetti → animalAppear
   - Success SE + 複合ハプティクス

3. **Phase 6D**: BGM & 環境音
   - HomeScreen で zoo_ambient_loop ループ再生
   - 画面遷移時の音量制御

4. **Phase 6E**: Lottie ファイル生成・petit_ai 検討
   - petit_ai で自動生成可能性検証
   - Illustrator/Figma で手動生成（フォールバック）

---

## 依存パッケージ

### pubspec.yaml に追加予定

```yaml
dependencies:
  lottie: ^3.0.0              # Lottie アニメーション
  audioplayers: ^6.0.0        # 音声再生
  flutter_haptic_feedback: ^2.0.0 # ハプティクス (native 使用)
```

### iOS/Android 対応

**iOS** (`ios/Podfile`):
```ruby
# Haptics は framework 'UIKit' で自動対応
```

**Android** (`android/app/build.gradle`):
```gradle
dependencies {
    // audioplayers は ExoPlayer を使用
    implementation 'com.google.android.exoplayer:exoplayer:2.18.5'
}
```

---

## テスト方針

### Unit テスト
- AnimationService のパス返却ロジック
- 性格タグ別分岐の完全性チェック

### Widget テスト
- LottieAnimationWidget の再生制御
- AnimationSequence の順序実行

### Integration テスト
- AnimalDetailScreen 交流 → Lottie → 音声 → ハプティクス 全フロー
- HerdSceneScreen 自動消滅 + 演出一式

---

## パフォーマンス最適化

### メモリ
- Lottie ファイルはオンデマンド読み込み
- 使用後は AnimationController を dispose

### 音声
- SE は キャッシュ再利用（AudioPlayer pool）
- BGM は シングルトン再生

### ハプティクス
- 設定 OFF 時は即座にスキップ
- プラットフォーム非対応時は graceful fallback

---

## KPI追加計測

| イベント | タイミング | 目的 |
|--------|---------|------|
| `lottie_displayed` | Lottie 再生 | エンゲージメント |
| `sound_played` | SE/BGM 再生 | 感覚フィードバック |
| `haptic_triggered` | ハプティクス実行 | デバイス対応率 |
| `special_pose_unlocked` | Lv4 初回到達 | マイルストーン |

---

## コミット予定

```
Phase 6A: Lottie+Animation Framework実装 - Riverpod統合完了

実装内容:
- AnimationService: 性格別Lottie・音声パス一元管理
- LottieAnimationWidget: Lottie再生UI
- animation_provider: Riverpod統合・再生状態管理
- AnimationSequence: 複数アニメーション順序実行

設計:
- 性格タグ5種 × Lv4 + decline = 21パターン
- 交流type3種 × 性格5種 = 15パターン
- 生息地5種別ボーナス演出
- Lv4特別ポーズ（無料）

依存ライブラリ:
- lottie: ^3.0.0
- audioplayers: ^6.0.0
- flutter_haptic_feedback: ^2.0.0

次フェーズ:
- AnimalDetailScreen交流Lottie統合
- PuzzleScreen完成演出強化
- BGM・SE全画面統合
```

