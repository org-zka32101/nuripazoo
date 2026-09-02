# Phase 8: Lottie ファイル生成 - アセット統合・資産管理

## 概要

Phase 7 のテスト・CI/CD 完成に続き、ぬりパズ動物園の「心臓」となる Lottie アニメーションおよび音声アセットの生成・統合を実施。

### Phase 8 の構成

- **8A**: Lottie プレースホルダー生成 ✅ 完了
- **8B**: 音声アセット構造構築 ✅ 完了
- **8C**: アセット資産管理マニフェスト ✅ 完了
- **8D**: petit_ai 統合・自動生成準備 → 次フェーズ検討
- **8E**: アセット置き換え・検証 → 実装時に実施
- **8F**: ビルド・デプロイ検証 → CI/CD 統合

---

## アセット構成 (52 Lottie + 16 音声)

### 1. Lottie アニメーション (52 ファイル)

#### 1.1 リアクションアニメーション (25 ファイル)

**目的**: なつき度昇降時のキャラクター表現

```
assets/lottie/reactions/
├── sweettooth_happy_lv1.json       # 甘えん坊 - なつき度Lv1上昇時
├── sweettooth_happy_lv2.json       # 甘えん坊 - なつき度Lv2上昇時
├── sweettooth_happy_lv3.json       # 甘えん坊 - なつき度Lv3上昇時
├── sweettooth_happy_lv4.json       # 甘えん坊 - なつき度Lv4上昇時 (★ Lv4特別)
├── sweettooth_sad_decline.json     # 甘えん坊 - なつき度低下時

├── independent_cool_lv1.json       # マイペース - なつき度Lv1上昇時
├── independent_cool_lv2.json       # マイペース - なつき度Lv2上昇時
├── independent_cool_lv3.json       # マイペース - なつき度Lv3上昇時
├── independent_cool_lv4.json       # マイペース - なつき度Lv4上昇時
├── independent_distant_decline.json # マイペース - なつき度低下時

├── shy_bashful_lv1.json            # 人見知り - なつき度Lv1上昇時
├── shy_bashful_lv2.json            # 人見知り - なつき度Lv2上昇時
├── shy_bashful_lv3.json            # 人見知り - なつき度Lv3上昇時
├── shy_bashful_lv4.json            # 人見知り - なつき度Lv4上昇時
├── shy_scared_decline.json         # 人見知り - なつき度低下時

├── playful_energetic_lv1.json      # やんちゃ - なつき度Lv1上昇時
├── playful_energetic_lv2.json      # やんちゃ - なつき度Lv2上昇時
├── playful_energetic_lv3.json      # やんちゃ - なつき度Lv3上昇時
├── playful_energetic_lv4.json      # やんちゃ - なつき度Lv4上昇時
├── playful_sulky_decline.json      # やんちゃ - なつき度低下時

├── calm_peaceful_lv1.json          # おっとり - なつき度Lv1上昇時
├── calm_peaceful_lv2.json          # おっとり - なつき度Lv2上昇時
├── calm_peaceful_lv3.json          # おっとり - なつき度Lv3上昇時
├── calm_peaceful_lv4.json          # おっとり - なつき度Lv4上昇時
└── calm_worried_decline.json       # おっとり - なつき度低下時
```

**Lottie 仕様**:
- 解像度: 512×512px
- フレームレート: 30fps
- 推奨再生時間: 2秒（60フレーム）
- ループ: false（1回再生）

---

#### 1.2 インタラクションアニメーション (15 ファイル)

**目的**: 日替わり交流（給餌・撫でる・遊ぶ）時の個性別リアクション

