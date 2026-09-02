# Phase 9B: 本番環境設定 - Production Environment Setup

**概要**: Firebase・RevenueCat・Google Mobile Ads の本番環境統合  
**実装期間**: 1-2 営業日  
**責任者**: バックエンド・インフラ担当  
**ゲート条件**: 本番環境が完全に初期化・設定完了

---

## 前提条件

```yaml
必須の事前準備:
  - Firebase 本番プロジェクト作成済
  - Apple Developer Account (有料: $99/年)
  - Google AdMob アカウント開設済
  - RevenueCat アカウント作成済
  - GitHub Secrets に環境変数登録権限
```

---

## Step 1: Firebase 本番プロジェクト設定

### 1.1 Firebase Project 初期化

**Link**: https://console.firebase.google.com/

```yaml
プロジェクト作成:
  1. "プロジェクトを作成"
  2. プロジェクト名: "nuripazu-prod"
  3. Google Analytics: 有効化
  4. アナリティクス地域: Japan (日本)
```

### 1.2 iOS アプリ登録

```bash
Firebase Console > Project Settings > iOS アプリを追加

1. Bundle ID: com.yourwish.nuripazu
2. App Nickname: "Nuripazu Prod"
3. Download GoogleService-Info.plist
   - lib/config/firebase/ に保存
   - .gitignore に追加してリポジトリから除外

4. Xcode での設定:
   - Xcode > Project > Build Phases > Copy Bundle Resources
   - GoogleService-Info.plist を追加
```

### 1.3 Firestore Database 初期化

```yaml
Firestore セットアップ:
  1. Firebase Console > Firestore Database > データベースを作成
  2. 本番モード で作成 (セキュリティルール適用)
  3. ロケーション: asia-northeast1 (東京)

セキュリティルール設定:
  (詳細は Step 3 参照)
```

### 1.4 Authentication 設定

```yaml
Firebase > Authentication > Sign-in method

有効化するプロバイダー:
  ✅ Anonymous Authentication
     - ゲストユーザー向けオンボード対応
  ✅ Apple (iOS 必須)
     - リスト > Apple ID を追加
     - Team ID を設定
  ✅ Google (オプション)
     - クライアント ID を設定

Email/Password は本番では使用しない
```

### 1.5 Cloud Functions デプロイ

**Purpose**: なつき度・動物データの改ざん対策

```bash
cd /path/to/nuripazoo/functions

# 本番環境へデプロイ
firebase deploy --only functions --project=nuripazu-prod

# デプロイ確認:
firebase functions:list --project=nuripazu-prod
```

**Cloud Functions の実装例** (後続フェーズで詳細):

```dart
// lib/services/affection_service.dart

// Firestore 直接書込を禁止、Cloud Functions 経由に統一
class AffectionService {
  static Future<void> increaseAffection(
    String userId,
    String userAnimalId,
  ) async {
    // Cloud Functions を呼び出し
    await FirebaseFunctions.instance
        .httpsCallable('increaseAffection')
        .call({
          'userId': userId,
          'userAnimalId': userAnimalId,
        });
    
    // Firestore 直接更新は禁止！
    // ❌ cloud_firestore.doc(path).update() はしない
  }
}
```

### 1.6 Firestore セキュリティルール

```javascript
// firestore.rules (本番環境用)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ユーザー認証チェック
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(uid) {
      return request.auth.uid == uid;
    }

    // ユーザーコレクション (本人のみ読み書き)
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // ユーザーの動物コレクション
      match /animals/{animalId} {
        allow read: if isOwner(userId);
        allow write: if false;  // Cloud Functions 経由のみ
      }
    }

    // 公開データ (図鑑など)
    match /animal_masters/{doc=**} {
      allow read: if isAuthenticated();
      allow write: if false;
    }

    // 群れボーナス設定 (管理者のみ)
    match /herd_bonus_config/{doc=**} {
      allow read: if isAuthenticated();
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### 1.7 Firebase Analytics & Crashlytics

```yaml
Firebase Console 設定:

