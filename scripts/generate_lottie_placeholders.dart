#!/usr/bin/env dart
/// Lottie アニメーション・音声ファイルのプレースホルダー生成ツール
/// 実装: 基本的な Lottie JSON フレームワークを生成
/// 本実装: petit_ai 自動生成 or Illustrator/Figma エクスポート で置き換え

import 'dart:io';
import 'dart:convert';

/// Lottieプレースホルダー JSON を生成
String generateLottieJson(String animationName, Duration duration) {
  final durationInMs = duration.inMilliseconds;
  final frameCount = (durationInMs / 33.33).toInt(); // ~30fps

  return jsonEncode({
    "v": "5.7.14",
    "meta": {
      "g": "Placeholder animation",
      "c": "Generated placeholder for $animationName",
      "t": "Nuripazu Animation"
    },
    "fr": 30,
    "ip": 0,
    "op": frameCount,
    "w": 512,
    "h": 512,
    "ddd": 0,
    "assets": [],
    "layers": [
      {
        "ddd": 0,
        "ind": 1,
        "ty": 4,
        "nm": "Placeholder Circle",
        "sr": 1,
        "ks": {
          "o": {"a": 0, "k": 100},
          "r": {"a": 1, "k": [
            {"t": 0, "s": [0], "e": [360], "i": {"x": [0.833], "y": [0.833]}, "o": {"x": [0.167], "y": [0.167]}}
          ]},
          "p": {"a": 0, "k": [256, 256, 0]},
          "a": {"a": 0, "k": [0, 0, 0]},
          "s": {"a": 0, "k": [100, 100, 100]}
        },
        "ao": 0,
        "shapes": [
          {
            "ty": "el",
            "d": 2,
            "s": {"a": 0, "k": [100, 100]},
            "p": {"a": 0, "k": [0, 0]},
            "nm": "Ellipse Path 1"
          },
          {
            "ty": "st",
            "c": {"a": 0, "k": [0.2, 0.4, 0.9, 1]},
            "o": {"a": 0, "k": 100},
            "w": {"a": 0, "k": 2},
            "lc": 2,
            "lj": 2,
            "nm": "Stroke 1"
          },
          {
            "ty": "tr",
            "p": {"a": 0, "k": [0, 0]},
            "a": {"a": 0, "k": [0, 0]},
            "s": {"a": 0, "k": [100, 100]},
            "r": {"a": 0, "k": 0},
            "o": {"a": 0, "k": 100},
            "sk": {"a": 0, "k": 0},
            "sa": {"a": 0, "k": 0},
            "nm": "Transform"
          }
        ],
        "ip": 0,
        "op": frameCount,
        "st": 0,
        "bm": 0
      }
    ],
    "markers": []
  });
}

/// 必要なアセット一覧を定義
final assetManifest = {
  'reactions': {
    'sweettooth': ['happy_lv1', 'happy_lv2', 'happy_lv3', 'happy_lv4', 'sad_decline'],
    'independent': ['cool_lv1', 'cool_lv2', 'cool_lv3', 'cool_lv4', 'distant_decline'],
    'shy': ['bashful_lv1', 'bashful_lv2', 'bashful_lv3', 'bashful_lv4', 'scared_decline'],
    'playful': ['energetic_lv1', 'energetic_lv2', 'energetic_lv3', 'energetic_lv4', 'sulky_decline'],
    'calm': ['peaceful_lv1', 'peaceful_lv2', 'peaceful_lv3', 'peaceful_lv4', 'worried_decline'],
  },
  'interactions': {
    'sweettooth': ['eating_happy', 'nuzzle', 'playful_excited'],
    'independent': ['eating_coolly', 'standoffish', 'aloof_play'],
    'shy': ['eating_nervously', 'flinches', 'hesitant_play'],
    'playful': ['gobbling', 'jumpy', 'boundless_energy'],
    'calm': ['eating_slowly', 'content_purr', 'leisurely_play'],
  },
  'herd_bonus': {
    'forest': 'forest_celebration',
    'ocean': 'ocean_celebration',
    'grassland': 'grassland_celebration',
    'mountain': 'mountain_celebration',
    'sky': 'sky_celebration',
  },
  'special_poses': {
    'sweettooth': 'sweettooth_princess',
    'independent': 'independent_majestic',
    'shy': 'shy_confident',
    'playful': 'playful_superhero',
    'calm': 'calm_zen_master',
  },
  'completion': {
    'celebration_confetti': 'celebration_confetti',
    'animal_appear': 'animal_appear',
  }
};