```
assets/lottie/interactions/
├── sweettooth_eating_happy.json     # 甘えん坊 - 給餌リアクション
├── sweettooth_nuzzle.json           # 甘えん坊 - 撫でるリアクション
├── sweettooth_playful_excited.json  # 甘えん坊 - 遊ぶリアクション

├── independent_eating_coolly.json   # マイペース - 給餌リアクション
├── independent_standoffish.json     # マイペース - 撫でるリアクション
├── independent_aloof_play.json      # マイペース - 遊ぶリアクション

├── shy_eating_nervously.json        # 人見知り - 給餌リアクション
├── shy_flinches.json                # 人見知り - 撫でるリアクション
├── shy_hesitant_play.json           # 人見知り - 遊ぶリアクション

├── playful_gobbling.json            # やんちゃ - 給餌リアクション
├── playful_jumpy.json               # やんちゃ - 撫でるリアクション
├── playful_boundless_energy.json    # やんちゃ - 遊ぶリアクション

├── calm_eating_slowly.json          # おっとり - 給餌リアクション
├── calm_content_purr.json           # おっとり - 撫でるリアクション
└── calm_leisurely_play.json         # おっとり - 遊ぶリアクション
```

**Lottie 仕様**:
- 解像度: 512×512px
- フレームレート: 30fps
- 推奨再生時間: 3秒（90フレーム）
- ループ: false（1回再生）

---

#### 1.3 群れボーナスアニメーション (5 ファイル)

**目的**: 生息地3体揃い時の祝福演出

```
assets/lottie/herd_bonus/
├── forest_celebration.json      # 森 - 群れボーナス演出
├── ocean_celebration.json       # 海 - 群れボーナス演出
├── grassland_celebration.json   # 草原 - 群れボーナス演出
├── mountain_celebration.json    # 山 - 群れボーナス演出
└── sky_celebration.json         # 空 - 群れボーナス演出
```

**Lottie 仕様**:
- 解像度: 512×512px
- フレームレート: 30fps
- 推奨再生時間: 4秒（120フレーム）
- ループ: false（1回再生）
- 音声: 群れボーナスSE 同時再生

---

#### 1.4 特別ポーズアニメーション (5 ファイル)

**目的**: Lv4 到達時の無料特典・固定ポーズ表示

```
assets/lottie/special_poses/
├── sweettooth_princess.json        # 甘えん坊 - プリンセスポーズ
├── independent_majestic.json       # マイペース - 威風堂々ポーズ
├── shy_confident.json              # 人見知り - 自信満々ポーズ
├── playful_superhero.json          # やんちゃ - スーパーヒーローポーズ
└── calm_zen_master.json            # おっとり - 悟りの境地ポーズ
```

**Lottie 仕様**:
- 解像度: 512×512px
- フレームレート: 30fps
- 推奨再生時間: 2秒（60フレーム、または静止画）
- ループ: false
- **設定**: 動物詳細画面で「固定表示」（アニメーション1回後、止まる）

---

#### 1.5 完成演出アニメーション (2 ファイル)

**目的**: パズル完成時の Aha Moment フロー

```
assets/lottie/completion/
├── celebration_confetti.json    # 完成祝福 - 宝石が舞う
└── animal_appear.json           # 動物出現 - 完成動物が浮かび上がる
```

**Lottie 仕様**:
- 解像度: 512×512px
- フレームレート: 30fps
- 推奨再生時間: celebration 2秒（60f）+ animal_appear 1秒（30f）
- ループ: false
- **シーケンス**: celebration_confetti → animal_appear (合計3秒)

---

### 2. 音声アセット (16 ファイル)

#### 2.1 UI・効果音 (3 ファイル)

```
assets/sounds/ui/
├── tap.mp3           # ボタンタップ音
├── success.mp3       # 成功・肯定的結果音
└── failure.mp3       # 失敗・否定的結果音
```

**仕様**:
- コーデック: MP3 or AAC
- サンプリングレート: 44.1kHz or 48kHz
- ビットレート: 128kbps
- チャンネル: Mono (8-16KB 推奨)

---

#### 2.2 なつき度関連SE (2 ファイル)

