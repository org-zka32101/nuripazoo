# Phase 9A: TestFlight 環境構築 - 実装ガイド

**概要**: iOS 証明書・プロビジョニング・Xcode 設定 → TestFlight ビルド生成 の完全実装ガイド

**実装期間**: 2-3 営業日  
**責任者**: iOS ビルド・リリース担当  
**ゲート条件**: TestFlight へのビルド正常アップロード確認

---

## 前提条件

```yaml
必須アカウント:
  - Apple Developer Account ($99/年)
  - App Store Connect アクセス権
  - Xcode (14.0+)
  - macOS 12.0+ (M1/Intel 対応)

既構築済環境:
  - 本番 Firebase Project
  - 本番 RevenueCat API キー
  - 本番 Google Mobile Ads API キー
  - GitHub Secrets に環境変数登録済
```

---

## Step 1: Apple Developer 証明書・プロビジョニング設定

### 1.1 Apple Developer Portal にログイン

```bash
# Link: https://developer.apple.com/account/
# Apple ID でログイン (2FA 有効推奨)
```

**画面**: Certificates, Identifiers & Profiles > Certificates

### 1.2 iOS Distribution 証明書の作成

```yaml
手順:
  1. Certificates > iOS Distribution の '+' ボタン
  2. "App Store and Ad Hoc" を選択
  3. CSR (Certificate Signing Request) ファイルをアップロード
     # ローカル Xcode で生成:
     # Xcode > Preferences > Accounts > Download Manual Profiles
     # または Keychain Access で CSR を生成

  4. 証明書をダウンロード (.cer)
  5. ダブルクリック → Keychain に自動登録
  6. Keychain Access.app で確認:
     - Certificates > "Apple Distribution" (ぬりパズ動物園)
```

**チェックリスト**:
- [ ] Certificate がローカル Keychain に登録済
- [ ] Keychain から秘密鍵をバックアップ (*.p12 形式)

### 1.3 App ID (Bundle Identifier) 登録

```yaml
手順:
  1. Certificates > Identifiers > '+' ボタン
  2. "App IDs" を選択
  3. "App" を選択
  4. Register:
     - Description: "Nuripazu - Animal Puzzle Zoo"
     - Bundle ID: "com.yourwish.nuripazu" (ワイルドカード不可)
     - Platform: iOS
  5. Capabilities を有効化:
     ✅ Push Notifications
     ✅ In-App Purchase
     ✅ CloudKit
     ✅ Sign in with Apple (任意)
     ✅ Game Kit (任意)
```

**チェックリスト**:
- [ ] Bundle ID: `com.yourwish.nuripazu` で登録済
- [ ] 必須 Capabilities が有効化

### 1.4 Provisioning Profile (Distribution) 作成

```yaml
手順:
  1. Certificates > Profiles > '+' ボタン
  2. "App Store" を選択 (TestFlight 用)
  3. Select App ID: "com.yourwish.nuripazu"
  4. Select Certificate: "Apple Distribution (ぬりパズ動物園)"
  5. Download Profile (.mobileprovision)
  6. Xcode に登録:
     - ダブルクリック自動登録
     - または ~/Library/MobileDevice/Provisioning\ Profiles/ に手動配置
  7. Xcode で確認:
     - Preferences > Accounts > Manage Certificates
     - "Nuripazu App Store Distribution" が表示される
```

**チェックリスト**:
- [ ] Provisioning Profile ダウンロード完了
- [ ] Xcode に正常に登録済

---

## Step 2: Xcode プロジェクト設定

### 2.1 Xcode を開く

```bash
cd /path/to/nuripazoo
open ios/Runner.xcworkspace
# (xcodeproj ではなく xcworkspace を開く！)
```

### 2.2 Signing & Capabilities 設定

**Xcode で Project > Runner を選択**

#### General タブ:

```yaml
Identity:
  - Display Name: "ぬりパズ動物園"
  - Bundle Identifier: "com.yourwish.nuripazu"
  - Version: "0.1.0"
  - Build: "1"
```

#### Signing & Capabilities タブ:

```yaml
Release コンフィグ設定:
  - Signing Certificate: "Apple Distribution" (自動または手動で選択)
  - Provisioning Profile: "Nuripazu App Store Distribution"
  - Team ID: (Apple Developer Team ID)
  - Code Signing Identity: "Apple Distribution"
  - Provisioning Profile (Automatic): OFF (手動管理)
```

**重要**: Debug と Release は別々の設定を持つため、Release 設定に集中

### 2.3 Capabilities 有効化

```yaml
Xcode > Project > Signing & Capabilities > '+Capability'

有効化するもの:
  ✅ Push Notifications
  ✅ In-App Purchase
  ✅ Game Kit
  ✅ CloudKit

これらを有効にすると:
  - Entitlements ファイルが自動生成
  - provisioning profile の Capabilities と一致
```

### 2.4 Info.plist 設定確認