Analytics:
  1. 自動データ収集: 有効
  2. レポート生成: リアルタイム
  3. ユーザー ID 設定: Firebase Auth と統合

Crashlytics:
  1. アプリクラッシュ報告: 自動
  2. エラー通知: メール送信
  3. ダッシュボード: 99.5% 以上を目標
```

---

## Step 2: RevenueCat 本番設定

### 2.1 RevenueCat プロジェクト作成

**Link**: https://app.revenuecat.com/

```yaml
Project Setup:
  1. Dashboard > Create New Project
  2. Project Name: "Nuripazu Production"
  3. Currency: JPY (日本円)
```

### 2.2 Apple App Store との連携

```yaml
RevenueCat > Project > Apple > Integrate

1. Apple ID (Developer Account) を入力
2. App-specific password を生成
   - appleid.apple.com > Security > App-specific passwords
   - ラベル: "RevenueCat Nuripazu Prod"
   - パスワードをコピー

3. RevenueCat に入力:
   - Apple ID: (メールアドレス)
   - App-specific Password: (上記で生成)
   - App Bundle ID: com.yourwish.nuripazu

4. "Fetch App Store Data" をクリック
   - RevenueCat が自動的に App Store Connect から設定を取得
```

### 2.3 Offering・Product 設定

```yaml
RevenueCat > Products > iOS

本番ストアに登録済の App Store Product ID を入力:
  (例: com.yourwish.nuripazu.cosmetics_pack_1)

Offering 作成:
  - Default (デフォルト、全ユーザー向け)
  - Trial (オプション、1週間無料トライアル)
  - Launch Promo (ローンチキャンペーン)
```

### 2.4 API Key 生成

```bash
RevenueCat > Project > API Keys

API Key (Public) を取得:
  - これを REVENUE_CAT_API_KEY_PROD として使用
  - アプリにハードコード (ただし暗号化推奨)

API Key (Secret) を取得:
  - バックエンド・クラウド関数用
  - GitHub Secrets に登録
```

### 2.5 Dart/Flutter SDK 統合

```dart
// lib/services/revenue_cat_service.dart

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static Future<void> initialize() async {
    await Purchases.configure(
      PurchasesConfiguration(
        // 本番 API Key
        apiKey: const String.fromEnvironment('REVENUE_CAT_API_KEY_PROD'),
        appUserID: firebaseUser.uid,  // Firebase Auth ユーザー ID
      ),
    );
    
    // 課金可能な Offering を取得
    final offerings = await Purchases.getOfferings();
    _offerings = offerings;
  }

  // 課金処理
  static Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      
      // 購入成功ログ
      FirebaseAnalytics.instance.logPurchase(
        currency: 'JPY',
        value: package.storeProduct.price,
        items: [
          AnalyticsEventItem(itemId: package.identifier),
        ],
      );
      
      return true;
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return false;
    }
  }
}
```

---

## Step 3: Google Mobile Ads 本番設定

### 3.1 AdMob アカウント作成

**Link**: https://admob.google.com/

```yaml
AdMob Setup:
  1. Google Account でログイン
  2. "初めての方へ" → "スタート"
  3. 説明に従ってアカウント作成
  4. AdMob App ID 取得
```

### 3.2 iOS アプリ登録

```yaml
AdMob > App を追加

1. Platform: iOS
2. App Name: "ぬりパズ動物園"
3. App Store ID: (App Store Connect から取得)
   - https://apps.apple.com/us/app/[name]/id[ID]

ID を記録:
  ADMOB_APP_ID_PROD = ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

### 3.3 Ad Unit 作成

