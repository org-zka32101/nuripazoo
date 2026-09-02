# Phase 9: TestFlight・ストア出申請 - リリース準備最終段階

## 概要

Phase 8 のアセット統合を経て、いよいよ**本格リリース準備**。TestFlight 外部テスト → Day1 クラッシュフリー 99.5%+ と Aha到達率 60%+ 検証 → App Store・Google Play 審査申請 の3ステップで、ぬりパズ動物園を世界に配信する。

---

## Phase 9 の構成

- **9A**: TestFlight 外部テスト環境構築 (Apple Testflight)
- **9B**: Firebase・RevenueCat 本番環境設定
- **9C**: Pre-launch 検証フロー（KPI 計測・ゲート）
- **9D**: App Store 審査申請・チェックリスト
- **9E**: Google Play 審査申請・チェックリスト
- **9F**: ライブオペレーション準備（月次運用）

---

## Phase 9A: TestFlight 外部テスト環境構築

### 前提条件

```yaml
必要なアカウント・設定:
  - Apple Developer Account (有料: $99/年)
  - Xcode + Apple Command Line Tools
  - 本番 Firebase Project (既構築済)
  - 本番 RevenueCat API キー
  - 広告 SDK API キー
  - App Store Connect アクセス権
```

### ステップ 1: iOS ビルド準備

#### 1.1 証明書・プロビジョニング・プロファイル生成

```bash
# Apple Developer Portal で以下を作成:

1. 証明書 (Certificate)
   □ iOS Distribution (App Store and Ad Hoc)
   □ 秘密鍵をダウンロード・ローカルに保存

2. Identifier (App ID)
   □ Bundle ID: com.yourwish.nuripazu
   □ Capabilities:
     - Push Notifications
     - In-App Purchase
     - Game Kit
     - CloudKit
     - Sign in with Apple (optional)

3. Device Registration
   □ テスト用デバイス UDID 10台以上登録

4. Provisioning Profile (Distribution)
   □ 証明書 + Bundle ID の組み合わせで生成
   □ Xcode に統合
```

#### 1.2 Xcode 設定

```bash
# プロジェクト設定
cd ios/

# 1. Signing & Capabilities
Xcode > Project > Signing & Capabilities:
  - Team: (Apple Developer Account)
  - Bundle Identifier: com.yourwish.nuripazu
  - Version: 0.1.0
  - Build: 1
  
# 2. Capabilities 有効化
  ✅ Push Notifications
  ✅ In-App Purchase
  ✅ Sign in with Apple

# 3. Info.plist 設定
```

#### 1.3 本番環境設定

```bash
# lib/config/firebase_config.dart (本番 Firebase)
const String firebaseProjectId = 'nuripazu-prod';
const String firebaseWebApiKey = '${FIREBASE_WEB_API_KEY_PROD}';

# lib/config/revenue_cat_config.dart (本番 RevenueCat)
const String revenueCatApiKey = '${REVENUE_CAT_API_KEY_PROD}';

# lib/config/ads_config.dart (本番 Google Mobile Ads)
const String adMobAppId = '${ADMOB_APP_ID_PROD}';
const String adMobBannerId = '${ADMOB_BANNER_ID_PROD}';
```

### ステップ 2: TestFlight ビルド

```bash
# iOS ビルド（Release モード）
flutter build ios --release --no-codesign

# Xcode でコード署名を追加してアーカイブ
# または xcodebuild で自動化:
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_build \
  -allowProvisioningUpdates \
  archive -archivePath build/ios_build/Runner.xcarchive

# .ipa を生成
xcodebuild -exportArchive \
  -archivePath build/ios_build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios_build/ipa
```

### ステップ 3: App Store Connect 設定