```bash
# ios/Runner/Info.plist
# 必須フィールド:

✓ CFBundleDisplayName: "ぬりパズ動物園"
✓ CFBundleIdentifier: "com.yourwish.nuripazu"
✓ CFBundleVersion: "1" (Build Number)
✓ CFBundleShortVersionString: "0.1.0" (Version)
✓ CFBundleSupportedPlatforms: [ "iPhoneOS" ]
✓ MinimumOSVersion: "14.0"
✓ UIDeviceFamily: [ 1, 2 ] (iPhone, iPad)

# 既に ios/Runner/Info.plist に記載済
```

---

## Step 3: ビルド前の本番環境設定

### 3.1 環境変数の確認

```bash
# .env ファイルが本番環境を指しているか確認:

echo $FIREBASE_PROJECT_ID_PROD
echo $FIREBASE_WEB_API_KEY_PROD
echo $REVENUE_CAT_API_KEY_PROD
echo $ADMOB_APP_ID_PROD
```

### 3.2 Firebase 本番プロジェクト設定

```bash
# lib/config/firebase_config.dart

class FirebaseConfigProd {
  static const String projectId = 'nuripazu-prod';
  static const String webApiKey = '${FIREBASE_WEB_API_KEY_PROD}';
  static const String appId = '${FIREBASE_APP_ID_PROD}';
  // ... (本番値)
}

# 確認: lib/main.dart で Prod コンフィグを使用していること
```

### 3.3 RevenueCat 本番キー設定

```dart
// lib/services/revenue_cat_service.dart
class RevenueCatConfig {
  // Release ビルドでは本番 API キー
  static const String apiKeyProd = '${REVENUE_CAT_API_KEY_PROD}';
}
```

---

## Step 4: TestFlight ビルド生成

### 4.1 build_testflight.sh スクリプト実行

```bash
cd /path/to/nuripazoo

# 基本実行 (自動チーム検出)
./scripts/build_testflight.sh

# または詳細オプション指定
./scripts/build_testflight.sh \
  --version 0.1.0 \
  --build 1 \
  --team XXXXXXXXXX \
  --export-team XXXXXXXXXX
```

**実行内容**:
1. ✅ 前提条件チェック (Xcode, Flutter, CocoaPods)
2. ✅ flutter pub get
3. ✅ pod install
4. ✅ Info.plist 更新 (Version, Build)
5. ✅ Flutter Release ビルド (no-codesign)
6. ✅ Xcode Archive 生成
7. ✅ .ipa エクスポート
8. ✅ ビルド成果物検証

**出力**: `build/ios_build/ipa/Runner.ipa`

### 4.2 手動ビルド (スクリプト不使用時)

```bash
# Step 1: 依存解決
cd /path/to/nuripazoo
flutter pub get

cd ios/
pod install

# Step 2: Flutter Release ビルド
cd /path/to/nuripazoo
flutter build ios --release --no-codesign

# Step 3: Xcode Archive
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_build \
  -archivePath build/ios_build/Runner.xcarchive \
  -allowProvisioningUpdates \
  -verbose \
  archive

# Step 4: Export .ipa
xcodebuild \
  -exportArchive \
  -archivePath build/ios_build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios_build/ipa

# 結果:
# build/ios_build/ipa/Runner.ipa (生成完了)
```

---

## Step 5: App Store Connect へビルドアップロード

### 5.1 Transporter を使用したアップロード

```bash
# Option A: Xcode Organizer (GUI)
# Xcode > Window > Organizer
# Archives タブ > ビルドを選択 > Distribute App > App Store > Upload

# Option B: Transporter (CLI, 推奨)
# App Store Connect > Notifications > Transporter ダウンロード
# または Mac App Store から無料インストール

# ビルド情報:
open build/ios_build/ipa/
# Runner.ipa をドラッグ & ドロップで Transporter にアップロード

# または CLI:
xcrun altool \
  --upload-app \
  --file build/ios_build/ipa/Runner.ipa \
  --type ios \
  --apiKey xxxxx \
  --apiIssuer xxxxx
```

### 5.2 App Store Connect で確認

**Link**: https://appstoreconnect.apple.com/

```yaml
ビルド確認手順:
  1. My Apps > ぬりパズ動物園
  2. TestFlight タブ
  3. iOS Builds セクション
  4. アップロードされたビルドが表示される
     - Status: "Processing" → "Ready to Test" (数分～数時間)
  5. "Ready to Test" になったら外部テスターに配布可能
```

**ビルド詳細表示**:
```
Build Version: 0.1.0
Build Number: 1
Min OS Version: iOS 14.0
Supported Devices: iPhone, iPad
Status: Ready to Test ✓
```

---

## Step 6: TestFlight 内部テスター設定

### 6.1 Internal Testers グループ作成

```yaml
手順:
  1. App Store Connect > TestFlight タブ
  2. Internal Testing セクション > Testers
  3. '+' ボタン > "Internal Testers グループ"
  4. グループ名: "Development Team"
  5. メンバー追加:
     - developer@yourwish.dev
     - qa@yourwish.dev
     - (開発チーム全員)
  6. 保存
```

### 6.2 ビルドを Internal Testing に追加

