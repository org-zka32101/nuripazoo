# Phase 9A: TestFlight 構築 - クイックリファレンス

**用途**: テクニカル手順をすぐに参照したいときのチートシート  
**対象**: 開発者・ビルド担当者  

---

## 📋 完全チェックリスト (所要時間: 1-2 営業日)

### Pre-Build (2-3 時間)

- [ ] **Apple Developer Portal**
  - [ ] iOS Distribution Certificate をダウンロード → Keychain に登録
  - [ ] App ID (com.yourwish.nuripazu) を作成
    - Push Notifications, In-App Purchase, CloudKit 有効化
  - [ ] Provisioning Profile を作成・ダウンロード
  - [ ] Team ID をメモ (XXXXXXXXXX)

- [ ] **Xcode 設定** (ios/Runner.xcworkspace を開く)
  - [ ] Signing & Capabilities > Team を選択
  - [ ] Bundle Identifier: com.yourwish.nuripazu
  - [ ] Provisioning Profile: "Nuripazu App Store Distribution"
  - [ ] Version: 0.1.0 / Build: 1

- [ ] **環境変数設定**
  ```bash
  cp .env.testflight.example .env.testflight
  # 値を入力:
  # - APPLE_TEAM_ID
  # - FIREBASE_*_PROD
  # - REVENUE_CAT_API_KEY_PROD
  # - ADMOB_*_PROD
  
  source .env.testflight
  ```

### Build (20-30 分)

- [ ] **build_testflight.sh 実行**
  ```bash
  cd /path/to/nuripazoo
  
  ./scripts/build_testflight.sh \
    --version 0.1.0 \
    --build 1 \
    --team $APPLE_TEAM_ID \
    --export-team $APPLE_TEAM_ID
  ```

- [ ] **ビルド成果物確認**
  - [ ] build/ios_build/ipa/Runner.ipa が生成済
  - [ ] ファイルサイズ: < 1000 MB

### Upload to App Store Connect (10-15 分)

- [ ] **Transporter (または Xcode Organizer) を開く**
  ```bash
  # Transporter をダウンロード:
  # https://apps.apple.com/us/app/transporter/id1450874784
  
  # ビルドを追加: Runner.ipa をドラッグ&ドロップ
  # または: xcrun altool --upload-app -f build/ios_build/ipa/Runner.ipa ...
  ```

- [ ] **App Store Connect で確認**
  - [ ] https://appstoreconnect.apple.com/ にログイン
  - [ ] My Apps > ぬりパズ動物園
  - [ ] TestFlight > iOS Builds
  - [ ] ビルドが表示される
  - [ ] Status: "Ready to Test" になるまで待機 (5分～2時間)

### TestFlight テスター設定 (10 分)

- [ ] **Internal Testers グループ作成**
  - [ ] App Store Connect > TestFlight
  - [ ] Internal Testing > Testers > '+' ボタン
  - [ ] グループ名: "Development Team"
  - [ ] メンバー追加: developer@yourwish.dev など

- [ ] **ビルドをテスターに配布**
  - [ ] TestFlight > Internal Testing > Builds
  - [ ] ビルドを選択 > "Add Build"
  - [ ] Release Notes を入力
  - [ ] "Development Team" を選択

- [ ] **テスター招待メール確認**
  - [ ] テスターのメールボックスを確認
  - [ ] "Test ぬりパズ動物園 on TestFlight" メール

---

## 🚀 実行コマンド集

### 環境準備

```bash
# 環境変数の読み込み
source .env.testflight

# 依存解決
cd /path/to/nuripazoo
flutter pub get
cd ios && pod install && cd ..
```

### ビルド実行

```bash
# フル自動ビルド (推奨)
./scripts/build_testflight.sh \
  --version 0.1.0 \
  --build 1 \
  --team $APPLE_TEAM_ID \
  --export-team $APPLE_TEAM_ID

# または詳細ステップバイステップ:

# 1. Flutter Release ビルド
flutter build ios --release --no-codesign

# 2. Archive
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_build \
  -archivePath build/ios_build/Runner.xcarchive \
  -allowProvisioningUpdates \
  archive

# 3. Export .ipa
xcodebuild \
  -exportArchive \
  -archivePath build/ios_build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios_build/ipa
```

### Upload

```bash
# Transporter CLI (推奨)
xcrun altool \
  --upload-app \
  --file build/ios_build/ipa/Runner.ipa \
  --type ios \
  --apiKey xxxx \
  --apiIssuer xxxx
```

### クリーンアップ

```bash
# キャッシュ削除して再構築
rm -rf build/ios_build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

pod cache clean --all
cd ios && pod install
```

---

## 🔍 トラブルシューティング (よくあるエラー)

| エラー | 原因 | 解決 |
|--------|------|------|
| "Code Signing Error" | Provisioning Profile が見つからない | Apple Developer Portal で新しい Profile を生成 → Xcode で Download Manual Profiles |
| "Certificate not found" | 秘密鍵がない | Keychain Access で確認: Certificates に Apple Distribution があるか |
| "Invalid Provisioning Profile" | Bundle ID が違う | Info.plist と Apple Developer の Bundle ID を統一 |
| "Build failed during export" | ExportOptions.plist の teamID が間違い | Team ID を確認して更新 |
| "Build takes > 10 min" | キャッシュが古い | `pod cache clean --all` → `pod install` → `flutter clean` |

---

## 📞 重要リソース

- **Apple Developer**: https://developer.apple.com/account/
- **App Store Connect**: https://appstoreconnect.apple.com/
- **Transporter**: https://apps.apple.com/us/app/transporter/id1450874784
- **Xcode Release Notes**: https://developer.apple.com/news/?id=xxxxx

---

## 🎯 成功の確認

```yaml
Phase 9A 成功の目安:

✓ TestFlight にビルドが "Ready to Test" 表示
✓ Internal Testers がメール招待を受け取った
✓ TestFlight アプリで "ぬりパズ動物園" が表示される
✓ テスターがビルドをインストール可能
```

---

## 📝 版履歴

| 版 | 日時 | 変更 |
|----|------|------|
| 1.0 | 2026-09-02 | 初版作成 |

---

**関連ドキュメント**: 
- [Phase 9A 詳細ガイド](./PHASE_9A_IMPLEMENTATION_GUIDE.md)
- [Phase 9 全体計画](./PHASE_9_TESTFLIGHT_STORE_SUBMISSION.md)
