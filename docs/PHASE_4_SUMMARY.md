# Phase 4: 継続要素 (Continuation Features) - 実装完了

## 概要

Phase 4では、ユーザーの継続的なエンゲージメントを実現するための機能セットを実装しました。
Aha Momentの後、毎日のサイクルに組み込まれる要素群となります。

**目標**: Day7 リテンション 18% を実現するための日々の交流・育成・収集の循環

---

## 実装完了項目

### 1. 動物詳細・交流画面 (`animal_detail_screen.dart`)

**責務**: ユーザーが獲得した動物との日々の交流を実現

**主要機能**:
- 動物情報表示
  - 動物アイコン、名前、個性タグ表示
  - なつき度 Lv (1-4) の色分け表示
  - Lv別の説明文 ("初対面..." → "心の友！")

- **なつき度低下警告**
  - 「あと N 日で交流できなくなります」表示
  - 残り1日以下で赤色警告
  - リテンション指標として機能

- **日替わり交流アクション**
  - 「エサをあげる」「なでなで」「遊ぶ」の3オプション
  - 1日1回制限（`hasInteractedTodayProvider` で確認）
  - 実行後は成功メッセージ表示 + 画面リセット
  
- **群れボーナス情報**
  - 同じ生息地の3体揃い状態表示
  - 中間目標として会話の口実を提供

**技術**:
- Riverpod FutureProvider.family で実装
- Cloud Functions 呼び出し (`interactWithAnimalProvider`)
- StreamRefresh で画面状態リセット

---

### 2. 図鑑・コレクション画面 (`collection_screen.dart`)

**責務**: 全動物マスター表示。収集進行度の可視化

**主要機能**:
- **コンプリート進捗表示**
  - 全体進捗パーセンテージ（LinearProgressIndicator）
  - `animalCompletionRateProvider` で計算
  
- **フィルタタブ**（プレースホルダー）
  - 「全て」「所持中」「未入手」の切り替え可能

- **動物グリッド表示**
  - 3列 GridView
  - **所持動物**: 白背景 + 琥珀色枠 + なつき度Lvバッジ
  - **未所持動物**: グレー背景 + グレー枠 + ロックアイコン

- **タップ動作**
  - 所持動物をタップ → 詳細画面へ遷移
  - 未所持動物をタップ → 何もしない（将来: パズル推奨）

**技術**:
- `userAnimalsProvider` と `animalMastersProvider` の組み合わせ
- Set 操作で所持判定を効率化

---

### 3. 設定画面 (`settings_screen.dart`)

**責務**: ユーザー設定・アカウント情報・ログアウト

**セクション構成**:

1. **アカウント**
   - ユーザーID（モノスペース表示）
   - プラン（free/pro）
   - 連続プレイ日数（オレンジ強調）

2. **通知設定**
   - なつき度低下リマインド（ON）
   - デイリーチャレンジ（OFF）
   - イベント通知（ON）
   - スイッチトグル（UI実装、ロジック未実装）

3. **サウンド設定**
   - BGM、SE、動物の鳴き声
   - 各オン/オフ切り替え（UI実装）

4. **データ管理**
   - キャッシュ削除
   - 利用規約リンク
   - プライバシーポリシーリンク

5. **ログアウト**
   - 確認ダイアログ表示
   - `userSignOutProvider` で実行
   - 成功後 → `/onboarding` へ遷移

**技術**:
- `currentUserProvider` で ユーザー情報取得
- `userSignOutProvider` でログアウト
- Firebase Auth 統合

---

### 4. アプリシェル・ボトムナビゲーション (`app_shell.dart`)

**責務**: メイン3画面の統合ナビゲーション

**構成**:
- `AppShell` (ConsumerWidget): 高階コンポーネント
- `AppShellContent` (StatefulWidget): 状態管理
  - `_currentIndex` でタブ状態を保持
  - State リセット時も状態を保持（重要）

**ボトムナビゲーションバー**:
- **タブ1**: 動物園（HomeScreen）→ `Icons.home`
- **タブ2**: 図鑑（CollectionScreen）→ `Icons.collections_bookmark`
- **タブ3**: 設定（SettingsScreen）→ `Icons.settings`

**技術**:
- `BottomNavigationBar` with `type: BottomNavigationBarType.fixed`
- Stateful だからこそタブ切り替え時に画面リセットされない

---

### 5. 群れシーン画面 (`herd_scene_screen.dart`)

**責務**: 群れボーナス解放時の祝福演出

**主要機能**:
- **自動消滅タイマー**
  - 3秒後に自動で前画面に戻る
  - `Future.delayed` + `Navigator.pop()`

- **背景色（生息地別）**
  - forest → 緑
  - ocean → 青
  - grassland → 琥珀
  - mountain → グレー
  - sky → シアン

- **演出UI**
  - 中央に白い円形コンテナ
  - ペットアイコン + "群れボーナス解放！" テキスト
  - 影付きテキスト（可読性確保）

**今後の拡張ポイント**:
- Lottie アニメーション統合
- 生息地ごとの背景画像
- サウンド効果（動物の鳴き声や音楽）

---

## 画面遷移フロー（Phase 4 完成形）