```bash
# App Store Connect (https://appstoreconnect.apple.com)

1. TestFlight タブ → Internal Testing
   □ Internal テスター 登録（開発チーム）
   □ ビルドアップロード (.ipa)
   □ テスト内容・フィードバック方法を明記

2. External Testing (外部テスター)
   □ 外部テスター グループ作成
   □ テスター招待（メール・リンク配布）
   □ テスト期間設定（デフォルト: 90日）
   □ リリースノート作成

3. ビルド情報
   □ 最小 iOS バージョン: 14.0+
   □ デバイス互換性確認
   □ Build Number: 自動インクリメント

# Sample Release Notes:
---
🎉 ぬりパズ動物園 v0.1.0 TestFlight Beta

このテストビルドで確認してください:

✨ 新機能
- パズル → 動物育成の完全フロー
- なつき度 Lv1-4 システム
- 群れボーナス演出

🔧 設定
- サウンド・アニメーション設定
- ダークモード対応

📊 ご協力ください
- クラッシュ報告（詳細・再現手順）
- パフォーマンス・動作確認
- UI/UX フィードバック

フィードバック連絡先: support@yourwish.dev
---
```

---

## Phase 9B: 本番環境設定

### Firebase 本番設定

```dart
// lib/services/firebase_service.dart

class FirebaseService {
  static Future<void> initialize() async {
    // 本番環境の Firebase 初期化
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY_PROD'),
        appId: String.fromEnvironment('FIREBASE_APP_ID_PROD'),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID_PROD'),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID_PROD'),
      ),
    );

    // Crashlytics 有効化
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Analytics 有効化
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
}
```

### RevenueCat 本番設定

```dart
// lib/services/revenue_cat_service.dart

class RevenueCatService {
  static Future<void> initialize() async {
    await Purchases.configure(
      PurchasesConfiguration(
        String.fromEnvironment('REVENUE_CAT_API_KEY_PROD'),
      )..appUserID = user.id, // User ID 設定
    );

    // 購読状態リスナー
    Purchases.addCustomerInfoUpdateListener(
      (CustomerInfo customerInfo) {
        updateUserSubscriptionStatus(customerInfo);
      },
    );
  }
}
```

### Google Mobile Ads 本番設定

```dart
// lib/services/ads_service.dart

class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize(
      requestConfiguration: const RequestConfiguration(
        // 本番環境は実広告を配信
        // テスト時は testDeviceIds に含める
        testDeviceIds: [],
      ),
    );
  }
}
```

---

## Phase 9C: Pre-launch 検証フロー

### ゲートクライテリア（必須）

TestFlight テスト期間中に以下を満たす必要がある:

#### 1. Crash-Free Rate ≥ 99.5%

```bash
Firebase Crashlytics で計測:
- Day1 crash-free rate: 100%
- Day7 crash-free rate: 99.5%+
- Day30 crash-free rate: 99.5%+

❌ 未達成: TestFlight 継続テスト
✅ 達成: 次ステップへ
```

**計測方法:**
```dart
// Firebase Crashlytics ダッシュボード
// Analytics → Crashlytics → Crash-free Users

// または REST API で自動取得:
GET https://firebaseremoteconfig.googleapis.com/v1/projects/{projectId}/crashlytics/
```

#### 2. Aha Moment 到達率 ≥ 60%

```bash
Firebase Analytics で計測:
- Aha Event: 'aha_moment_reached'
- DAU に占める割合: 60%+

計測:
  イベント数 / DAU ≥ 0.6

❌ 未達成: ゲーム仕様見直し・調整
✅ 達成: 次ステップへ
```

**計測クエリ:**
```sql
-- Firebase Analytics BigQuery
SELECT
  DATE(event_timestamp) as date,
  COUNT(DISTINCT user_id) as dau,
  COUNTIF(event_name = 'aha_moment_reached') as aha_count,
  COUNTIF(event_name = 'aha_moment_reached') / COUNT(DISTINCT user_id) as aha_rate
FROM `project_id.analytics_events`
WHERE event_date BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) AND CURRENT_DATE()
GROUP BY date
ORDER BY date DESC;
```

#### 3. 安定性チェック

```markdown
## Stability Verification Checklist

### Core Flows
- [ ] パズル → 完成フロー（エラーなし）
- [ ] 動物アクション → リアクション演出（スムーズ）
- [ ] なつき度昇降 → 音声・アニメーション（正常）
- [ ] 群れボーナス演出 → 表示・音声（正常）
- [ ] Lv4 特別ポーズ → 固定表示（正常）

### Settings & Lifecycle
- [ ] オン/オフ（再起動時も保持）
- [ ] バックグラウンド → フォアグラウンド復帰（クラッシュなし）
- [ ] 縦・横回転（レイアウト維持）
- [ ] ダークモード切り替え（正常）

### Performance
- [ ] パズル画面 FPS ≥ 50
- [ ] アニメーション再生 ≥ 30fps
- [ ] メモリ使用量 < 200MB（通常状態）
- [ ] バッテリー消費 < 5%/hour

### Offline
- [ ] パズル・図鑑・交流（オフラインOK）
- [ ] オンライン機能（オンライン時のみ）

### Permissions
- [ ] ハプティクス権限（許可・拒否両方で動作）
- [ ] バッテリー最適化（両方で動作）
```

