# Phase 9D: App Store Submission - Quick Reference

**用途**: App Store 審査申請の最速チェックリスト  
**対象**: Product マネージャー  
**実装時間**: 3-5 営業日 (審査含)

---

## 🎯 5 分でわかる Phase 9D

```
Phase 9C Go ✅
  ↓
Step 1: ビルド最終確認 (30分)
  ├─ Version: 1.0.0+1
  ├─ TestFlight 全テスト完了
  └─ コード署名確認
  ↓
Step 2: App Store Connect 入力 (2-3時間)
  ├─ アプリ名・説明・キーワード
  ├─ スクリーンショット 6枚
  ├─ カテゴリ・評価・機能
  └─ プライバシー・サポート
  ↓
Step 3: 審査申請 (15分)
  └─ 「提出する」ボタン → Waiting for Review
  ↓
Step 4: 審査監視 (2-3日)
  └─ Daily 確認 → In Review → Approved
  ↓
Step 5: Coming Soon + 公開 (1日)
  └─ 「Coming Soon」有効化 → リリース
```

---

## ⚡ Step-by-Step Checklist

### Step 1: ビルド最終確認 (30分)

```bash
# バージョン確認
grep "^version:" pubspec.yaml
# 出力: version: 0.1.0+1 → ビルド1
#     (最初は 1.0.0+1 に変更推奨)

# Info.plist 確認
grep -A1 "CFBundleShortVersionString\|CFBundleVersion" ios/Runner/Info.plist

# TestFlight ビルド確認
# App Store Connect > TestFlight
# ✅ 内部テスター 5-10人 全員テスト完了
# ✅ 外部テスター フィードバック好意的
# ✅ Crash-Free ≥99.5%
# ✅ Aha Rate ≥60%

# コード署名確認
security find-identity -v -p codesigning
# 2) iPhone Distribution: yourwish Inc.
```

### Step 2: App Store Connect 入力 (2-3時間)

**2.1 基本情報**

```
App Store Connect
  → ぬりパズ動物園 を選択
  → バージョン 1.0.0

アプリ名:          ぬりパズ動物園 (30文字以内)
サブタイトル:      宝石パズル × 動物育成 (30文字以内)
説明文:           (以下テンプレート参照)
キーワード:       puzzle, animal, relaxing, casual (100文字以内)
```

**推奨説明文 (コピペ用)**

```
宝石パズルを完成させると、そこに動物が現れる。
完成は終わりじゃなく、新しい始まり。

毎日触れると、動物があなたに心を寄せてくる。
3日間会わないと、ちょっと寂しそうになる。

同じ色の動物を3体揃えると、
生息地でミニシーンが繰り広げられる。

育成ゲームの奥深さと、
パズルの爽快感が一つになった新感覚。

シンプルだけど、やめられない。
そんなぬりパズ動物園へようこそ。

【ぬりパズ動物園の特徴】
• 簡単だけど奥深い宝石パズル
• 100種類以上の動物が登場
• 動物ごとの個性的なリアクション
• 毎日交流して、なつき度を育成
• 3体の群れボーナスで新しい演出
• 癒し系の柔らかいビジュアル
```

**2.2 カテゴリ・評価**

```
Primary Category:      Games
Secondary Category:    Casual
Content Rating:        4+

年齢区分理由:
  暴力:             なし ✅
  悪言:             なし ✅
  性的コンテンツ:     なし ✅
  ギャンブル:        なし ✅ (広告は含むが課金ギャンブルではない)
```

**2.3 機能情報**

```
☑️ In-App Purchases: はい
☑️ 広告含む:          はい
☑️ インターネット:     はい (一部機能)
☐ Game Center:       いいえ
```

**2.4 スクリーンショット**

| # | スクリーン | 解像度 | 形式 |
|---|----------|--------|------|
| 1 | パズル画面 | 1170×2532 | PNG |
| 2 | 完成演出 | 1170×2532 | PNG |
| 3 | 動物育成 | 1170×2532 | PNG |
| 4 | 群れボーナス | 1170×2532 | PNG |
| 5 | 図鑑 | 1170×2532 | PNG |
| 6 | ホーム | 1170×2532 | PNG |

**2.5 プライバシー・サポート**

```
Privacy Policy URL:    https://yourwish.dev/privacy/ja
Support Email:         support@yourwish.dev
Support Website:       https://yourwish.dev/support (オプション)

Data Collection:       はい
├─ ユーザーID (Firebase)
├─ ゲーム進捗 (Firestore)
├─ 分析データ (Firebase Analytics)
├─ 課金情報 (RevenueCat)
└─ 広告ID (Google AdMob)

Third Parties:
├─ Firebase (Google)
├─ RevenueCat
└─ Google AdMob
```

### Step 3: 審査申請 (15分)

**最終チェック**

```
□ アプリ名・説明: 完成 ✅
□ キーワード: 100文字以内 ✅
□ スクリーンショット: 6枚 ✅
□ カテゴリ: Games/Casual ✅
□ 機能情報: In-App, 広告, インターネット ✅
□ プライバシー: URL有効 ✅
□ ビルド: 1.0.0+1 選択 ✅
```

**申請実行**

