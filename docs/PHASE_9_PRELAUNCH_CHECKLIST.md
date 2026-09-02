# Phase 9: リリース前最終チェックリスト

## 🎯 Go/No-Go ゲート判定フロー

```
Phase 9 START
    │
    ├─ [9A] TestFlight 環境構築
    │   ├─ iOS 証明書・プロビジョニング: ✅/❌
    │   ├─ Xcode 設定完了: ✅/❌
    │   ├─ ビルド生成・アップロード: ✅/❌
    │   └─ Internal Testers 登録: ✅/❌
    │
    ├─ [9B] 本番環境設定
    │   ├─ Firebase 本番 Project: ✅/❌
    │   ├─ RevenueCat 本番 Key: ✅/❌
    │   ├─ Google Mobile Ads: ✅/❌
    │   └─ Environment 変数確認: ✅/❌
    │
    ├─ [9C] Pre-launch 検証 (7-14日)
    │   ├─ Crash-Free Rate ≥ 99.5%: ✅/❌
    │   ├─ Aha Moment 到達率 ≥ 60%: ✅/❌
    │   ├─ Manual QA (全フロー): ✅/❌
    │   └─ パフォーマンス確認: ✅/❌
    │
    ├─ [GO-NO-GO DECISION]
    │   ├─ ✅ GO → Phase 9D
    │   └─ ❌ NO-GO → Extend TestFlight
    │
    └─ [9D/9E] Store Submission
        ├─ App Store 申請: ✅/❌
        └─ Google Play 申請: ✅/❌
```

---

## ✅ チェックリスト詳細

### Phase 9A: TestFlight 環境構築

#### iOS Signing & Provisioning
- [ ] Apple Developer Account アクティブ (年会費 $99)
- [ ] iOS Distribution Certificate 作成・インストール
- [ ] Provisioning Profile (Distribution) 作成・Xcode 登録
- [ ] Bundle Identifier: `com.yourwish.nuripazu` 登録
- [ ] App ID (Bundle ID) Apple Developer Portal で登録
- [ ] Capabilities 有効化:
  - [ ] Push Notifications
  - [ ] In-App Purchase
  - [ ] Sign in with Apple (optional)

#### Xcode 設定
- [ ] Project Settings → Signing & Capabilities
  - [ ] Team: 正しい Developer Account
  - [ ] Bundle ID: `com.yourwish.nuripazu`
  - [ ] Version: `1.0.0`
  - [ ] Build: `1`
- [ ] Deployment Target: iOS 14.0+
- [ ] Info.plist 設定確認
  - [ ] Privacy descriptions (Microphone, Bluetooth - if needed)
  - [ ] NSPhotoLibraryUsageDescription (if needed)

#### ビルド生成
- [ ] `flutter clean` → 古いビルド削除
- [ ] `flutter pub get` → 依存関係確認
- [ ] `flutter build ios --release` → Release ビルド
- [ ] Xcode でコード署名追加:
  ```bash
  xcodebuild -workspace ios/Runner.xcworkspace \
    -scheme Runner -configuration Release \
    -derivedDataPath build/ios_build \
    -allowProvisioningUpdates archive \
    -archivePath build/ios_build/Runner.xcarchive
  ```