```
assets/sounds/affection/
├── level_up.mp3      # なつき度昇級時の喜びの音
└── level_down.mp3    # なつき度低下時の悲しみの音
```

**仕様**: UI/ と同じ

---

#### 2.3 パズル完成音 (1 ファイル)

```
assets/sounds/puzzle/
└── completion.mp3    # パズル完成・達成感の音
```

**仕様**: UI/ と同じ

---

#### 2.4 BGM (1 ファイル)

```
assets/sounds/bgm/
└── zoo_ambient_loop.mp3  # 動物園環境音（ループ・アンビエント）
```

**仕様**:
- コーデック: MP3 or AAC
- サンプリングレート: 44.1kHz or 48kHz
- ビットレート: 96-128kbps
- チャンネル: Stereo
- ループポイント: シームレス（Audacityで確認必須）
- 再生時間: 60秒以上推奨（ループが短いと不自然）

---

#### 2.5 動物音声 (9 ファイル: 3種類 × 3感情)

```
assets/sounds/animals/
├── animal_001/
│   ├── happy_cry.mp3       # 動物001の嬉しい鳴き声
│   ├── sad_cry.mp3         # 動物001の悲しい鳴き声
│   └── neutral_cry.mp3     # 動物001の通常の鳴き声
│
├── animal_002/
│   ├── happy_cry.mp3       # 動物002の嬉しい鳴き声
│   ├── sad_cry.mp3         # 動物002の悲しい鳴き声
│   └── neutral_cry.mp3     # 動物002の通常の鳴き声
│
└── animal_003/
    ├── happy_cry.mp3       # 動物003の嬉しい鳴き声
    ├── sad_cry.mp3         # 動物003の悲しい鳴き声
    └── neutral_cry.mp3     # 動物003の通常の鳴き声
```

**仕様**:
- コーデック: MP3 or AAC
- サンプリングレート: 44.1kHz or 48kHz
- ビットレート: 96-128kbps
- チャンネル: Mono
- 再生時間: 0.5-1.5秒（長すぎないこと）

---

## アセット生成ワークフロー

### ステップ 1: プレースホルダー生成 ✅

```bash
# Phase 8A で実行済み
python3 scripts/generate_lottie_placeholders.py
# → 52個の Lottie JSON プレースホルダーを生成
# → 16個の音声ディレクトリを生成
```

### ステップ 2: 本実装アセット生成（複数パス）

#### パス A: petit_ai 自動生成（推奨）

```bash
# petit_ai を使用した Lottie JSON 自動生成
# ☆ 最も効率的・拡張性高い

cd docs/
python3 generate_animations_petitai.py

# 出力: assets/lottie/*/*.json (本実装)
```

**メリット**:
- 自動・高速・再現性高い
- スタイル統一可能
- 月次更新も容易

**デメリット**:
- petit_ai の絵柄クセ（独特の色合い・線画スタイル）
- カスタマイズ幅が限られる

---

#### パス B: Illustrator/Figma 手動制作

```
# 手作業・人的工数大（1ファイル 10-30分）
# ☆ 高品質・カスタマイズ自由度高い

1. Figma テンプレート開く
2. 各アニメーション設計（ストーリーボード）
3. Figma でベクター制作
4. Bodymovin プラグイン で JSON エクスポート
5. assets/lottie/*/*.json に配置
6. 再生テスト
```

**メリット**:
- 高品質・細部コントロール可能
- スタイル自由（独自性出やすい）

**デメリット**:
- 工数大（全52個は数週間必要）
- 運用コスト高

---

#### パス C: ハイブリッド（petit_ai + 手動調整）

```
# 最もバランスの取れたアプローチ

1. petit_ai で基盤生成（自動80%）
2. Figma で調整・改善（手動20%）
3. Bodymovin でエクスポート
4. assets に配置
```

---

### ステップ 3: 音声アセット生成