```
App Store Connect
  → ぬりパズ動物園
  → バージョン 1.0.0
  → 画面右上「提出する」
```

**承認画面**

```
☑️ ガイドラインを読了
☑️ 内容の正確性確認
→ 「提出」
```

**結果**

```
✅ 申請成功
   状態: Waiting for Review
```

### Step 4: 審査監視 (2-3日)

**毎日確認**

```
App Store Connect
  → ぬりパズ動物園
  → バージョン 1.0.0
  → 状態欄を確認
```

**状態遷移**

```
1. Waiting for Review (数時間～1日)
   → キューに追加待機

2. In Review (12-48時間)
   → Apple チーム審査中

3. Approved (承認!) ✅
   → Coming Soon 自動表示

3. Rejected (稀)
   → 理由確認 → 修正 → 再提出
```

**Rejected 時の対応**

| リジェクト理由 | 対応 |
|-------------|------|
| クラッシュ検出 | ホットフィックス ビルド → 再提出 |
| プライバシーポリシー不備 | URL 更新 → 再提出 |
| 広告実装不備 | AdMob 設定確認 → 修正 → 再提出 |
| 課金実装不備 | RevenueCat 確認 → 修正 → 再提出 |
| ビルド情報不完全 | 全項目再確認 → 再提出 |

### Step 5: Coming Soon + 公開 (1日)

**Approved 状態で自動実行**

```
App Store Connect
  → Pricing and Availability
  → Version Release Date: Automatic Release
```

**Coming Soon バナー確認**

```
App Store (ユーザー視点)
  → ぬりパズ動物園
  → Coming Soon バナー表示
  → プレビュー動画・説明文表示

確認項目:
  ✅ アイコン表示
  ✅ タイトル表示
  ✅ スクリーンショット表示
  ✅ リリース予定日表示
  ✅ 事前登録ボタン表示
```

**公開**

```
自動リリース設定の場合:
  → Approved 後、自動でリリース (通常 1-2時間)

手動リリース設定の場合:
  → App Store Connect 画面から「公開」ボタンで実行
```

---

## 📝 Key Values チートシート

```yaml
App Info:
  App Name: ぬりパズ動物園
  Subtitle: 宝石パズル × 動物育成
  Bundle ID: com.yourwish.nuripazu
  Version: 1.0.0
  Build: 1

App Store:
  Category: Games
  Sub: Casual
  Rating: 4+
  Languages: Japanese (+ English 推奨)

Support:
  Email: support@yourwish.dev
  Privacy: https://yourwish.dev/privacy/ja
  Website: https://yourwish.dev/support

Screenshots:
  Format: 1170×2532 PNG
  Count: 6 枚 (最小 2, 最大 10)
  Devices: iPhone 6.7" 以上

Features:
  IAP: はい (コスメ課金)
  Ads: はい (AdMob)
  Internet: はい (一部機能)
  Game Center: いいえ
```

---

## ⚠️ よくあるミス

| ミス | 対策 |
|------|------|
| スクリーンショットが古い | 最新ビルドで新規キャプチャ |
| Privacy Policy が英語のみ | 日本語版を用意 |
| バージョン 0.1.0 のままにした | 1.0.0 に変更 (最初はこれ) |
| プライバシーポリシー URL が切れている | 実装を確認 (404 が出ないか) |
| 説明文が 4000 文字超過 | 短縮する |
| In-App Purchase を「いいえ」にした | 「はい」に変更 (課金あるため) |
| 広告チェックボックスをチェックし忘れ | 「はい」をチェック |

---

## 🚨 審査リジェクト時の対応フロー

```
Rejected 通知
  ↓
理由を読む (e.g., "Guideline 2.1")
  ↓
対応策を特定
  ├─ クラッシュ → ホットフィックスビルド
  ├─ プライバシー → URL 更新
  ├─ 広告 → AdMob 設定修正
  ├─ 課金 → RevenueCat 確認
  └─ その他 → ガイドラインを再読
  ↓
修正実装
  ↓
新ビルド作成 & アップロード
  ↓
App Store Connect で再度「提出する」
  ↓
Waiting for Review へ (最初から)
```

---

## ✅ Phase 9D 完了チェック

### 申請直前

```
□ TestFlight 全テスト完了
□ Crash-Free ≥99.5%
□ Aha Rate ≥60%
□ クリティカルバグなし
```

### App Store Connect

```
□ アプリ名・説明・キーワード
□ スクリーンショット 6枚
□ カテゴリ・評価・機能
□ プライバシー URL有効
□ In-App Purchases: はい
□ 広告: はい
```

### 申請・審査

```
□ 審査申請完了
□ 毎日状況確認
□ Approved 取得
```

### リリース準備

```
□ Coming Soon バナー確認
□ マーケティング素材準備
□ サポート体制準備
□ リリース日決定
```

---

## 📞 Support

- **App Store Connect**: https://appstoreconnect.apple.com/
- **Apple Guideline**: https://developer.apple.com/app-store/review/guidelines/
- **Email**: support@yourwish.dev

---

**Version**: 1.0  
**Phase**: 9D App Store Review Submission  
**Timeline**: 3-5 business days