Future<void> main(List<String> args) async {
  print('🎬 Lottie プレースホルダー生成スクリプト');
  print('=' * 60);

  int count = 0;

  // リアクションアニメーション生成
  print('\n📁 リアクションアニメーション...');
  final reactionsDir = Directory('assets/lottie/reactions');
  if (!await reactionsDir.exists()) {
    await reactionsDir.create(recursive: true);
  }

  for (final personality in assetManifest['reactions']!.keys) {
    for (final reaction in assetManifest['reactions']![personality]!) {
      final fileName = '${personality}_${reaction}.json';
      final file = File('${reactionsDir.path}/$fileName');
      final duration = Duration(seconds: 2);

      await file.writeAsString(generateLottieJson(fileName, duration));
      print('  ✅ $fileName');
      count++;
    }
  }

  // インタラクションアニメーション生成
  print('\n📁 インタラクションアニメーション...');
  final interactionsDir = Directory('assets/lottie/interactions');
  if (!await interactionsDir.exists()) {
    await interactionsDir.create(recursive: true);
  }

  for (final personality in assetManifest['interactions']!.keys) {
    for (final interaction in assetManifest['interactions']![personality]!) {
      final fileName = '${personality}_${interaction}.json';
      final file = File('${interactionsDir.path}/$fileName');
      final duration = Duration(seconds: 3);

      await file.writeAsString(generateLottieJson(fileName, duration));
      print('  ✅ $fileName');
      count++;
    }
  }

  // 群れボーナスアニメーション生成
  print('\n📁 群れボーナスアニメーション...');
  final herdBonusDir = Directory('assets/lottie/herd_bonus');
  if (!await herdBonusDir.exists()) {
    await herdBonusDir.create(recursive: true);
  }

  for (final habitat in assetManifest['herd_bonus']!.keys) {
    final fileName = '${assetManifest['herd_bonus']![habitat]}.json';
    final file = File('${herdBonusDir.path}/$fileName');
    final duration = Duration(seconds: 4);

    await file.writeAsString(generateLottieJson(fileName, duration));
    print('  ✅ $fileName');
    count++;
  }

  // 特別ポーズアニメーション生成
  print('\n📁 特別ポーズアニメーション...');
  final specialPosesDir = Directory('assets/lottie/special_poses');
  if (!await specialPosesDir.exists()) {
    await specialPosesDir.create(recursive: true);
  }

  for (final personality in assetManifest['special_poses']!.keys) {
    final fileName = '${assetManifest['special_poses']![personality]}.json';
    final file = File('${specialPosesDir.path}/$fileName');
    final duration = Duration(seconds: 2);

    await file.writeAsString(generateLottieJson(fileName, duration));
    print('  ✅ $fileName');
    count++;
  }

  // 完成アニメーション生成
  print('\n📁 完成演出アニメーション...');
  final completionDir = Directory('assets/lottie/completion');
  if (!await completionDir.exists()) {
    await completionDir.create(recursive: true);
  }

  for (final animation in assetManifest['completion']!.keys) {
    final fileName = '${assetManifest['completion']![animation]}.json';
    final file = File('${completionDir.path}/$fileName');
    final duration = Duration(seconds: 2);

    await file.writeAsString(generateLottieJson(fileName, duration));
    print('  ✅ $fileName');
    count++;
  }

  print('\n' + '=' * 60);
  print('✨ 完了: $count 個の Lottie プレースホルダーを生成しました');
  print('\n📝 次のステップ:');
  print('  1. petit_ai で絵柄を自動生成');
  print('  2. Illustrator/Figma で手動制作');
  print('  3. 各 JSON ファイルを本実装で置き換え');
  print('  4. flutter test で検証');
}
