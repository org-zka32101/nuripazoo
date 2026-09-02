# Phase 9D: App Store Review Submission

**用途**: App Store 審査申請から「Coming Soon」段階までの完全ガイド  
**対象**: Product マネージャー・デベロッパー  
**実装時間**: 3-5 営業日

---

## 📋 Phase 9D 概要

Phase 9C の Go/No-Go 判定で **GO** を取得した後、App Store での審査申請を実行します。

```
Phase 9C (Go ✅)
    ↓
Phase 9D: App Store 申請
    ├─ Step 1: 最終ビルド準備
    ├─ Step 2: App Store Connect 情報入力
    ├─ Step 3: アプリ審査申請
    ├─ Step 4: 審査状況監視
    └─ Step 5: 承認後の「Coming Soon」設定
    ↓
App Store 承認 → 公開リリース準備
```

---

## 🎯 Phase 9D Success Criteria

✅ **全てのクリティア達成で公開準備完了**

```
□ App Store Connect でビルド承認
□ アプリ審査申請完了
□ Apple 審査チーム承認済み
□ 「Coming Soon」表示が有効
□ 日本・米国での配信確認
□ MarketingMaterials (スクショ・説明) 最終確認
```

---

## Step 1: 最終ビルド準備 (30分)

### バージョン・ビルド番号の確認

```bash
# pubspec.yaml を確認
grep "^version:" pubspec.yaml
# 出力例: version: 0.1.0+1

# Info.plist で確認
grep -A1 "CFBundleShortVersionString\|CFBundleVersion" ios/Runner/Info.plist
```

**推奨バージョン戦略**:
- 初回リリース: `1.0.0+1` (version + buildNumber)
- 以降のアップデート: `1.0.1+2`, `1.1.0+3`

### TestFlight ビルドの最終検証

```bash
# 最新ビルドが本番環境で動作しているか確認
# App Store Connect > TestFlight > ぬりパズ動物園
# ✅ 全社内テスター (5-10人) が問題なくテスト完了
# ✅ 外部テスター のフィードバックが好意的
```

**チェック項目**:
- [ ] Firebase 本番環境に接続している
- [ ] Analytics イベントが送信されている
- [ ] Crashlytics でクラッシュが報告されていない
- [ ] 課金フロー (RevenueCat) が動作している
- [ ] 広告 (AdMob) が表示されている

### コード署名の最終確認

```bash
# コード署名証明書が有効か確認
security find-identity -v -p codesigning

# 出力例:
# 1) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "Apple Development: example@yourwish.dev (XXXXXXXXXX)"
# 2) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "iPhone Distribution: yourwish Inc. (XXXXXXXXXX)"
```

**App Store 用は 2) のディストリビューション証明書を使用**

---

## Step 2: App Store Connect 情報入力 (2-3時間)

### 2.1 アプリ基本情報

**App Store Connect へログイン**
```
https://appstoreconnect.apple.com/ → ぬりパズ動物園 を選択
```

### 2.2 ビルドの選択

```
App Store Connect 
  → ぬりパズ動物園 
  → ビルド 
  → TestFlight から本番ビルドを選択 (v1.0.0+1)
```

**必要な確認**:
- [ ] Build version: 1.0.0+1 が表示されている
- [ ] Build status: `Uploaded to App Store` になっている
- [ ] iOS Minimum Version: 14.0 以上

### 2.3 AppStore 情報タブ

**アプリ名と説明**

| フィールド | 値 | 制限 |
|-----------|-----|------|
| App Name | ぬりパズ動物園 | 30文字以内 |
| Subtitle | 宝石パズル × 動物育成 | 30文字以内 |
| Description | (以下参照) | 4,000文字以内 |
| Keywords | puzzle, animal, relaxing, casual | 100文字以内 |

**推奨 Description** (日本語):

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

【安心な機能設計】
• シンプルで分かりやすい操作
• 無料でご利用可能
• 広告が表示されます
• お好みに応じてコスメ課金も選択可能
```

### 2.4 カテゴリ・評価

**Primary Category**: `Games`  
**Secondary Category**: `Casual`

**Content Rating** (年齢区分)

```
年齢区分: 4+ (一般向け)