### ゲート判定フロー

```
Phase 9C START
    ↓
[Firebase データ収集] (7-14日)
    ↓
Crash-Free Rate Check
    ├─ ✅ ≥ 99.5% → Next
    └─ ❌ < 99.5% → Debug → Retest
    ↓
Aha Moment Rate Check
    ├─ ✅ ≥ 60% → Next
    └─ ❌ < 60% → Design Review → Adjustment → Retest
    ↓
Manual Stability Verification
    ├─ ✅ All Pass → Next
    └─ ❌ Issues Found → Fix → Retest
    ↓
[Go/No-Go Decision]
    ├─ ✅ GO → Phase 9D (App Store)
    └─ ❌ NO-GO → Extend TestFlight
```

---

## Phase 9D: App Store 審査申請

### 準備チェックリスト

```markdown
## App Store Submission Checklist

### ビルド・バージョン
- [ ] Version: 1.0.0
- [ ] Build: 1
- [ ] iOS Minimum: 14.0+
- [ ] Xcode: 15.0+
- [ ] Swift: 5.9+

### 説明・スクリーンショット
- [ ] アプリ名: ぬりパズ動物園
- [ ] サブタイトル: 「宝石パズル × 動物育成」
- [ ] 説明文: 500文字以内
- [ ] キーワード: puzzle, animal, relaxing (最大100文字)
- [ ] スクリーンショット: 6枚
  - パズル画面
  - 完成演出
  - 動物育成画面
  - 群れボーナス
  - 図鑑
  - 設定画面

### カテゴリ・評価
- [ ] Primary Category: Games
- [ ] Secondary Category: Casual
- [ ] Content Rating: 4+
  - 暴力: None
  - 成人コンテンツ: None
  - ギャンブル: None (広告のみ)

### 価格・配布
- [ ] Price: Free (with ads)
- [ ] Availability: Worldwide
- [ ] License Agreement: Standard

### アプリ情報
- [ ] Support URL: https://yourwish.dev/support
- [ ] Privacy Policy: https://yourwish.dev/privacy
- [ ] Support Email: support@yourwish.dev

### 機能情報
- [ ] Sign in with Apple: (該当時のみ)
- [ ] 広告含む: ✅
- [ ] In-App Purchase: ✅
- [ ] Requires internet: ✅ (一部機能)
- [ ] Healthcare data: ❌
- [ ] Fin data: ❌

### 法務・コンテンツ
- [ ] 3rd party logos: None
- [ ] 実実名声優: None
- [ ] データセーフティ: ✅ 完成
- [ ] 子向けアプリ: ❌

### 設定
- [ ] Enable Sandbox Testing: ✅
- [ ] Requires HLS Streaming: ❌
- [ ] System frameworks: ✅
```

### App Store Connect 提出手順

```bash
# ステップ 1: App Store Connect ログイン
# https://appstoreconnect.apple.com

# ステップ 2: My Apps → 新規アプリ or 既存アプリ

# ステップ 3: アプリ情報入力
App Store Connect:
  1. アプリ名・サブタイトル
  2. プライマリ言語: 日本語
  3. バンドル ID: com.yourwish.nuripazu
  4. SKU: nuripazu-2024

# ステップ 4: スクリーンショット・説明
App Store:
  1. ローカライズ: 日本語 / English (optional)
  2. スクリーンショット: 6枚 (iPhone 6.7" → 1242×2688px)
  3. プレビュー動画: (optional)
  4. 説明・キーワード・サポート URL

# ステップ 5: ビルド選択
TestFlight:
  1. Build を選択（最新）
  2. 内容レーティング: 質問に回答
  3. Export Compliance: ❌ (暗号なし)

# ステップ 6: 審査情報
審査情報:
  1. 1st Contact: 日本語 / English
  2. Demo Account: (必要なら)
  3. Demo User Credentials: (ログイン必須なら)
  4. Notes for Reviewer:
     - Gameplay: Tap puzzle pieces → Complete shape → Pet animal
     - Affection level: 1-4 (daily interaction)
     - Offline: Puzzle & pet interactions work offline
     - Ads: Opt-in (banner ads, rewarded)
     - IAP: Cosmetics only, core features free

# ステップ 7: 提出
  □ 同意: Developer Agreement
  □ チェック: Content Rights
  □ 提出ボタン: Submit for Review
```

