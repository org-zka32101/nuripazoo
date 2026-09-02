# Phase 9B: Production Setup - Quick Start Guide

**用途**: Phase 9B 実装の最短チェックリスト  
**対象**: バックエンド・インフラ担当  
**実装時間**: 1-2 営業日

---

## 🎯 5 分でわかる Phase 9B

```
Firebase (本番)
  ↓
RevenueCat (課金)
  ↓
Google Mobile Ads (広告)
  ↓
GitHub Secrets (CI/CD)
  ↓
TestFlight 本番環境テスト
```

---

## ⚡ Step-by-Step Checklist

### Step 1: Firebase 本番プロジェクト (15 分)

- [ ] Firebase Console: `nuripazu-prod` プロジェクト作成
- [ ] iOS アプリ登録 → `GoogleService-Info.plist` ダウンロード
- [ ] Firestore Database 初期化 (本番モード, asia-northeast1)
- [ ] Authentication: Anonymous + Apple 有効化
- [ ] Cloud Functions: `firebase deploy --only functions`

**確認コマンド**:
```bash
# GoogleService-Info.plist が存在するか
ls -la lib/config/firebase/GoogleService-Info.plist

# Cloud Functions がデプロイされたか
firebase functions:list --project=nuripazu-prod
```

### Step 2: Firestore セキュリティルール (10 分)

- [ ] Firestore > Rules タブを開く
- [ ] 以下をコピペ:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isOwner(uid) { return request.auth.uid == uid; }
    
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      match /animals/{animalId} {
        allow read: if isOwner(userId);
        allow write: if false;
      }
    }
    
    match /animal_masters/{doc=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

- [ ] Publish

### Step 3: RevenueCat 本番設定 (20 分)

- [ ] RevenueCat: `nuripazu-prod` プロジェクト作成
- [ ] Apple > Integrate:
  - [ ] Apple ID + App-specific Password 入力
  - [ ] Bundle ID: `com.yourwish.nuripazu`
  - [ ] Fetch App Store Data クリック
- [ ] API Key (Public) 取得 → `REVENUE_CAT_API_KEY_PROD`
- [ ] API Key (Secret) 取得 → GitHub Secrets に登録

**確認**:
```bash
echo $REVENUE_CAT_API_KEY_PROD
# 値が表示される (例: appl_xxx...)
```

### Step 4: Google AdMob 設定 (20 分)

- [ ] AdMob Console: iOS アプリ登録
- [ ] Ad Unit 作成:
  - [ ] Banner: `ADMOB_BANNER_ID_PROD`
  - [ ] Rewarded: `ADMOB_REWARDED_ID_PROD`
  - [ ] Interstitial: `ADMOB_INTERSTITIAL_ID_PROD`
- [ ] App ID 取得: `ADMOB_APP_ID_PROD`

**確認**:
```
AdMob Console > Apps & settings
ID 一覧が表示される
```

### Step 5: GitHub Secrets 登録 (10 分)

- [ ] GitHub > Settings > Secrets and variables > Actions
- [ ] 以下の Key=Value を追加:

```
FIREBASE_WEB_API_KEY_PROD=xxx
FIREBASE_APP_ID_PROD=xxx
FIREBASE_PROJECT_ID_PROD=nuripazu-prod
FIREBASE_MESSAGING_SENDER_ID_PROD=xxx

REVENUE_CAT_API_KEY_PROD=appl_xxx
REVENUE_CAT_SECRET_KEY_PROD=xxx

ADMOB_APP_ID_PROD=ca-app-pub-xxx~yyy
ADMOB_BANNER_ID_PROD=ca-app-pub-xxx
ADMOB_REWARDED_ID_PROD=ca-app-pub-xxx

APPLE_TEAM_ID=XXXXXXXXXX
```

**確認**:
```bash
gh secret list  # すべてのシークレットが表示される
```

### Step 6: Remote Config 設定 (5 分)

- [ ] Firebase > Remote Config > パラメータを新規作成:
  - [ ] `affection_level_decay_days` = 3
  - [ ] `herd_bonus_celebration_duration_ms` = 5000
  - [ ] `max_free_animals` = 1
  - [ ] `enable_legacy_support` = false

### Step 7: TestFlight 本番環境テスト (30 分)

```bash
# TestFlight ビルド実行
./scripts/build_testflight.sh \
  --version 0.1.0 \
  --build 1 \
  --team $APPLE_TEAM_ID

# App Store Connect にアップロード
# (Transporter 使用、詳細は Phase 9A 参照)
```

**テスト項目**:
- [ ] Firebase 認証 (Anonymous)
- [ ] Firestore データ読み書き
- [ ] 課金フロー (ダミー商品)
- [ ] 広告表示 (バナー + リワード)
- [ ] Analytics イベント送信
- [ ] Crashlytics 動作確認

---

## 📝 Key Values チートシート

```yaml
Firebase:
  Project ID: nuripazu-prod
  Web API Key: 🔐 (Firebase Console > Project Settings)
  App ID: 🔐 (GoogleService-Info.plist)

RevenueCat:
  API Key: appl_xxxxx (RevenueCat > Project > API Keys)
  Secret Key: 🔐 (GitHub Secrets のみ)

AdMob:
  App ID: ca-app-pub-xxxxx~yyyyy (AdMob Console)
  Banner ID: ca-app-pub-xxxxx (Ad Unit)
  Rewarded ID: ca-app-pub-xxxxx (Ad Unit)

Apple:
  Team ID: XXXXXXXXXX (developer.apple.com/account)
  Bundle ID: com.yourwish.nuripazu
```

---

## ⚠️ よくあるミス

| ミス | 対策 |
|------|------|
| Firebase の開発環境と本番を混同 | Project ID が `nuripazu-prod` であることを確認 |
| RevenueCat API Key を平文で管理 | GitHub Secrets に保管、リポジトリには入れない |
| AdMob App ID を間違える | AdMob Console で 正確な ID (~ を含む) をコピー |
| Firestore ルール適用忘れ | なつき度データが直接更新されることになり危険 |
| GitHub Actions が本番キーを使用しない | `environment: production` を `.yml` に指定 |

---

## 🔍 動作確認コマンド

```bash
# Firebase に接続できるか
firebase projects:list | grep nuripazu-prod

# GitHub Secrets が登録されているか
gh secret list

# Dart パッケージが正しいか
flutter pub get
grep -E 'firebase|revenue_cat|google_mobile_ads' pubspec.yaml

# 本番環境の設定が読み込まれているか
grep -r 'nuripazu-prod' lib/config/
grep -r 'REVENUE_CAT_API_KEY_PROD' lib/config/
```

---

## 📞 Support Links

- **Firebase Console**: https://console.firebase.google.com/
- **RevenueCat Dashboard**: https://app.revenuecat.com/
- **Google AdMob**: https://admob.google.com/
- **Apple Developer**: https://developer.apple.com/account/
- **GitHub Secrets**: https://github.com/org-zka32101/nuripazoo/settings/secrets/actions

---

**Version**: 1.0  
**Last Updated**: 2026-09-02  
**Phase**: 9B Production Environment Setup