```yaml
バナー広告:
  1. AdMob > Ad Unit を新規作成
  2. プラットフォーム: iOS
  3. Ad Format: Banner
  4. Display Type: Smart Banner
  5. Unit Name: "Nuripazu Banner"
  
  結果 Ad Unit ID:
    ADMOB_BANNER_ID_PROD = ca-app-pub-3940256099942544/2934735716

リワード広告:
  1. Ad Format: Rewarded
  2. Unit Name: "Nuripazu Rewarded"
  3. Reward Amount: 50 coins
  4. Reward Type: coins (カスタム)
  
  結果 Ad Unit ID:
    ADMOB_REWARDED_ID_PROD = ca-app-pub-3940256099942544/5224354917

間幕広告:
  1. Ad Format: Interstitial
  2. Unit Name: "Nuripazu Interstitial"
  
  結果 Ad Unit ID:
    ADMOB_INTERSTITIAL_ID_PROD = ca-app-pub-3940256099942544/4411468910
```

### 3.4 Google Mobile Ads SDK 統合

```dart
// lib/services/ads_service.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const String appId = String.fromEnvironment('ADMOB_APP_ID_PROD');
  static const String bannerId = String.fromEnvironment('ADMOB_BANNER_ID_PROD');
  static const String rewardedId = String.fromEnvironment('ADMOB_REWARDED_ID_PROD');

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // バナー広告
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  // リワード広告
  static Future<RewardedAd?> createRewardedAd() async {
    return RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadListener: RewardedAdLoadListener(
        onAdLoaded: (ad) {
          // 広告読み込み成功
        },
        onAdFailedToLoad: (LoadAdError error) {
          // エラーハンドリング
        },
      ),
    );
  }
}
```

---

## Step 4: GitHub Secrets 登録

### 4.1 Production API Keys の保管

**Link**: GitHub Settings > Secrets and variables > Actions

本番 API キーを GitHub Secrets に登録（CI/CD で使用):

```bash
FIREBASE_WEB_API_KEY_PROD=xxx...
FIREBASE_APP_ID_PROD=xxx...
FIREBASE_PROJECT_ID_PROD=xxx...
FIREBASE_MESSAGING_SENDER_ID_PROD=xxx...

REVENUE_CAT_API_KEY_PROD=xxx...
REVENUE_CAT_SECRET_KEY_PROD=xxx...

ADMOB_APP_ID_PROD=xxx...
ADMOB_BANNER_ID_PROD=xxx...
ADMOB_REWARDED_ID_PROD=xxx...

APPLE_TEAM_ID=XXXXXXXXXX
```

### 4.2 GitHub Actions Workflow 更新

```yaml
# .github/workflows/build-ios.yml

jobs:
  build-ios:
    runs-on: macos-latest
    environment: production
    
    env:
      FIREBASE_WEB_API_KEY_PROD: ${{ secrets.FIREBASE_WEB_API_KEY_PROD }}
      FIREBASE_PROJECT_ID_PROD: ${{ secrets.FIREBASE_PROJECT_ID_PROD }}
      REVENUE_CAT_API_KEY_PROD: ${{ secrets.REVENUE_CAT_API_KEY_PROD }}
      ADMOB_APP_ID_PROD: ${{ secrets.ADMOB_APP_ID_PROD }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      
      - name: Build TestFlight
        run: |
          ./scripts/build_testflight.sh \
            --version ${{ github.ref_name }} \
            --team ${{ secrets.APPLE_TEAM_ID }}
```

---

## Step 5: Remote Config 設定

### 5.1 Feature Flags・A/B Testing 準備

```yaml
Firebase > Remote Config

設定項目:

affection_level_decay_days:
  - 説明: "なつき度が 1 低下する日数"
  - 型: Number
  - 値: 3 (3 日間未交流で 1 低下)
  - A/B Test: チャーン率を監視

herd_bonus_celebration_duration_ms:
  - 説明: "群れボーナス演出の長さ (ミリ秒)"
  - 型: Number
  - 値: 5000 (5 秒)

max_free_animals:
  - 説明: "無料で入手できる動物の最大数"
  - 型: Number
  - 値: 1

enable_legacy_support:
  - 説明: "旧バージョンのサポート"
  - 型: Boolean
  - 値: false
```

### 5.2 Dart での Remote Config 使用