### 審査結果対応

```markdown
## App Store Review Response Guide

### 🟢 In Review (1-3 days)
- 何もしない（待機）
- Slack/Email で通知受け取り

### 🟢 Ready for Sale
- アプリ公開
- Day1 metrics 監視開始
- Crash monitoring 継続

### 🟡 Rejected (一般的理由)

#### "Requires sign-in without offline mode"
❌ 不可: ログイン必須・オフライン非対応
✅ 修正: パズル・交流画面はオフラインOK

#### "Misleading app behavior"
❌ 不可: スクショと異なる動作
✅ 修正: スクショ・説明と実装の整合性確認

#### "Bug / Performance issues"
❌ 不可: クラッシュ・フリーズ検出
✅ 修正: Crashlytics 確認・デバッグ

#### "Inappropriate content"
❌ 不可: Rated M content / Gambling
✅ 修正: コンテンツレーティング見直し・削除

### 🔴 Metadata Rejection (軽微)
- アイコン・スクショ修正
- 説明文修正
- 24時間以内に再提出

### 対応時間
- Rejection 受け取り → 48時間以内に対応開始
- 修正 → 24-48時間で再提出
- 再審査 → 通常 1-2日
```

---

## Phase 9E: Google Play 審査申請

### 準備チェックリスト

```markdown
## Google Play Submission Checklist

### ビルド・APK
- [ ] Version Code: 1
- [ ] Version Name: 1.0.0
- [ ] Android SDK: Min 21, Target 34+
- [ ] App Signing: Play App Signing で管理
- [ ] APK Bundle (.aab): 生成完了

### アプリ情報
- [ ] アプリ名: ぬりパズ動物園
- [ ] 短説明: 50文字以内
- [ ] フル説明: 4000文字以内
- [ ] スクリーンショット: 8枚
  - 16:9 (440×810px)
  - フィーチャーグラフィック (1024×500px)

### カテゴリ・評価
- [ ] Application Type: Game
- [ ] Category: Casual
- [ ] Content Rating: 3+（IARC）
  - Submitted form: PEGI / GRAC / CLASSIND

### 価格・配布
- [ ] Price: Free (with ads)
- [ ] Countries: Worldwide
- [ ] Targeting: All devices

### プライバシー・セキュリティ
- [ ] Privacy Policy URL: ✅
- [ ] Data Safety: ✅
  - データ収集: Analytics, Ads
  - データ共有: Google Firebase, RevenueCat
  - セキュアな転送: ✅ HTTPS

### 広告・課金
- [ ] Ads SDK: Google Mobile Ads (認証済)
- [ ] IAP: RevenueCat (認証済)
- [ ] IAP テスト: Google Play テスター登録で確認
```

### Google Play Console 提出手順

