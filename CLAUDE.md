# CLAUDE.md - ぬりパズ動物園（nuripazu）

## プロジェクト概要

ジェムパズル×動物育成の癒し系パズルゲーム。完成後の「なつき度育成」「群れ形成」で継続動機を実現。

- **プロジェクト名**: ぬりパズ動物園（内部コード: `nuripazu`）
- **言語**: Dart (Flutter 3.x)
- **フレームワーク**: Flutter + Riverpod + Firebase + RevenueCat + Lottie
- **対象OS**: iOS / Android
- **ビジネスモデル**: 広告主体 + コスメ課金 + サブスク

## Vision / Mission / OKR

```
Vision: 宝石パズルが、ただの暇つぶしから「愛着の育つ庭」に変わる世界
Mission: 完成して終わりだったパズル体験に、集め・育て・眺める継続価値を与える

OKR:
  - KR1: Day7 リテンション 18%
  - KR2: Day30 リテンション 8%
  - KR3: 有料転換率 3%
  - KR4: Viral Coefficient 0.3
```

## 差別化の核（絶対に落としてはいけない点）

1. **なつき度 Lv1-4 システム**: 1日1回交流、3日未交流でLv低下（放置ペナルティ＝復帰ナッジ根拠）
2. **動物ごとの個性タグ + 分岐リアクション**: 同じ交流でも動物により演出が変わる
3. **群れ形成（生息地3体揃いでミニシーン）**: 中間目標として会話の口実を作る
4. **Lv4 到達特典は無料**: 専用ポーズ表示。課金は時短・見た目彩りのみ（育成の本質は無料完結）

## ディレクトリ構成

```
nuripazu/
├── lib/
│   ├── main.dart
│   ├── models/              # AnimalMaster, UserAnimal, PuzzleSession, HerdBonus, ShareAsset, User
│   ├── services/            # FirestoreService, PuzzleEngineService, AffectionService, ShareService
│   ├── viewmodels/          # Riverpod Provider群
│   ├── views/               # 画面コンポーネント
│   │   ├── onboarding.dart
│   │   ├── home.dart        # 動物園ホーム
│   │   ├── puzzle.dart
│   │   ├── completion.dart  # 完成演出
│   │   ├── collection.dart  # 図鑑
│   │   ├── animal_detail.dart # 交流画面
│   │   ├── share.dart
│   │   ├── paywall.dart
│   │   └── settings.dart
│   └── widgets/             # 再利用可能ウィジェット（petit_ui優先）
├── assets/
│   ├── lottie/              # Lottie アニメーション
│   ├── images/              # ピクセルアート・UI画像
│   └── sounds/              # 鳴き声・SE
├── test/
│   ├── unit/                # ユニットテスト（Lv昇降、群れ判定等）
│   ├── widget/              # ウィジェットテスト
│   └── integration/         # 統合テスト（課金+Aha動線）
├── pubspec.yaml
├── CLAUDE.md
├── README.md
└── .firebase/               # Firebase設定（環境変数管理）
```

## 技術スタック

```
- Flutter 3.x / Dart 3.x
- Riverpod (상태 관理)
- Firebase (Firestore/Auth/Analytics/Crashlytics/Remote Config/Cloud Functions)
- RevenueCat (課金SDK)
- Lottie (アニメーション)
- petit_core, petit_ui (共通基盤・UI)
- google_fonts (Typography)
- intl (多言語・日時)
```

## 実装順序（推奨）