```yaml
手順:
  1. TestFlight > Internal Testing > Builds
  2. アップロードされたビルドを選択
  3. "Add Build" > "Development Team" グループを選択
  4. Release Notes を入力:

---
🎉 ぬりパズ動物園 v0.1.0 - TestFlight 内部テスト

このビルドで確認します:

✨ 実装完了機能
- パズル → 完成 → 動物アクションの完全フロー
- なつき度 Lv1-4 システム (Lv昇降・低下)
- 群れボーナス演出 (3体揃い時)
- 個性別リアクション Lottie アニメーション
- UI レイアウト・ダークモード対応

🔧 テスト項目
- クラッシュレポート: 異常終了時は詳細情報
- パフォーマンス: FPS, 遅延, メモリ使用量
- アニメーション: Lottie 再生品質, スムーズ度
- サウンド: SE/BGM/鳴き声の再生確認
- ネットワーク: オフライン対応確認
- UI/UX: ボタン操作感, レスポンス

📊 フィードバック方法
1. TestFlight アプリ > Feedback タブ > '+' ボタン
2. 詳細 (再現手順・スクリーンショット) を記入
3. Submit

⏰ テスト期間: 7日間
連絡先: support@yourwish.dev
---

  5. Save
```

---

## Step 7: 外部テスター設定 (Optional @ Day 1)

### 7.1 External Testers グループ作成

```yaml
手順:
  1. TestFlight > External Testing > Testers
  2. '+' ボタン > グループ作成
  3. グループ名: "Community Beta"
  4. テスター追加方法:
     a) メール招待
     b) 公開リンク (LinkedIn, Twitter 等)
  5. テスター上限: 10,000 名
  6. テスト期間: デフォルト 90 日
```

### 7.2 External Build 設定 (Day 1 前)

```yaml
手順:
  1. TestFlight > External Testing > Builds
  2. ビルドを選択
  3. "Add Build" > "Community Beta"
  4. Beta App Review (審査)
     - Apple に事前審査依頼
     - 承認まで 24～48 時間
  5. 承認後、テスター配布開始
```

---

## Troubleshooting

### エラー: "Code Signing Error"

```
原因: Provisioning Profile がマッチしていない

解決:
1. Xcode > Preferences > Accounts > Manage Certificates
   - Certificate が Keychain に登録済か確認
2. Apple Developer Portal で新しい Provisioning Profile を生成
3. Xcode で "Download Manual Profiles" をクリック
4. Clean Build Folder: Cmd+Shift+K
5. 再ビルド
```

### エラー: "Certificate not found"

```
原因: Keychain に秘密鍵がない

解決:
1. Apple Developer Portal から証明書を再ダウンロード
2. ダブルクリックで Keychain にインポート
3. Keychain Access で確認:
   Certificates > "Apple Distribution (ぬりパズ動物園)"
   - 秘密鍵が表示される必要がある
```

### エラー: "Invalid Provisioning Profile"

```
原因: Bundle ID や Capabilities がマッチしていない

解決:
1. Apple Developer Portal で Provisioning Profile を削除
2. 新しいプロファイルを生成
3. Xcode で "Download Manual Profiles"
4. Info.plist の Bundle ID を再確認
5. Xcode Project > Signing & Capabilities を再設定
```

### エラー: "Build failed during export"

```
原因: ExportOptions.plist の teamID が不正

解決:
1. Team ID を確認: Apple Developer Portal > Membership > Team ID
2. ios/ExportOptions.plist を編集:
   <key>teamID</key>
   <string>XXXXXXXXXX</string>
3. 正しい ID を設定して再実行
```

### ビルドが遅い (10分以上)

```
最適化:
1. Clean Build Folder (Cmd+Shift+K)
2. Derived Data を削除:
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
3. CocoaPods キャッシュをクリア:
   pod cache clean --all
4. pod install を再実行
5. 不要な Asset をビルドから除外
```

---

## Checklist: Phase 9A 完了基準

- [ ] Apple Developer Certificate (Distribution) が Keychain に登録済
- [ ] App ID (com.yourwish.nuripazu) が Apple Developer Portal に作成済
- [ ] Provisioning Profile が生成・ダウンロード済
- [ ] Xcode Signing & Capabilities が正しく設定済
- [ ] Info.plist が最新版 (Version, Build, Bundle ID)
- [ ] ExportOptions.plist が正しい TeamID で設定済
- [ ] build_testflight.sh が実行可能状態 (chmod +x)
- [ ] Flutter Release ビルドが成功
- [ ] .ipa ファイルが build/ios_build/ipa/Runner.ipa に生成
- [ ] App Store Connect へのビルドアップロード成功
- [ ] TestFlight で "Ready to Test" ステータス確認
- [ ] Internal Testers グループが作成済
- [ ] テスター招待メール送信完了

---

## Next: Phase 9B

✅ Phase 9A 完了後、Phase 9B に進み、Firebase・RevenueCat 本番環境設定を実施

```
Phase 9B: 本番環境設定
  - Firebase 本番プロジェクト初期化
  - Firestore セキュリティルール適用
  - RevenueCat 本番キー設定
  - Google Mobile Ads 本番設定
```

---

**更新日**: 2026-09-02  
**ステータス**: Phase 9A 実装ガイド v1.0  
**責任者**: Claude Code - Phase 9A 実装