```bash
# ステップ 1: Google Play Console ログイン
# https://play.google.com/console

# ステップ 2: 新規アプリ作成
  1. アプリ名: ぬりパズ動物園
  2. デフォルト言語: 日本語
  3. アプリケーション: Games
  4. 同意: チェック

# ステップ 3: アプリ ID 設定
  1. Package Name: com.yourwish.nuripazu
  2. Signing Key: Google Play App Signing で生成・管理

# ステップ 4: ストア掲載情報
  1. タイトル / 短説明
  2. フル説明 / スクショ
  3. フィーチャーグラフィック
  4. カテゴリ / コンテンツレーティング
  5. ウェブサイト / メールアドレス
  6. プライバシーポリシー

# ステップ 5: IARC コンテンツレーティング
  - Questionnaire 入力（5分）
  - Rating: Generic 3+ (typical casual game)
  - Certificates 受け取り

# ステップ 6: APK/AAB アップロード
Release Channels:
  1. Internal Testing → アップロード確認
  2. Closed Testing → Beta テスター招待
  3. Open Testing → オープンベータ（任意）
  4. Production → 本公開

# ステップ 7: 本公開準備
  1. Release タブ → Create new release
  2. AAB (.aab) ファイル選択
  3. Release Notes 入力
  4. Content Rating 確認
  5. Review Guidelines 同意
  6. 公開ボタン: "Send to Review"

# Sample Release Notes (Google Play)
---
🎉 ぬりパズ動物園 v1.0.0

宝石パズルを完成させて、かわいい動物を育てよう！

✨ 機能
- パズル完成で新しい動物がゲット
- 毎日交流してなつき度をアップ (Lv1-4)
- 3体揃えて群れボーナス獲得
- Lv4 到達で特別ポーズが解放

🎮 ゲームプレイ
- タップ操作で直感的
- オフラインでもプレイ可能
- ダークモード対応
- ハプティクスフィードバック

📊 KPI
- Day1 ユーザー保持: 18%
- Aha 到達率: 60%
- 平均セッション: 5分

サポート: support@yourwish.dev
---
```

### Google Play 審査結果対応

```markdown
## Google Play Review Response Guide

### ✅ Approved
- 自動公開（即時またはスケジュール）
- Day1 analytics 監視開始
- Crash monitoring 継続

### ⚠️ Changes Requested

#### "App permissions overuse"
❌: 不要な permissions 要求
✅: 必要最小限の permissions に削減
  - INTERNET (ネットワーク)
  - ACCESS_NETWORK_STATE
  - 不要: CONTACTS, LOCATION, CAMERA

#### "Privacy Policy missing / incomplete"
❌: URL invalid or Privacy Policy 無し
✅: 完全な Privacy Policy 作成・公開
  - データ収集: Firebase Analytics, Ads
  - データ共有: RevenueCat, Google

#### "Misleading app metadata"
❌: スクショ・説明と機能が異なる
✅: 整合性確認・修正

### 再審査期間
- Requested Changes 受け取り → 48時間で対応
- 修正反映 → 24-72時間で再審査完了

### リリース時期
- 月曜-木曜に公開推奨（金曜は週末対応）
- App Store 時差考慮: PST 9:00-11:00 AM
- Google Play 公開: UTC 9:00 AM
```

---

## Phase 9F: ライブオペレーション準備

### 月次運用スケジュール

```markdown
## Monthly Operation Cycle

### Week 1-2: Content Creation
- [ ] 新動物 2-3 種デザイン（petit_ai or 手作業）
- [ ] Lottie アニメーション生成
- [ ] 動物音声・SE 生成
- [ ] QA テスト・クラッシュ検証

### Week 3: Soft Launch
- [ ] Firebase Remote Config 設定更新
- [ ] 新動物データ Firestore 投入
- [ ] Beta テスター向けにロールアウト
- [ ] Metrics 監視（Aha 到達率・クラッシュ率）

### Week 4: Ramp-up & Monitoring
- [ ] 100% ロールアウト
- [ ] Day1/Day7/Day30 Retention 監視
- [ ] Crash-Free Rate ≥ 99.5% 確認
- [ ] 次月準備開始

### Continuous Monitoring
- Daily: Crash reports, Active users
- Weekly: Retention, Aha rate
- Monthly: Revenue, Churn, NPS
```

### KPI ダッシュボード

```bash
# Firebase Analytics + BigQuery

## Daily Metrics

SELECT
  DATE(event_timestamp) as date,
  COUNT(DISTINCT user_id) as dau,
  COUNT(DISTINCT session_id) as sessions,
  SUM(CASE WHEN event_name = 'aha_moment_reached' THEN 1 ELSE 0 END) as aha_count,
  SUM(CASE WHEN event_name = 'aha_moment_reached' THEN 1 ELSE 0 END) / COUNT(DISTINCT user_id) as aha_rate
FROM `project_id.analytics_events`
WHERE DATE(event_timestamp) = CURRENT_DATE()
GROUP BY date;

## Retention (D1, D7, D30)

WITH first_seen AS (
  SELECT
    user_id,
    MIN(DATE(event_timestamp)) as first_date
  FROM `project_id.analytics_events`
  GROUP BY user_id
),
active_dates AS (
  SELECT
    user_id,
    DATE(event_timestamp) as active_date
  FROM `project_id.analytics_events`
  GROUP BY user_id, DATE(event_timestamp)
)
SELECT
  COUNT(DISTINCT f.user_id) as new_users,
  COUNT(DISTINCT CASE WHEN DATEDIFF(a.active_date, f.first_date) <= 1 THEN f.user_id END) as d1_active,
  COUNT(DISTINCT CASE WHEN DATEDIFF(a.active_date, f.first_date) <= 7 THEN f.user_id END) as d7_active,
  COUNT(DISTINCT CASE WHEN DATEDIFF(a.active_date, f.first_date) <= 30 THEN f.user_id END) as d30_active
FROM first_seen f
LEFT JOIN active_dates a ON f.user_id = a.user_id
WHERE f.first_date = CURRENT_DATE() - 30;
```