```bash
# UI/SE: 各 3-5秒、テンポ 120BPM
# BGM: 60秒以上、シームレスループ
# 動物音声: 0.5-1.5秒、リアルな鳴き声

# 生成方法（複数選択肢）
- ① Audacity + Free FX（推奨：無料・高品質）
- ② Logic Pro + iZotope（Mac 専用・最高品質）
- ③ Freesound.org ダウンロード + 編集
- ④ 実録音（スタジオ・フィールド）
```

### ステップ 4: ビルド・検証

```bash
# 依存関係再読み込み
flutter pub get

# アセット確認
flutter analyze

# デバイスで再生テスト
flutter run

# CI/CD テスト実行
flutter test
```

---

## ファイル置き換え手順

### 1. Lottie JSON 置き換え

```bash
# 各ファイルをプレースホルダーから本実装に置き換え
# 例：
rm assets/lottie/reactions/sweettooth_happy_lv1.json
cp ~/downloads/sweettooth_happy_lv1_final.json assets/lottie/reactions/

# すべてのファイルをバッチ置き換え（スクリプト化推奨）
```

### 2. 音声ファイル置き換え

```bash
# 各 .mp3 を実装ファイルに置き換え
# 例：
cp ~/audio/tap_sound.mp3 assets/sounds/ui/tap.mp3

# ビットレート確認（ffmpeg）
ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1:nw=1 assets/sounds/ui/tap.mp3
```

### 3. 動作検証

```bash
# ウィジェットテストで再生確認
flutter test test/widget/lottie_animation_widget_test.dart

# 統合テストで Aha フロー確認
flutter test test/integration/aha_moment_flow_test.dart

# 実デバイスで音量・遅延・スキップ確認
flutter run --release
```

---

## アセット管理・品質チェック

### チェックリスト（アセット置き換え時）

```markdown
## Lottie アニメーション

### リアクション
- [ ] sweettooth_happy_lv1-4: 甘えん坊の喜びが表現されている？
- [ ] sweettooth_sad_decline: 甘えん坊の落ち込みが表現されている？
- [ ] (他4性格も同様)

### インタラクション
- [ ] sweettooth_eating_happy: 食べてるシーン感が出ている？
- [ ] sweettooth_nuzzle: 触れ合いが柔らかく表現されている？
- [ ] sweettooth_playful_excited: 遊びの楽しさが表現されている？
- [ ] (他4性格も同様)

### 群れボーナス
- [ ] forest_celebration: 森の雰囲気が出ている？
- [ ] ocean_celebration: 海の雰囲気が出ている？
- [ ] (他3生息地も同様)

### 特別ポーズ
- [ ] sweettooth_princess: プリンセス風な高貴さが出ている？
- [ ] independent_majestic: 威風堂々とした迫力が出ている？
- [ ] (他3性格も同様)

### 完成演出
- [ ] celebration_confetti: 宝石が舞うエフェクト？
- [ ] animal_appear: 完成動物が浮かび上がる感？

## 音声アセット

### UI/SE
- [ ] tap.mp3: ボタンタップの軽い音か？
- [ ] success.mp3: ポジティブな達成感？
- [ ] failure.mp3: ネガティブ・悔しさが表現されている？

### なつき度
- [ ] level_up.mp3: 喜びの音・上昇感がある？
- [ ] level_down.mp3: 落ち込みの音・悲しさがある？

### パズル
- [ ] completion.mp3: 大勝利感・達成感？

### BGM
- [ ] zoo_ambient_loop.mp3: 和みのアンビエント・60秒以上？
- [ ] ループポイントはシームレス？

### 動物音声
- [ ] animal_001_happy_cry: 嬉しい鳴き声か？
- [ ] animal_001_sad_cry: 悲しい鳴き声か？
- [ ] animal_001_neutral_cry: 通常の鳴き声か？
- [ ] (animal_002, animal_003 も同様)
```

---

## ファイルサイズ・最適化

### ターゲット（デバイス容量・通信効率）

