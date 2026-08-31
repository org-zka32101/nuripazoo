# ぬりパズ動物園 Cloud Functions

Firebase Cloud Functions による バックエンド ビジネスロジック実装。

## 🎯 目的

- **セキュリティ**: Firestore ルールで直接書込み禁止のデータをサーバー検証で保護
- **改ざん対策**: なつき度・所持動物の変更は Cloud Functions 経由に統一
- **スケーラビリティ**: リアルタイムイベント・定期実行の集約

## 📋 実装済み Functions

### 1️⃣ `interactWithAnimal` (Callable)
```dart
// クライアント呼び出し
final result = await FirebaseFunction.instance
  .httpsCallable('interactWithAnimal')
  .call({
    'uid': userId,
    'animalId': animalId,
    'interactionType': 'feed', // 'feed' | 'pet' | 'play'
  });
```

**機能**:
- なつき度 Lv1-4 を1段階上昇（最大Lv4で固定）
- 1日1回制限チェック（本日既に交流済みなら拒否）
- 改ざん対策（UID確認）
- Firebase Analytics イベント記録

**戻り値**:
```json
{
  "success": true,
  "newAffectionLevel": 2,
  "message": "Affection level increased to 2"
}
```

---

### 2️⃣ `updateLastVisit` (Callable)
```dart
// アプリ起動時に呼び出し（ストリーク判定用）
await FirebaseFunction.instance
  .httpsCallable('updateLastVisit')
  .call({});
```

**機能**:
- ユーザーの最終訪問日時を更新
- ストリーク計算の基準日として使用

---

### 3️⃣ `completeAnimal` (Callable)
```dart
// パズル完成時に呼び出し（Aha Moment）
final result = await FirebaseFunction.instance
  .httpsCallable('completeAnimal')
  .call({
    'uid': userId,
    'animalId': animalId,
  });
```

**機能**:
- 新規動物を Lv1 で登録
- `aha_moment_reached` イベント記録（KPI）
- 群れボーナス判定（生息地3体揃い）
- 群れ解放時は `herd_bonus_unlocked` イベント記録

**戻り値**:
```json
{
  "success": true,
  "newAnimal": true,
  "newHerdBonus": true,
  "habitat": "forest"
}
```

---

### 4️⃣ `onUserCreate` (Auth Trigger)
自動実行: ユーザー登録時

**機能**:
- Firestore に ユーザードキュメント作成
- 初期プラン: `free`
- 初期ストリーク: `0`
- `user_created` イベント記録

---

### 5️⃣ `checkAffectionDecline` (Scheduled)
実行: 毎日 02:00 (Asia/Tokyo)

**機能**:
- 全ユーザーの全動物をチェック
- 3日以上未交流の場合、Lv を1段階低下
- 低下時に `affection_declined` イベント記録
- 放置ペナルティ → 復帰ナッジの仕組み

---

## 🚀 セットアップ

### 1. 依存パッケージをインストール
```bash
cd functions
npm install
```

### 2. ローカルテスト（エミュレータ）
```bash
# Firebase エミュレータスイート起動
firebase emulators:start

# 別ウィンドウで functions を実行
npm run watch
```

### 3. デプロイ
```bash
# 本番環境にデプロイ
npm run deploy

# または
firebase deploy --only functions
```

---

## 🔐 セキュリティ設計

### Firestore ルール統合
```
- animals/: Cloud Functions のみ書込み可能
- herd_bonuses/: Cloud Functions のみ書込み可能
- users/: ユーザーのみ読取り、Cloud Functions が更新
```

### UID確認（改ざん対策）
```typescript
if (context.auth.uid !== uid) {
  throw new HttpsError('permission-denied', 'Unauthorized access');
}
```

---

## 📊 Analytics イベント一覧

| イベント | トリガー | 用途 |
|---------|---------|------|
| `aha_moment_reached` | パズル完成 | KR: 初回体験確認 |
| `animal_interacted` | 交流実行 | KR: 継続率測定 |
| `herd_bonus_unlocked` | 群れ3体揃い | KR: 中間目標達成 |
| `affection_declined` | 3日未交流 | チャーン先行指標 |
| `user_created` | ユーザー登録 | 新規ユーザー追跡 |

---

## 🧪 テスト

```bash
# Unit tests (Future implementation)
npm run test
```

---

## 📝 トラブルシューティング

### Cloud Functions がデプロイできない
```bash
# Firebase プロジェクト ID を確認
firebase projects:list

# .env に PROJECT_ID を設定
echo "FIREBASE_PROJECT_ID=nuripazu-xxx" > .env.local

# 再デプロイ
firebase deploy --only functions
```

### Firestore エミュレータが起動しない
```bash
# Java がインストールされているか確認
java -version

# Firebase CLI を更新
npm install -g firebase-tools@latest
```

---

## 📞 開発継続

Phase 2 の Cloud Functions 実装が完了しました。  
次は Flutter クライアント側で以下を実装：

1. **Riverpod Provider** でこれらの Callable Functions を ラッピング
2. **AffectionService** と Cloud Functions の統合
3. **Firebase Analytics** の計測設定

詳細は `../CLAUDE.md` 参照。