### トラブルシューティング対応体制

```markdown
## Incident Response SLA

### 🔴 Critical (Crash-Free < 95%)
- Detection → Alert (リアルタイム)
- Investigation → 30 min
- Hotfix Release → 4 hours
- Communication: Emergency Slack alert

### 🟡 Major (Feature broken)
- Detection → Alert (1 hour)
- Investigation → 2 hours
- Fix Release → 24 hours
- Communication: User notification in-app

### 🟢 Minor (UI bug / Performance)
- Detection → Logged
- Investigation → Next sprint
- Fix Release → Next version
- Communication: Release notes
```

---

## Pre-Launch Final Checklist

```markdown
## 🚀 GO/NO-GO Decision Criteria

### Requirements ✅
- [ ] Phase 1-8 完全実装
- [ ] Crash-Free Rate ≥ 99.5% (7日間)
- [ ] Aha 到達率 ≥ 60%
- [ ] Manual QA: All critical flows pass
- [ ] Localization: 日本語 完全
- [ ] Privacy Policy・Terms: 公開
- [ ] Support email: 監視体制構築

### Nice-to-Have 🎁
- [ ] English localization (optional)
- [ ] Open Testing beta (Google Play)
- [ ] Day1 user retention target: 18%+
- [ ] Content roadmap: Next 6 months

### Risk Mitigation 🛡️
- [ ] Hotfix branch: 本番対応可能
- [ ] Monitoring dashboards: リアルタイム
- [ ] Communication plan: Slack/Email
- [ ] Rollback procedure: 5 min以内

### Go Decision: ✅ All critical ✅ → Launch
### No-Go Decision: ❌ Any critical ❌ → Extend TestFlight
```

---

## リリース後ロードマップ（3-12ヶ月）

### Month 1-2: Soft Launch & Stabilization
- 日本リージョン限定
- Day1 クラッシュフリー 99.5%+ 維持
- 新動物 2-3種/月 追加
- ユーザーフィードバック収集

### Month 3-6: Regional Expansion
- English localization 実装
- 北米・欧州 ローンチ
- 季節限定動物 導入
- マルチプレイ・ランキング検討

### Month 6-12: Monetization Optimization
- IAP 商品ポートフォリオ拡充
- AdMob 広告最適化
- RevenueCat subscription tier 追加
- LiveOps イベント定期開催

---

## 📞 サポート・運用体制

```markdown
## Support Channels

### User Support
- Email: support@yourwish.dev (24h以内返信)
- In-App Help: Settings → Help & Support
- FAQ: https://yourwish.dev/support/faq

### Bug Reports
- Report form: In-App → Report Bug
- Crash logs: Firebase Crashlytics 自動送信
- Performance: Analytics 自動計測

### Community
- Twitter/X: @nuripazu_game (announcements)
- Discord: Community server (optional)
- Newsletter: Monthly updates
```

---

## ✨ チェックリスト (Phase 9)

- [ ] Phase 9A: TestFlight 環境構築
- [ ] Phase 9B: 本番環境設定
- [ ] Phase 9C: Pre-launch 検証（KPI ゲート）
- [ ] Phase 9D: App Store 審査申請
- [ ] Phase 9E: Google Play 審査申請
- [ ] Phase 9F: ライブオペレーション準備

---

🚀 **Ready for Global Release** - ぬりパズ動物園、世界へ出航！

---

Generated by [Claude Code](https://claude.ai/code)