#### App Store Connect 設定
- [ ] App Store Connect ログイン (https://appstoreconnect.apple.com)
- [ ] TestFlight → Internal Testing
  - [ ] Testers 登録 (開発チーム最低3人)
  - [ ] ビルド (`.ipa`) アップロード
  - [ ] ビルド処理完了待機 (5-15分)
  - [ ] リリースノート作成

#### TestFlight テスト期間
- [ ] 内部テスト: 最低 3日 (開発チーム)
- [ ] 外部テスト準備: テスター 10-50人招待
  - [ ] テスター登録用リンク生成
  - [ ] Slack/Email でテスター招待
  - [ ] テスト期間: 7-14日
  - [ ] Feedback 収集方法: Email, Slack

---

### Phase 9B: 本番環境設定

#### Firebase Configuration
- [ ] Firebase Project (Production) 作成
  - [ ] Project ID: `nuripazu-prod`
  - [ ] Google Cloud Console: Link to Nuripazu-prod
- [ ] Firestore Database (Production)
  - [ ] Collection: `animals`, `users`, `puzzles`
  - [ ] Security Rules: 本番設定
  - [ ] 初期データ投入確認
- [ ] Firebase Authentication
  - [ ] Anonymous Auth 有効化
  - [ ] Google Sign-in 有効化 (optional)
- [ ] Cloud Functions
  - [ ] updateAffectionLevel 関数デプロイ
  - [ ] updateHerdBonus 関数デプロイ
  - [ ] 実行ログ確認
- [ ] Firebase Analytics
  - [ ] Collection 有効化
  - [ ] Custom Events 設定
  - [ ] BigQuery Export 有効化 (optional)
- [ ] Firebase Crashlytics
  - [ ] Collection 有効化
  - [ ] Crash Threshold: 5 crashes
- [ ] Firebase Remote Config
  - [ ] 初期設定ロード
  - [ ] Feature flags 設定

#### RevenueCat Configuration
- [ ] RevenueCat Production Project 作成
  - [ ] Project Name: `Nuripazu Prod`
  - [ ] Default Currency: JPY
- [ ] Apple App Store Product ID 登録
  - [ ] Product ID: `nuripazu_starter_pack` など
  - [ ] Display Name: 日本語
  - [ ] Price: JPY 価格設定
- [ ] Google Play Product ID 登録
  - [ ] SKU: `nuripazu_starter_pack` (Apple と同一)
  - [ ] Display Name: 日本語
  - [ ] Price: JPY 価格設定
- [ ] Entitlements 設定
  - [ ] Offering: 「Initial」など
  - [ ] Packages: Monthly, Annual
- [ ] Test Device 登録
  - [ ] UDIDs: テスト iPhone (3台)
  - [ ] Google Play email: テスター用 Account
- [ ] Secret Key 生成
  - [ ] Production API Key 取得
  - [ ] Firebase Secrets に登録

#### Google Mobile Ads Configuration
- [ ] Google AdMob Account 作成
  - [ ] Account Status: Approved
  - [ ] Payment Method: 登録完了
- [ ] App 登録
  - [ ] Platform: iOS + Android
  - [ ] App ID: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`
- [ ] Ad Units 作成
  - [ ] Banner Ad: `ca-app-pub-...`
  - [ ] Interstitial Ad: `ca-app-pub-...`
  - [ ] Rewarded Ad: `ca-app-pub-...`
- [ ] Ad Units in Code
  - [ ] lib/config/ads_config.dart: 本番 ID に更新
  - [ ] テスト広告は削除（本番環境のため）

#### Environment Variables
- [ ] `.env` or Firebase Secrets に登録:
  ```
  FIREBASE_WEB_API_KEY_PROD=...
  FIREBASE_APP_ID_PROD=...
  FIREBASE_MESSAGING_SENDER_ID_PROD=...
  FIREBASE_PROJECT_ID_PROD=...
  REVENUE_CAT_API_KEY_PROD=...
  ADMOB_APP_ID_PROD=...
  ADMOB_BANNER_ID_PROD=...
  ```
- [ ] GitHub Actions Secrets に登録
- [ ] CI/CD でロード確認

---

### Phase 9C: Pre-launch Validation (7-14 days)

#### Day 1-3: Internal Testing
- [ ] Core Flows
  - [ ] 起動 → ホーム画面: No crash
  - [ ] ホーム → パズル選択: No crash
  - [ ] パズル再生: No errors
  - [ ] パズル完成: Animation smooth, 2-3秒
  - [ ] 完成 → 動物アクション: Dialog 表示, Click responsive
  - [ ] なつき度上昇: Animation + SE + Haptics
  - [ ] Lv4 到達: Special pose animation
  - [ ] 図鑑表示: Loading smooth
  - [ ] 設定画面: Toggle works, Persists
- [ ] Edge Cases
  - [ ] ネットワーク切断 → 復帰: Reconnect smooth
  - [ ] バッテリーセーバー: App works
  - [ ] バックグラウンド → フォアグラウンド: No crash
  - [ ] デバイス回転 (縦↔横): Layout OK
  - [ ] 長時間プレイ: Memory stable

#### Day 4-7: Firebase Metrics Collection
- [ ] Firebase Analytics Dashboard
  - [ ] DAU (Daily Active Users) 記録開始
  - [ ] Events flowing: `aha_moment_reached`, `animal_interacted` etc.
  - [ ] Session duration: 平均 5分以上
- [ ] Crash Monitoring
  - [ ] Firebase Crashlytics Dashboard
  - [ ] Crash-free users: Track
  - [ ] Any crashes: Investigate & fix immediately

#### Day 8-14: External Testing & Validation
- [ ] External Testers (10-50 users)
  - [ ] TestFlight invite 送信
  - [ ] Testers: Feedback 収集
  - [ ] Duration: 7日間テスト実施
- [ ] KPI Gate Checks
  - [ ] Crash-Free Rate: `CRASHFREEUSERS / TOTALUSERS ≥ 0.995`
  - [ ] Aha Moment Rate: `AHA_EVENTS / DAU ≥ 0.60`
  - [ ] Avg Session: `≥ 300 sec (5min)`
  - [ ] D1 Retention: `≥ 18%` (Target)
- [ ] Manual Stability Verification
  - [ ] All flows pass: Core gameplay, edge cases, perms
  - [ ] Performance: FPS ≥ 50, Memory < 200MB, Battery < 5%/hr
  - [ ] UI/UX: Responsive, No dead buttons, Accessibility OK

#### Metrics Query Example
```sql
-- Check Crash-Free Rate (BigQuery)
SELECT
  DATE(event_timestamp) as date,
  COUNT(DISTINCT user_id) as total_users,
  COUNTIF(NOT EXISTS(
    SELECT 1 FROM crashes c 
    WHERE c.user_id = e.user_id 
    AND DATE(c.timestamp) = DATE(e.event_timestamp)
  )) as crash_free_users,
  COUNTIF(NOT EXISTS(
    SELECT 1 FROM crashes c 
    WHERE c.user_id = e.user_id 
    AND DATE(c.timestamp) = DATE(e.event_timestamp)
  )) / COUNT(DISTINCT user_id) as crash_free_rate
FROM `project_id.analytics_events` e
WHERE DATE(event_timestamp) BETWEEN '2026-09-10' AND '2026-09-17'
GROUP BY date
ORDER BY date DESC;
```

---

### Phase 9D: App Store Submission

#### Metadata & Assets
- [ ] App Icon (1024×1024px, no transparency)
- [ ] Screenshot (6枚, 1242×2688px for iPhone 15 Pro Max)
  - [ ] 1. Puzzle screen
  - [ ] 2. Completion animation
  - [ ] 3. Animal detail screen
  - [ ] 4. Herd bonus
  - [ ] 5. Collection (図鑑)
  - [ ] 6. Settings screen
- [ ] Preview Video (optional, 30sec max)
- [ ] Description (500 chars)
- [ ] Subtitle (30 chars)
- [ ] Keywords (100 chars)
- [ ] Support URL
- [ ] Privacy Policy URL
- [ ] Support Email

#### App Store Connect Submission
- [ ] Build selection (latest TestFlight build)
- [ ] Content Rating: Select `4+` (no violence, no adult content)
- [ ] Export Compliance: `No` (no encryption)
- [ ] Review Information:
  - [ ] Demo Account: None needed
  - [ ] Notes for Reviewer:
    ```
    App: Casual puzzle + pet game
    Gameplay: Tap puzzle pieces → Complete shape → Pet animal → Affection level increases
    Offline: Puzzle & pet play work offline
    Online: Analytics, ads, IAP
    Ads: Optional (banner, interstitial, rewarded)
    IAP: Cosmetics only, core gameplay free
    No user accounts required
    ```
- [ ] Licensing Agreement: Accept
- [ ] Automatically release after approval: Select date (or manual)
- [ ] Submit: "Submit for Review"

#### Post-Submission
- [ ] Status tracking: App Store Connect
  - [ ] In Review: 1-3 days
  - [ ] Ready for Sale: Go live
  - [ ] Rejected: Read feedback & fix
- [ ] First release checklist:
  - [ ] Monitors enabled (Crashlytics, Analytics)
  - [ ] Support email active
  - [ ] Social media posts scheduled

---

### Phase 9E: Google Play Submission

#### Metadata & Assets
- [ ] App Icon (512×512px, with safe zone)
- [ ] Playstore Screenshots (8枚, 1080×1920px)
  - [ ] Same 6 as App Store
  - [ ] 2 additional: Feature highlights
- [ ] Feature Graphic (1024×500px, no text overlay)
- [ ] Short Description (80 chars)
- [ ] Full Description (4000 chars)
- [ ] Category: Games > Casual
- [ ] Content Rating
  - [ ] IARC Questionnaire: Fill out
  - [ ] Rating received: Save certificates
- [ ] Privacy Policy URL
- [ ] Support URL / Email
- [ ] Website (optional)

#### Google Play Console Submission
- [ ] Create Release
  - [ ] Upload AAB (.aab) file
  - [ ] Review requirements & rollout %
  - [ ] Release notes (Japanese)
- [ ] Release Info
  - [ ] Version code: 1
  - [ ] Version name: 1.0.0
  - [ ] Release type: Production
- [ ] App Access
  - [ ] Restricted: No
- [ ] Ads & Monetization
  - [ ] Admob App ID: Registered
  - [ ] Policy confirmation: Check
- [ ] Consent & Permissions
  - [ ] Target API Level: 34+
  - [ ] 64-bit: Enabled
  - [ ] Permissions review: Minimal
  - [ ] App signing: Google Play App Signing
- [ ] Review Submission
  - [ ] Content guidelines: Agree
  - [ ] Data safety form: Complete
  - [ ] Send to Review

#### Post-Submission
- [ ] Status tracking: Play Console
  - [ ] In Review: 1-3 days
  - [ ] Published: Go live (often immediate)
  - [ ] Rejected: Read notes & resubmit
- [ ] Version rollout
  - [ ] Start at 5%, monitor crashes
  - [ ] Ramp: 25% → 50% → 100%
  - [ ] Timeline: 1-2 weeks

---

### Phase 9F: ライブオペレーション準備

#### Support & Monitoring Infrastructure
- [ ] Support Email: setup & reply SLA
  - [ ] support@yourwish.dev
  - [ ] SLA: 24 hours
- [ ] Crash Monitoring Dashboards
  - [ ] Firebase Crashlytics: Real-time alerts
  - [ ] Slack integration: #crashes channel
  - [ ] On-call rotation: 24/7
- [ ] Analytics Dashboards
  - [ ] BigQuery: DAU, Aha rate, Retention
  - [ ] Daily reports: Slack bot
  - [ ] Weekly review: Team sync

#### Hotfix Readiness
- [ ] Hotfix branch: `hotfix/v1.0.1`
  - [ ] Build scripts: Automated
  - [ ] Testing: Minimal regression tests
  - [ ] Release: < 4 hours
- [ ] Emergency procedures
  - [ ] Rollback plan: Documented
  - [ ] Communication: Slack + Twitter
  - [ ] Status page: (optional)

#### Content Pipeline
- [ ] Monthly animals: 2-3 新種
  - [ ] Design: petit_ai or manual
  - [ ] Lottie: Animation 5ファイル
  - [ ] Voice: 3ファイル
  - [ ] QA: Full testing cycle
- [ ] Data management
  - [ ] Animal master data: Firestore
  - [ ] Versioning: Release notes
  - [ ] A/B testing: Remote Config

---

## 🎯 GO/NO-GO Decision Matrix

| Criteria | Target | Minimum | Status |
|----------|--------|---------|--------|
| Crash-Free Rate | 99.8% | 99.5% | ✅/❌ |
| Aha Moment Rate | 70% | 60% | ✅/❌ |
| D1 Retention | 20% | 18% | ✅/❌ |
| Avg Session Duration | 6 min | 5 min | ✅/❌ |
| Manual QA | All pass | Critical only | ✅/❌ |
| Performance FPS | 60fps | 50fps | ✅/❌ |
| Memory Usage | <150MB | <200MB | ✅/❌ |
| Support Ready | Yes | Yes | ✅/❌ |

### Decision Rule
```
IF (Crash-Free ≥ 99.5%) AND (Aha Rate ≥ 60%) AND (QA Critical = All Pass):
  → GO ✅ (Launch)
ELSE:
  → NO-GO ❌ (Extend TestFlight)
```

---

## 📱 리콜 및 대응

### Scenario: Crash detected at Day1
```
08:00 - Crashlytics alert: Crash rate 20%
08:05 - Investigate: Rotation bug in animal_detail_screen
08:30 - Fix: Re-run tests locally
09:00 - Build hotfix 1.0.1
10:00 - Submit App Store & Play Console
18:00 - App Store approved & live
24:00 - Play Console approved & live
```

### Scenario: Low Aha rate (45% instead of 60%)
```
Day 7 - Analytics shows: Aha rate = 45%
Action 1: Analyze user flow
  - Puzzle completion: 80% (OK)
  - Animal action trigger: 60% (Issue: UX unclear)
  - Affection increase: 40% (Root cause)

Action 2: Design fix
  - Add tutorial highlight: "Tap to interact"
  - Change animal pos for visibility
  - Add haptic feedback on interaction

Action 3: A/B test via Remote Config
  - 50% users: Original UI
  - 50% users: New UI
  - Measure: Aha rate

Action 4: If improved
  - Rollout to 100%
  - Submit update (1.0.1) to stores
```

---

## ✨ リリース直前チェックリスト (Last 24 Hours)

- [ ] All Phase 9A-9E tasks completed
- [ ] Crash-Free Rate ≥ 99.5%
- [ ] Aha Moment Rate ≥ 60%
- [ ] All manual QA critical flows pass
- [ ] Support email inbox: monitored
- [ ] On-call engineer: assigned
- [ ] Status page: ready (optional)
- [ ] Twitter/社告: scheduled
- [ ] Slack channels: #launches, #crashes, #analytics
- [ ] Monitoring dashboards: open & ready
- [ ] Rollback plan: reviewed
- [ ] Final smoke test: All platforms

---

**🚀 GO → LAUNCH!**

---

Generated by [Claude Code](https://claude.ai/code)
