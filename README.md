# ぬりパズ動物園（nuripazu）

ジェムパズル×動物育成の癒し系パズルゲーム。完成動物を育てて動物園を作ろう。

## 🎮 プロジェクト概要

- **Vision**: 宝石パズルが、ただの暇つぶしから「愛着の育つ庭」に変わる世界
- **Mission**: 完成して終わりだったパズル体験に、集め・育て・眺める継続価値を与える
- **対象**: 20-40代女性中心、隙間時間リラックス層
- **プラットフォーム**: iOS / Android (Flutter)

## 🏗️ 技術スタック

```
- Flutter 3.x / Dart 3.x
- Riverpod (状態管理)
- Firebase (Firestore, Auth, Analytics, Crashlytics, Remote Config, Cloud Functions)
- RevenueCat (課金SDK)
- Lottie (アニメーション)
- petit_core, petit_ui (共通基盤)
```

## 📁 ディレクトリ構成

```
lib/
├── main.dart                  # エントリーポイント
├── models/                    # データモデル定義
├── services/                  # ビジネスロジック層
├── viewmodels/                # Riverpod Provider群
├── views/                     # 画面コンポーネント
└── widgets/                   # 再利用可能ウィジェット
```

## 🚀 セットアップ

```bash
# 依存パッケージをインストール
flutter pub get

# コード生成（Freezed, json_serializable）
dart run build_runner build --delete-conflicting-outputs

# 実行
flutter run
```

## 📋 実装ロードマップ

### Phase 1: 基盤構築
- [x] プロジェクト初期化
- [x] データモデル定義
- [x] Service層実装（AffectionService最優先）
- [ ] Riverpod Provider 構築
- [ ] Firebase 統合

### Phase 2: Aha Moment
- [ ] ジェムパズル本体
- [ ] 完成演出 + 動物アクション
- [ ] **最短経路: 3タップ以内・60秒以内**

## 🎯 差別化の核

1. **なつき度 Lv1-4 システム**: 1日1回交流、3日未交流でLv低下
2. **動物ごとの個性リアクション**: 同じ交流でも演出が変わる
3. **群れ形成ボーナス**: 生息地3体揃いでミニシーン
4. **無料育成 + コスメ課金**: 育成本質は無料、課金は時短・見た目のみ

## 📊 OKR

```
KR1: Day7 リテンション 18%
KR2: Day30 リテンション 8%
KR3: 有料転換率 3%
KR4: Viral Coefficient 0.3
```

---

**内部コードネーム**: `nuripazu`  
**作成日**: 2026-08-27