```
OnboardingScreen
  ↓
PuzzleScreen (Aha Moment)
  ↓ [パズル完成]
HomeScreen (AppShell > タブ0)
  ↓
  ├─ FAB「+」 → PuzzleScreen
  ├─ 動物カード → AnimalDetailScreen
  └─ ボトムナビ
     ├─ 図鑑 → CollectionScreen (AppShell > タブ1)
     │   └─ 所持動物 → AnimalDetailScreen
     └─ 設定 → SettingsScreen (AppShell > タブ2)
        └─ ログアウト → OnboardingScreen

AnimalDetailScreen
  ↓
  ├─ 交流ボタン → interactWithAnimalProvider (Cloud Functions)
  │  ↓ [成功]
  │  └─ HerdSceneScreen (3体揃いの場合)
  │     ↓ [3秒待機]
  │     └─ 前画面に戻る
  └─ 戻る → 前画面に戻る
```

---

## Riverpod プロバイダの役割分担

### Phase 4で活用するプロバイダ

| プロバイダ | 型 | 責務 |
|-----------|-----|------|
| `userAnimalsProvider` | StreamProvider | 所持動物リスト（リアルタイム） |
| `animalMastersProvider` | FutureProvider | 全動物マスター（キャッシュ） |
| `userAnimalProvider` | FutureProvider.family | 特定の所持動物 |
| `animalMasterProvider` | FutureProvider.family | 特定の動物マスター |
| `animalCompletionRateProvider` | Provider | コンプリート率計算 |
| `hasInteractedTodayProvider` | FutureProvider.family | 本日交流済み判定 |
| `daysToAffectionDeclineProvider` | FutureProvider.family | 低下まで何日か |
| `herdBonusProvider` | FutureProvider.family | 群れボーナス確認 |
| `interactWithAnimalProvider` | FutureProvider.family | 交流実行 (CF) |
| `currentUserProvider` | FutureProvider | 現在のユーザー |
| `userSignOutProvider` | FutureProvider | ログアウト |

---

## 重要な実装パターン

### 1. 日替わり交流の1回制限

```dart
// AnimalDetailScreen で hasInteractedAsync を確認
hasInteractedAsync.when(
  data: (hasInteracted) => hasInteracted
      ? Container(...「今日は既に交流しました」...)
      : Column(...交流ボタン表示...),
)
```

**Cloud Functions 側**（Phase 2で実装済み）:
- `interactWithAnimal()` で `lastInteractedAt` をチェック
- 同日に複数回呼ばれた場合は拒否

### 2. なつき度低下警告の表示

```dart
daysUntilDeclineAsync.when(
  data: (days) => days <= 1
      ? Container(...赤色警告...)
      : Text('あと${days}日...'),
)
```

このアラートが **復帰ナッジ** として機能 → Day7 リテンション向上

### 3. 所持判定の効率的な実装

```dart
final ownedIds = userAnimals.map((a) => a.animalId).toSet();
// ... 後で
final isOwned = ownedIds.contains(master.animalId);
```

GridView 再構築時の O(1) 判定を実現

---

## テスト対象（推奨）

### Unit テスト
- 群れボーナス判定ロジック（3体同じ habitat）
- なつき度Lvの色分け関数

### Widget テスト
- AnimalDetailScreen の低下警告表示
- CollectionScreen のグリッドレンダリング
- SettingsScreen のログアウトダイアログ

### Integration テスト
- 動物詳細 → 交流 → ホーム戻却（全フロー）
- コレクション → 詳細 → 交流 → 群れシーン

---

## 今後の実装予定（Phase 5以降）

1. **Lottie アニメーション統合**
   - 個性別リアクション演出
   - 群れシーンのアニメーション
   - 完成演出の高度化

2. **背景画像・ピクセルアート**
   - 生息地ごとの背景
   - 動物アイコンの実画像化

3. **サウンド・SE システム**
   - BGM 再生
   - 交流時の効果音
   - 動物の鳴き声（個別）

4. **プッシュ通知**
   - なつき度低下リマインド
   - デイリーチャレンジ通知

5. **分析・Remote Config**
   - KPI イベントの詳細化
   - 通知閾値の動的調整

6. **ペイウォール・課金**
   - 2体目パズル完成後トリガー
   - コスメ課金（見た目彩り）
   - サブスク（時短）

---

## コミット メッセージ

```
Phase 4: 継続要素実装 - 日々の交流・図鑑・設定・ボトムナビ

実装内容:
- AnimalDetailScreen: 日替わり交流 + なつき度Lv表示
- CollectionScreen: 全動物図鑑 + コンプリート進捗
- SettingsScreen: ユーザー設定・通知・ログアウト
- AppShell: ボトムナビゲーション (動物園/図鑑/設定)
- HerdSceneScreen: 群れボーナス祝福演出 (3秒自動消滅)

改善内容:
- main.dart の動物詳細ルーティング実装
- views/index.dart の全スクリーン export 追加
- Riverpod 連携: interactWithAnimal() Cloud Functions 統合

テスト対象:
- 日替わり交流の1回制限
- なつき度Lv低下警告
- 図鑑のグリッド表示 (所持/未所持)
- ボトムナビ切り替え時の状態保持
```

---

## 技術的な注記

- **Stateful AppShell**: ボトムナビバー再構築時に State が保たれるよう設計
- **FutureProvider.family**: 動物ID ごとに独立したキャッシュを持つ
- **Cloud Functions 依存**: 交流実行は必ず CF 経由（改ざん防止）
- **オフライン対応**: 画面表示はオフライン OK、交流実行はオンライン必須