| カテゴリ | ファイル数 | 目標単価 | 目標合計 |
|---------|---------|--------|--------|
| Lottie JSON | 52 | 50KB | 2.6MB |
| UI/SE | 3 | 20KB | 60KB |
| 動物音声 | 9 | 50KB | 450KB |
| BGM | 1 | 500KB | 500KB |
| **合計** | 65 | - | **3.6MB** |

### 最適化テクニック

```bash
# JSON 最小化（Lottie）
node -e "console.log(JSON.stringify(JSON.parse(require('fs').readFileSync('test.json'))))" > test.min.json

# 音声圧縮（ffmpeg）
ffmpeg -i input.mp3 -codec:a libmp3lame -q:a 4 output_optimized.mp3

# 効果測定
ls -lah assets/lottie/reactions/ | grep json | awk '{s+=$5} END {print s/1024 "KB"}'
```

---

## トラブルシューティング

### Lottie 再生時エラー

```
❌ Error: Cannot load file 'assets/lottie/reactions/sweettooth_happy_lv1.json'

✅ 対処:
1. flutter pub get で依存関係再読み込み
2. pubspec.yaml に assets フォルダ登録確認
3. JSON ファイル名のタイプミス確認（大文字・小文字）
4. ファイルエンコーディングが UTF-8 か確認（BOM なし）
```

### 音声再生時エラー

```
❌ Error: Cannot load audio file 'assets/sounds/ui/tap.mp3'

✅ 対処:
1. ファイルフォーマット確認（MP3 / AAC）
2. ffprobe でコーデック確認
3. AudioPlayer の初期化確認（AudioService で）
4. パーミッション確認（iOS: Info.plist, Android: permissions)
```

### ビルド失敗（アセット量多）

```
❌ Error: App Bundle too large (> 150MB)

✅ 対処:
1. 不要な Lottie JSON を削除
2. 音声ファイルを AAC に変換（MP3 より 10-20% 小）
3. 解像度を 512×512 → 256×256 に低下（Retina 非対応）
4. 一部アセットを Firebase Storage に移動（ダウンロード型）
```

---

## 次フェーズ（Phase 9）

Phase 8 でアセット構造が整ったら、Phase 9 では:

### Phase 9: TestFlight・ストア出申請

- [ ] アセット完成度 100% 確認
- [ ] TestFlight 外部テスト設定
- [ ] Day1 クラッシュフリー 99.5%+ 確認
- [ ] Aha到達率 60%+ 確認
- [ ] App Store 審査申請
- [ ] Google Play 審査申請

---

## 参考リソース

### Lottie 生成ツール

| ツール | 用途 | 難易度 | コスト |
|-------|------|--------|--------|
| petit_ai | 自動生成（絵柄） | 低 | 無料/有料 |
| Illustrator | ベクター制作 | 高 | $20.99/月 |
| Figma | Web ベース制作 | 中 | 無料/有料 |
| LottieFiles | テンプレ検索 | 低 | 無料 |

### 音声生成ツール

| ツール | 用途 | 難易度 | コスト |
|-------|------|--------|--------|
| Audacity | 録音・編集 | 中 | 無料 |
| Logic Pro | DAW | 高 | $4.99 or 買切 |
| Freesound | ダウンロード | 低 | 無料/CC-BY |
| Splice | ダウンロード | 低 | $7.99/月 |

---

## KPI・計測

| イベント | タイミング | 計測 |
|---------|---------|------|
| `animation_loaded` | Lottie 再生開始時 | 再生成功率 |
| `audio_played` | 音声再生開始時 | 再生成功率 |
| `aha_moment_animation` | パズル完成時 | Aha 到達率 |
| `interaction_animation` | 交流時 | なつき度更新率 |

---

🎬 **Phase 8 完了** - アセット構造が整った状態でリリース準備へ

---

Generated by [Claude Code](https://claude.ai/code)