暴力: なし ✅
過度な悪言: なし ✅
性的コンテンツ: なし ✅
アルコール・タバコ: なし ✅
ギャンブル: なし ✅ (広告は含む)
医療情報: なし ✅
```

### 2.5 スクリーンショット・プレビュー

**各デバイスのスクリーンショット (6枚推奨)**

| 順序 | スクリーン | 説明 |
|-----|----------|------|
| 1 | パズル画面 | 宝石を消す爽快感 |
| 2 | 完成演出 | 動物が現れる瞬間 |
| 3 | 動物詳細 | なつき度を育成 |
| 4 | 群れボーナス | 3体揃ったミニシーン |
| 5 | 図鑑・コレクション | 100種類の動物 |
| 6 | ホーム画面 | 動物園の全景 |

**スクリーンショット仕様**:
- 解像度: 1170×2532px (iPhone 15 Pro)
- フォーマット: PNG または JPG
- 各言語別: 日本語版が必須

**プレビュー動画** (オプション、15-30秒):
- App のハイライトを30秒以内で表示
- BGM・効果音付き推奨
- 動物のかわいさと爽快感を演出

### 2.6 プライバシーと安全情報

**Privacy Policy URL**
```
https://yourwish.dev/privacy/ja
```

**Support Email**
```
support@yourwish.dev
```

**Support Website** (オプション)
```
https://yourwish.dev/support
```

**Privacy and Data Practices** (App Privacy)

```
✅ ユーザーデータを収集: はい

データ収集項目:
├─ ユーザーID (Firebase Auth UID)
├─ ゲーム進捗 (Firestore)
├─ 分析イベント (Firebase Analytics)
│  └─ パズル完成数、なつき度更新回数、など
├─ 課金情報 (RevenueCat)
│  └─ 購入履歴、サブスク状態
└─ 広告ID (Google Mobile Ads)
   └─ 広告最適化のため

データ使用目的:
├─ アプリ機能の提供
├─ パフォーマンス改善
├─ ユーザー分析
├─ 広告配信
└─ セキュリティ・不正防止

第三者との共有:
├─ Firebase (Google) - バックエンド
├─ RevenueCat - 課金
├─ Google AdMob - 広告
└─ その他はなし
```

**Tracking & Privacy**

```
☑️ トラッキング同意をリクエスト
  → App Tracking Transparency (ATT) を有効化
  → ユーザーが opt-in/opt-out できるようにする
```

### 2.7 設定・サポート

**Game Information**

| 項目 | 値 |
|-----|-----|
| Arcade: Sports | いいえ |
| MFi Controller | いいえ |
| In-App Purchases | はい |
| Requires internet | はい (一部機能のみ) |
| Health & fitness data | いいえ |

**Game Center** (オプション)
```
Game Center を使用していない場合: チェックなし
```

---

## Step 3: アプリ審査申請 (15分)

### 提出前の最終チェック

```
App Store Connect
  → ぬりパズ動物園 
  → バージョン 1.0.0
  → App Information をすべて入力したか確認
```

**チェックリスト**:

```
□ バージョン情報完成
  ├─ アプリ名: ぬりパズ動物園 ✅
  ├─ サブタイトル: 宝石パズル × 動物育成 ✅
  ├─ 説明文: 4,000文字以内 ✅
  ├─ キーワード: 100文字以内 ✅
  └─ スクリーンショット: 6枚 ✅

□ カテゴリ・評価
  ├─ Primary: Games ✅
  ├─ Secondary: Casual ✅
  ├─ Content Rating: 4+ ✅
  └─ 評価理由: 暴力なし ✅

□ 機能情報
  ├─ In-App Purchases: はい ✅
  ├─ 広告含む: はい ✅
  ├─ インターネット必須: はい ✅
  └─ Game Center: いいえ ✅

□ ビルド
  ├─ バージョン: 1.0.0+1 ✅
  ├─ Xcode: 15.0+ でビルド ✅
  ├─ iOS最小: 14.0 ✅
  └─ TestFlight で全テスト完了 ✅

□ プライバシー
  ├─ Privacy Policy URL: 有効 ✅
  ├─ Support Email: 有効 ✅
  └─ Data Practices: 入力済み ✅

□ リリース計画
  ├─ 自動リリース: いいえ (手動で承認) ✅
  └─ Coming Soon: はい (準備中の表示) ✅
```

### 提出ボタンを押す

```
App Store Connect
  → ぬりパズ動物園
  → バージョン 1.0.0
  → 画面右上「提出する」