1. petit_core/petit_ui 導入
2. データモデル定義（User, AnimalMaster, UserAnimal, PuzzleSession, HerdBonus, ShareAsset）
3. Service層（**AffectionService のLv昇降ロジックを最優先で固める**）
4. 計測3点セット（Firebase Analytics/Crashlytics/Remote Config）
5. ViewModel (Riverpod Provider群)
6. **Aha Moment 最短動線を最優先**（起動→パズル→完成→動物1アクション = 3タップ以内）
7. 各画面 View の実装
8. 個性別リアクション Lottie・群れミニシーン
9. 画面遷移・ナビゲーション
10. オンボ + ペイウォール（2体目完成後トリガー、1体目は無料体験優先）
11. なつき度低下（放置ペナルティ）ロジック + 復帰通知
12. 群れ形成判定・ミニシーン再生
13. エラーハンドリング全般
14. ユニット・ウィジェット・統合テスト
15. CI/CD (GitHub Actions)
16. リリース準備（iOS/Android）

## KPI 計測（5個以内）

```
aha_moment_reached      # 初回動物アクション時
animal_interacted       # なつき度更新時
herd_bonus_unlocked     # 群れ演出時
share_created           # シェア実行時
paywall_converted       # 課金時
```

**追加監視**: なつき度低下率（チャーン先行指標、Remote Configで閾値調整可）

## 実装上の重要事項

### セキュリティ

- ✅ APIキー環境変数化（`.env` / GitHub Secrets）
- ✅ **なつき度・所持動物データは Firestore ルールで直接書込み禁止、Cloud Functions 経由に統一**（改ざん対策）
- ✅ RevenueCat 課金検証
- ✅ HTTPS のみ
- ✅ ペアレンタルゲート（課金導線のみ）

### データ入稿パイプライン（月次運用）

- **スプレッドシート管理** → **検証スクリプト**（重複・NGワード確認）→ **Firestore 投入**
- 新動物2-3種を毎月追加（コンテンツ物量リスク対応）
- **petit_ai 絵柄自動生成** の実現性は別途検証要（⭐4/5 判定時の残課題）

### UI/UX 品質基準

- ✅ ボタン44pt以上 + バウンスアニメーション
- ✅ ハプティクスフィードバック
- ✅ ダークモード対応必須
- ✅ 和み系の柔らかい配色・角丸多用
- ✅ Lottie 完成演出（宝石が舞い、動物が浮かび上がる）
- ✅ 個性別リアクション演出 (Lottie差分)
- ✅ 群れミニシーン (3-5秒・音付き)
- ✅ 動物種ごとの鳴き声・SE個別
- ✅ BGM は動物園全体で1本・ミュート尊重

### パフォーマンス・オフライン対応

- ✅ パズル本体・図鑑閲覧はオフライン完全対応
- ✅ 交流演出もオフライン完全対応（Lottieはローカル）
- ✅ シェア・広告視聴・課金はオンライン必須
- ✅ タイムアウト10秒・リトライ3回
- ✅ スケルトン UI で読み込み状態を可視化

### テスト戦略

- **Unit**: なつき度昇降ロジック・群れ判定（カバレッジ50%+）
- **Widget**: パズル画面・動物詳細画面
- **Integration**: 課金導線 + Aha 動線

### CI/CD

- GitHub Actions → analyze → test → ビルド → TestFlight/Firebase App Distribution
- ソフトローンチ: TestFlight 外部テスト → Day1・クラッシュフリー99.5%+・Aha到達率60%+確認後に本公開

## 未検証・要確認事項

- ✅ **petit_ai 絵柄自動生成パイプラインの実現性**（高優先度）
- ✅ **かずきさん自身の育成ゲーム嗜好**（開発継続意欲の先行指標）
- ✅ **ストア出願前に「ぬりパズ動物園」タイトル最終再確認**

## リリース・運用設計

- **ソフトローンチ**: TestFlight 外部テストでゲート確認後に本公開
- **広告审查**: 広告SDK・ペアレンタルゲート・データセーフティ整合
- **LiveOps**: 月次で新動物2-3種を無停止追加。季節限定動物（4-12週サイクル）をカレンダー化

---

詳細は以下を参照：

- **企画設計書**: `docs/nuripazu_企画設計書_v1_0.md`
- **コード実装引き継ぎ**: `docs/nuripazu_code_handoff_v1_0.md`