```dart
// lib/services/remote_config_service.dart

import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // 本番デフォルト値
    await _remoteConfig.setDefaults(const {
      'affection_level_decay_days': 3,
      'herd_bonus_celebration_duration_ms': 5000,
      'max_free_animals': 1,
      'enable_legacy_support': false,
    });

    // 最新設定を取得
    await _remoteConfig.fetchAndActivate();
  }

  static int getAffectionDecayDays() {
    return _remoteConfig.getInt('affection_level_decay_days');
  }

  static int getHerdBonusDurationMs() {
    return _remoteConfig.getInt('herd_bonus_celebration_duration_ms');
  }
}
```

---

## Step 6: 本番環境テスト

### 6.1 TestFlight での本番環境動作確認

```yaml
テスト項目:

Firebase:
  ✅ 認証: Anonymous ログイン成功
  ✅ Firestore: データ読み書き成功
  ✅ Analytics: イベント送信確認
  ✅ Crashlytics: クラッシュレポート送信確認
  ✅ Remote Config: 設定値取得確認

RevenueCat:
  ✅ 課金画面表示
  ✅ 課金処理フロー
  ✅ レシート検証
  ✅ 復元機能 (restore purchases)

Google Mobile Ads:
  ✅ バナー広告表示
  ✅ リワード広告表示
  ✅ クリック・タップ検出

KPI 計測:
  ✅ aha_moment_reached イベント送信
  ✅ animal_interacted イベント送信
  ✅ paywall_converted イベント送信
```

### 6.2 本番環境での日本語サポート確認

```dart
// lib/services/localization_service.dart

// iOS システム言語が日本語の場合
// アプリ UI が日本語で表示されることを確認

void main() {
  runApp(
    MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      // ⚠️ locale がデバイスの言語設定に従うこと
    ),
  );
}
```

---

## Troubleshooting

### エラー: "Firebase Project not found"

```
原因: pubspec.yaml の Firebase Project ID が誤り

解決:
1. Firebase Console で正確な Project ID を確認
2. lib/config/firebase_config.dart を更新
3. GoogleService-Info.plist を再ダウンロード
```

### エラー: "RevenueCat API Key not found"

```
原因: 環境変数が設定されていない

解決:
source .env.testflight
echo $REVENUE_CAT_API_KEY_PROD
# 値が表示されることを確認
```

### エラー: "AdMob App ID invalid"

```
原因: AdMob App ID の形式が誤り

解決:
1. AdMob Console で正確な App ID を確認
   - 形式: ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
2. lib/config/ads_config.dart を更新
3. info.plist に GADApplicationIdentifier を追加:
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

---

## Checklist: Phase 9B 完了基準

- [ ] Firebase 本番プロジェクト作成済
- [ ] Firestore Database 初期化完了
- [ ] Authentication (Anonymous, Apple) 有効化
- [ ] Cloud Functions デプロイ完了
- [ ] Firestore セキュリティルール適用済
- [ ] Firebase Analytics・Crashlytics 設定完了
- [ ] RevenueCat 本番プロジェクト作成済
- [ ] Apple App Store 連携設定完了
- [ ] Offering・Product 登録完了
- [ ] RevenueCat API Key 取得・保管済
- [ ] Google AdMob App ID 生成済
- [ ] Ad Unit (Banner, Rewarded) 作成済
- [ ] GitHub Secrets に全て本番キー登録済
- [ ] Remote Config 設定項目登録完了
- [ ] TestFlight での本番環境テスト実施・合格
- [ ] KPI 計測イベント送信確認

---

## Next: Phase 9C

✅ Phase 9B 完了後、Phase 9C に進み、Pre-launch 検証 (7-14 日間) を実施

```
Phase 9C: Pre-Launch 検証フロー
  - KPI ゲート: Crash-Free Rate ≥99.5%, Aha Rate ≥60%
  - テスター フィードバック収集
  - パフォーマンス・スタビリティ確認
  - Go/No-Go 決定
```

---

**更新日**: 2026-09-02  
**ステータス**: Phase 9B 設定ガイド v1.0  
**責任者**: Claude Code - Phase 9B 実装