```

**承認確認画面**:
```
Apple 開発者ガイドラインを読了したか: ✅
内容の正確性を確認したか: ✅
```

**提出完了**

```
✅ 申請成功
   状態: Waiting for Review
   審査予想時間: 24-48時間 (通常)
```

---

## Step 4: 審査状況監視 (毎日確認)

### Apple 審査の進み方

```
1. Waiting for Review (提出直後)
   └─ 審査キューに追加されるのを待機 (数時間～1日)

2. In Review (審査中)
   └─ Apple チームが実装をレビュー (12-48時間)
   └─ チェック項目:
      • ガイドライン違反なし
      • クラッシュなし
      • プライバシー適切
      • 広告実装適切
      • 課金実装適切

3. Rejected (稀: 否認)
   └─ 理由が通知される
   └─ 修正 → 再提出

4. Approved (承認!)
   └─ 公開準備完了
   └─ Coming Soon は自動開始
```

### 審査状況の確認方法

```bash
# 毎日確認
# App Store Connect
#   → ぬりパズ動物園
#   → バージョン 1.0.0
#   → 画面上部の「状態」欄
```

**Rejected の場合の対応**

```
例: "Guideline 2.1 - Performance"
    理由: クラッシュが検出された

→ 対応:
  1. Xcode でクラッシュを再現
  2. Crashlytics のログを確認
  3. ホットフィックスをビルド
  4. App Store Connect へ新ビルドをアップロード
  5. 再度「提出する」
```

### 審査期間の活動

**審査中にできること**:

```
✅ できる:
  • Coming Soon ページのカスタマイズ
  • マーケティング資料の追加編集
  • 日本国内でのマーケティング開始
  • メディア対応・プレスリリース準備

❌ できない:
  • 審査中の機能変更
  • バージョン番号の変更
  • 新しいビルドのアップロード (再提出の場合を除く)
```

---

## Step 5: 「Coming Soon」設定と公開準備 (1日)

### Coming Soon ページの有効化

```
App Store Connect
  → ぬりパズ動物園 
  → Pricing and Availability
    → Version Release Date
```

**リリース方法の選択**:

```
☑️ Automatic Release
   → 承認後、自動でリリース
   推奨: このオプションを選ぶ (すぐに公開したいため)

☐ Manual Release
   → 承認後、手動でリリース日時指定
   推奨: 後でマーケティング施策に合わせて公開したい場合
```

### Coming Soon バナーのカスタマイズ

```
App Store
  → ぬりパズ動物園
  → Coming Soon
    ├─ アプリアイコン: ✅ (自動表示)
    ├─ プレビュー動画: 設定可能
    ├─ スクリーンショット: 6枚 (既入力)
    ├─ 説明文: 編集可能
    ├─ リリース予定日: 「まもなく」か「日付」を指定
    └─ 事前登録ボタン: 有効化

推奨設定:
  • リリース予定日: 「まもなく利用可能」
  • 事前登録を許可: はい
```

### マーケティング素材の確認

```
Coming Soon ページに表示される項目:

✅ アプリアイコン
   └─ 1024×1024px (自動)

✅ タイトル: ぬりパズ動物園
   └─ 30文字以内

✅ サブタイトル: 宝石パズル × 動物育成
   └─ 30文字以内

✅ スクリーンショット: 6枚
   └─ 1170×2532px

✅ 説明文
   └─ 4,000文字以内

✅ プレビュー動画 (オプション)
   └─ 15-30秒
   └─ H.264 codec, MP4 format
```

### 配信地域の確認

```
Pricing and Availability
  → Available in
    ├─ Japan: ✅ (必須)
    ├─ United States: ✅ (推奨)
    ├─ その他グローバル: ✅ (将来的に)
```

---

## 🚨 よくあるリジェクト理由と対応

### リジェクト 1: クラッシュが報告された

```
理由: Your app crashed on launch on iOS 14.0

対応:
  1. iOS 14.0 のシミュレーターで再現
  2. Xcode で デバッグ
  3. Crashlytics ログを確認
  4. ホットフィックス をビルド
  5. 新ビルドを App Store Connect にアップロード
  6. 再度申請
```

### リジェクト 2: プライバシーポリシーが不適切

```
理由: Privacy Policy does not explain data collection

