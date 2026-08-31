# ぬりパズ動物園 — Code 実装引き継ぎ書（作成日: 2026-08-27）
前提資料: nuripazu_企画設計書_v1_0.md（本書単体でも実装着手可能なよう要点を集約）
内部コードネーム: `nuripazu`

## Vision/Mission/OKR
- Vision: 宝石パズルが、ただの暇つぶしから「愛着の育つ庭」に変わる世界
- Mission: 完成して終わりだったパズル体験に、集め・育て・眺める継続価値を与える
- OKR: Day7 18% ／ Day30 8% ／ 有料転換率 3% ／ Viral Coefficient 0.3

## 概要
ジェムパズル（宝石を正しい枠へ仕分けてピクセルアート完成）×動物育成の癒し系パズル。
競合Jewel Coloring（1,000関卡超・完成=ゴール型）に対し、「完成=スタート」（なつき度育成・
群れ形成演出）で差別化。白地軸: パズル完成後の資産化・継続動機。

## 差別化の核（実装者が絶対に落としてはいけない点）
1. **なつき度Lv1-4システム**：1日1回交流、3日未交流でLv低下（放置ペナルティ＝復帰ナッジの根拠）
2. **動物ごとの個性タグ＋分岐リアクション**：同じ交流でも動物により演出が変わる
3. **群れ形成（生息地3体揃いでミニシーン）**：中間目標として会話の口実を作る
4. Lv4到達特典（専用ポーズ）は**無料**。課金は時短・見た目彩りのみ（育成の本質は無料完結）

## スタック
Flutter/Dart 3.x + Riverpod + Firebase(Firestore/Auth/Analytics/Crashlytics/Remote Config/Cloud Functions)
+ RevenueCat + Lottie。MVVM。petit_core/petit_ui を依存追加、共通基盤は再実装しない。

## ディレクトリ構成
```
lib/
  models/       // AnimalMaster, UserAnimal, PuzzleSession, HerdBonus, ShareAsset, User
  services/     // FirestoreService, PuzzleEngineService, AffectionService, ShareService
  viewmodels/   // Riverpod Provider群
  views/        // Onboarding, Home(動物園), Puzzle, CompletionCelebration,
                // Collection(図鑑), AnimalDetail(交流), Share, Settings, Paywall
  widgets/      // アプリ固有のみ（共通UIはpetit_ui優先）
```

## データモデル
```
User { uid, plan(free/pro), streakDays, lastVisitAt, createdAt }
AnimalMaster { id, name, habitat, personalityTag, pixelArtId, rarity, reactionSetId }
UserAnimal { uid, animalId, unlockedAt, affectionLevel(1-4), lastInteractedAt, isDeclineWarned }
PuzzleSession { id, uid, animalId, startedAt, completedAt, mistakeCount }
HerdBonus { uid, habitat, completedCount, sceneUnlockedAt }
ShareAsset { id, uid, generatedAt, imageUrl }
```

## 実装順序（推奨）
1. petit_core/petit_ui導入 → 2. データモデル → 3. Service層（AffectionServiceのLv昇降ロジックを最優先で固める）
→ 4. 計測3点セット → 5. ViewModel(Riverpod)
→ 6. **Aha Moment最短動線を最優先**（起動→パズル→完成→動物1アクション=3タップ以内）
→ 7. 各画面View → 8. 個性別リアクションLottie・群れミニシーン → 9. 遷移
→ 10. オンボ＋ペイウォール（2体目完成後にトリガー、1体目は無料体験優先）
→ 11. なつき度低下（放置ペナルティ）ロジック＋復帰通知 → 12. 群れ形成判定
→ 13. エラーハンドリング → 14. テスト → 15. CI/CD → 16. リリース準備

## 計測（KPI 5個以内）
`aha_moment_reached`（初回動物アクション） / `animal_interacted`（なつき度更新） /
`herd_bonus_unlocked` / `share_created` / `paywall_converted`
※なつき度低下率をチャーン先行指標として追加監視（Remote Configでしきい値調整）

## 実装の注意点
- APIキー環境変数／全APIエラーハンドリング／メインスレッド／Ahaイベント最優先
- 44pt／バウンス／スケルトンUI／Lottie／ハプティクス／背景白無地NG／SE+ミュート
- petit_core/petit_ui再実装禁止／ペアレンタルゲート（課金導線のみ）／min_supported_version
- **【固有】なつき度・所持動物データはFirestoreルールでクライアント直接書込み禁止、交流はCloud Functions経由**（改ざん対策）
- **【固有】動物マスタ入稿はスプレッドシート→検証スクリプト（重複・NGワード）→Firestore投入のパイプラインを先に作る**（月次新動物2-3種、コンテンツ物量リスクへの直接対応策）
- **【要確認】** petit_aiでの絵柄自動生成パイプラインの実現性（未検証、⭐4/5判定時の残課題）
- **【要確認】** かずきさん自身の育成ゲーム嗜好（開発継続意欲の先行指標として要確認）
- **【要確認】** ストア出願前にタイトル「ぬりパズ動物園」の最終再確認

## 添付
データモデル詳細/API/画面フロー/計測設計/テスト戦略/批判的レビュー結果 → nuripazu_企画設計書_v1_0.md参照