対応:
  1. https://yourwish.dev/privacy/ja を更新
  2. 収集データを明記:
     - Firebase ユーザーID
     - ゲーム進捗
     - Analytics イベント
     - 広告ID
  3. 使用目的を明記:
     - アプリ機能
     - 分析
     - 広告配信
  4. 第三者 (Google, RevenueCat など) との共有を明記
  5. ユーザーがデータ削除をリクエストできる方法を記載
  6. 再度申請
```

### リジェクト 3: 広告実装が不適切

```
理由: Ads are too intrusive or placed incorrectly

対応:
  1. AdMob 設定を確認:
     - バナー広告は画面下部のみ
     - リワード広告は ユーザーの明示的な操作後
     - インタースティシャルは 画面遷移時のみ
  2. 広告とコンテンツの混在を解消
  3. AdMob ポリシーを再確認
  4. テストで広告表示をチェック
  5. ビルド更新 → 再度申請
```

### リジェクト 4: 課金実装が不適切

```
理由: In-app purchase does not follow guidelines

対応:
  1. RevenueCat 実装を確認:
     - 無料体験は明記されているか
     - キャンセル方法が簡単か
     - 購入確認が明示的か
  2. App Store guideline 3.1.1 を確認:
     - 3.1.1 "Subscriptions must offer a Free Trial"
       → 最初の課金は無料体験を提供推奨
  3. 修正 → ビルド更新 → 再度申請
```

### リジェクト 5: ビルド情報が不完全

```
理由: Missing or incomplete app information

対応:
  1. App Store Connect で全項目を確認:
     - App Name ✅
     - Subtitle ✅
     - Description ✅
     - Category ✅
     - Privacy Policy ✅
     - Support Email ✅
  2. スクリーンショット 6枚確認
  3. Content Rating 再確認
  4. 再度申請
```

---

## ✅ Phase 9D 完了チェックリスト

### 申請前

```
□ TestFlight での最終テスト完了
□ KPI ゲート: Crash-Free ≥99.5% ✅
□ KPI ゲート: Aha Moment ≥60% ✅
□ クリティカルバグなし
□ バージョン: 1.0.0+1 確認
□ iOS 14.0+ で動作確認
```

### App Store Connect 入力

```
□ アプリ名: ぬりパズ動物園
□ サブタイトル: 宝石パズル × 動物育成
□ 説明文: 4,000文字以内
□ キーワード: puzzle, animal, relaxing, casual
□ Primary Category: Games
□ Secondary Category: Casual
□ Content Rating: 4+
□ スクリーンショット: 6枚
□ Privacy Policy URL: 有効
□ Support Email: 有効
□ In-App Purchases: はい
□ 広告含む: はい
□ Coming Soon: 有効化
```

### 申請・監視

```
□ 審査申請完了 (Waiting for Review)
□ 毎日審査状況を確認
□ リジェクトの場合は対応
□ Approved 状態を確認
```

### リリース準備

```
□ Coming Soon ページが表示されている
□ スクリーンショット・説明が正しい
□ マーケティング素材準備完了
□ ソーシャルメディア投稿準備
□ プレスリリース準備
□ ユーザーサポート体制準備
```

---

## 📊 Phase 9D タイムライン

```
Day 1 (半日)
  → ビルド最終確認
  → App Store Connect 情報入力
  → 審査申請

Day 1-2
  → 「Waiting for Review」状態確認

Day 2-3
  → Apple による審査実施 (「In Review」)
  → 審査状況を監視

Day 3-4
  → 承認 (「Approved」) 待機

Day 4
  → Coming Soon バナーが App Store に表示
  → 自動リリースまたは手動リリース予約

Day 5+
  → アプリ公開 🎉
  → ユーザーダウンロード開始
```

---

## 📞 Key Links

- **App Store Connect**: https://appstoreconnect.apple.com/
- **App Store Guideline**: https://developer.apple.com/app-store/review/guidelines/
- **Privacy Policy Template**: https://yourwish.dev/privacy/ja
- **Support**: support@yourwish.dev

---

## 🚀 Phase 9D 完了時の状態

```
✅ App Store で「Coming Soon」表示
✅ Apple 審査承認済み
✅ 日本・米国での配信確認
✅ マーケティング素材確認完了
✅ ユーザーサポート体制準備完了

→ 次フェーズ (Phase 9E Google Play) へ
→ または自動リリース → 公開
```

---

**Version**: 1.0  
**Phase**: 9D App Store Review Submission  
**Duration**: 3-5 business days (審査含)
