# Phase 9C: Pre-Launch Validation - KPI ゲート検証

**概要**: TestFlight 7-14 日間の本番環境テストで、リリース Go/No-Go を判定  
**実装期間**: 7-14 営業日  
**責任者**: QA・Analytics・Product チーム  
**ゲート条件**: 
- Crash-Free Rate ≥99.5% ✅
- Aha Moment Rate ≥60% ✅
- 重大バグなし ✅

---

## 前提条件

```yaml
実施環境:
  - Phase 9A + 9B が完全に完了している
  - TestFlight ビルドが App Store Connect に正常にアップロード済
  - Internal Testers グループが招待済
  - Firebase Analytics・Crashlytics が本番環境で動作中
  - Remote Config が設定済

テスター構成:
  - 内部テスター (開発チーム): 5-10 人
  - 外部テスター (コミュニティ): 50-500 人 (Day 1 Gate を通過した場合)
```

---

## KPI ゲート定義

### Gate 1: Crash-Free Rate ≥99.5%

**定義**: アプリがクラッシュしなかったセッションの割合

```
Crash-Free Rate = (Total Sessions - Crashing Sessions) / Total Sessions * 100

例:
  Total Sessions: 1,000
  Crashing Sessions: 3
  Crash-Free Rate: (1000 - 3) / 1000 * 100 = 99.7% ✅
```

**計測方法**:
```
Firebase Console > Crashlytics > Dashboard
  - Show: Crashes and ANRs
  - Filter: Last 7 days
  - Metric: Crash-free users (%)
```

**判定基準**:
- ✅ GO: ≥99.5% (許容クラッシュ数: 最大 5/1000 セッション)
- ⚠️ CAUTION: 98.0-99.5% (詳細調査→修正→再テスト)
- ❌ NO-GO: <98.0% (重大バグあり、修正が必須)

**重大バグの定義**:
- アプリ起動時のクラッシュ
- パズル解放時のクラッシュ
- 課金フローのクラッシュ
- ユーザーデータ損失につながるクラッシュ

---

### Gate 2: Aha Moment Rate ≥60%

**定義**: インストール後、なつき度交流まで到達したユーザーの割合

```
Aha Moment Rate = (Users who reached first affection interaction) / (Total installs) * 100

例:
  Total Installs: 100
  Users reached Aha: 65
  Aha Moment Rate: 65 / 100 * 100 = 65% ✅
```

**Aha Moment イベント**:
- Event: `aha_moment_reached`
- Trigger: 初めてのなつき度交流アクション実行時
- Expected user journey:
  1. Install app
  2. Tutorial/Onboarding
  3. First puzzle complete
  4. First animal appears
  5. **Interact with animal (Aha!)** ← Measurement point
  6. Affection level increases

**計測方法**:
```
Firebase Console > Analytics > Events > aha_moment_reached
  - Count: Total events
  - Filter: By date range (7 days)
  - Divide: Total installs in same period
  - Result: Percentage
```

**Dart 実装** (計測コード):
```dart
// lib/services/analytics_service.dart

Future<void> logAhaMomentReached(String animalId) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'aha_moment_reached',
    parameters: {
      'animal_id': animalId,
      'animal_personality': animalPersonality,
      'session_duration_seconds': _sessionDuration,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  // Crashlytics にも記録 (検証用)
  await FirebaseCrashlytics.instance.log(
    'Aha moment reached: Animal=$animalId',
  );
}
```

**判定基準**:
- ✅ GO: ≥60% (十分な継続動機 → リリース OK)
- ⚠️ CAUTION: 45-60% (オンボード改善検討 → 再テスト)
- ❌ NO-GO: <45% (Aha に到達しないユーザーが多い → デザイン見直し)

**改善施策** (Aha Rate が低い場合):
1. **Tutorial 改善**: オンボード・ダイアログを簡潔に
2. **First Puzzle 難易度調整**: 最初のパズルが簡単すぎ？
3. **Animal Unlock Timing**: 初動物を早めに出現させる
4. **Affection Interaction フロー**: タップ位置を明確に
5. **UX テスト**: 5-10 人のユーザー観察テスト

---

## Day-by-Day Testing Plan (7-14 days)

### Day 1-2: Internal Testing + Monitoring Setup

```yaml
Internal Testers (開発チーム):
  - 5-10 人のテスターが同時利用
  - 日々のクラッシュ・エラーログを監視
  - Firebase Crashlytics ダッシュボード確認 (4時間ごと)
  
Monitoring Setup:
  - Slack 通知: Crashlytics クラッシュ自動通知
    設定: Firebase Console > Crashlytics > Notifications
  - Email Alert: Daily summary (毎朝 8時)
  - Spreadsheet: Manual tracking (Crash count, Aha reach rate)
```

**Day 1-2 テスト項目**:
- [ ] インストール・アプリ起動
- [ ] Tutorial フロー完全完了
- [ ] First puzzle 解放・完成
- [ ] First animal 出現・交流
- [ ] なつき度 Lv 上昇確認
- [ ] 図鑑閲覧
- [ ] 設定変更 (音量、ダークモード)
- [ ] 広告表示 (バナー、リワード)
- [ ] 課金フロー (ダミー商品)

### Day 3-7: Stable Monitoring + Early Iteration

```yaml
期間: 最初の 1 週間

監視項目:
  - Crash-Free Rate: 毎日確認
  - Aha Moment Rate: 毎日確認 (時間ごと)
  - User retention: Day 1 retention 追跡
  - Session duration: 平均セッション時間
  
クラッシュ対応:
  - Critical (再現率 >50%): 即座に修正
  - High (再現率 20-50%): 1日以内に修正
  - Medium (再現率 <20%): 記録・後続版で修正
```

**日次レポート**:
```
【Daily Report - Day 3】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 KPI Status:

Crash-Free Rate:  98.8% (1 crash / 83 sessions)
  - Status: ⚠️ WATCH (Target: 99.5%)
  - Crash: Affection interaction - Memory leak?

Aha Moment Rate:  52% (52 / 100 installs)
  - Status: ⚠️ LOW (Target: 60%)
  - Issue: Onboarding too long, users drop off

Session Duration: 4.2 min (avg)
  - Status: OK
  - Note: Engage time good

Day 1 Retention:  65% (user returned next day)
  - Status: Good

🔧 Issues Found:
1. Affection interaction crash (HIGH)
   - Reproduce: Tap animal twice quickly
   - Fix: Add double-tap guard

2. Long onboarding (MEDIUM)
   - Measure: 3 min to first puzzle
   - Fix: Skip button or faster flow

✅ Actions for Day 4:
- Deploy hotfix for affection crash
- Streamline onboarding (30 sec shorter)
- Re-test with new build

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Day 8-14: Final Stabilization + Go/No-Go Decision

```yaml
期間: 後半 1 週間

活動:
  - Crash-Free Rate: ≥99.5% 持続確認
  - Aha Moment Rate: ≥60% 到達確認
  - 外部テスター フィードバック収集
  - 重大バグ 0 状態確認
  
外部テスター配布 (Day 8 以降):
  - 初回: 100 ユーザー (内部+友人)
  - 確認後: 500 ユーザーまで拡大
  - Phase: ベータ全体公開 (最大 10,000 ユーザー)
```

**Day 14 最終判定**:
```
┌─────────────────────────────────────────┐
│         Go/No-Go Decision Matrix        │
├─────────────────────────────────────────┤
│                                         │
│ Crash-Free Rate ≥99.5%      ✅ YES     │
│ Aha Moment Rate ≥60%        ✅ YES     │
│ Critical Bugs = 0           ✅ YES     │
│ Day 1 Retention ≥65%        ✅ YES     │
│                                         │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │
│                                         │
│ 🟢 GO TO PHASE 9D (App Store)          │
│                                         │
│ Launch Date: 2026-09-16                │
│                                         │
└─────────────────────────────────────────┘
```

---

## Firebase Analytics Queries (Measurement)

### Query 1: Crash-Free Rate

```sql
-- Firebase Crashlytics (UI) 方法

Firebase Console > Crashlytics > Dashboard
  - Time range: Last 7 days
  - Filter by: All users
  - Metric: Crash-free users (%)
  - Expected: ≥99.5%
```

### Query 2: Aha Moment Rate

```sql
-- Firebase Analytics (Custom Query)

Firebase Console > Analytics > Events > aha_moment_reached
  
Method 1: Simple Count
  - Select Event: aha_moment_reached
  - Count: Total events in last 7 days
  - Calculate: Divide by total installs

Method 2: Conversion Funnel
  Events tracked:
    1. app_launched (total installs)
    2. onboarding_completed
    3. first_puzzle_completed
    4. animal_appeared
    5. aha_moment_reached ← Measure this
  
  Conversion: (Event 5) / (Event 1) * 100 = Aha Rate
```

### Query 3: Day 1 Retention

```sql
Firebase Console > Analytics > Retention

Settings:
  - Start event: first_open
  - Return event: user_engagement
  - Cohort: By install date
  
Result shows: % of users who returned on Day 1, 2, 3, etc.
Target: ≥65% Day 1 retention
```

### Query 4: Session Duration

```sql
Firebase Console > Analytics > Events

Event: user_engagement
Metric: Duration (avg)
Expected: ≥3 minutes

Breakdown by:
  - Affection personality (check if personality affects engagement)
  - Device type (iPhone vs iPad)
  - OS version (iOS 14 vs 15 vs 16)
```

---

## Feedback Collection Framework

### Internal Testers (Day 1-7)

**Slack チャネル**: #testflight-feedback

```
【Form Template】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 Tester Name:
📅 Test Date:
⏱️ Session Duration:

🐛 Issues Found:
  - Bug: [Description]
    Reproduce: [Steps]
    Severity: 🔴 Critical / 🟡 High / 🟢 Low
  - (Add more bugs as found)

💬 Feedback:
  - What felt good?
  - What felt slow/confusing?
  - Would you recommend?

📸 Screenshots/Video: [Link]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### External Testers (Day 8+)

**TestFlight In-App Feedback**:
```
TestFlight > Feedback タブ > '+'
  - Built-in feedback form
  - Screenshots attached automatically
  - Sent to email + TestFlight console
```

**Spreadsheet Aggregation**:
```
Google Sheet: "Phase 9C Feedback Tracker"

Columns:
  - Tester Name
  - Report Date
  - Issue Category (Crash, UI, Performance, etc)
  - Description
  - Severity
  - Status (Open/Fixed/Wontfix)
  - Notes

Summary Metrics:
  - Total reports: [N]
  - Critical: [N]
  - High: [N]
  - Low: [N]
  - Resolution rate: [%]
```

---

## Go/No-Go Decision Criteria

### GO Conditions (All must pass)

✅ **Crash-Free Rate ≥99.5%**
  - Crashing sessions < 5/1000
  - No critical crashes reproducible
  - Memory leaks fixed

✅ **Aha Moment Rate ≥60%**
  - 60%+ users reach first affection interaction
  - Onboarding completion ≥80%
  - Drop-off points identified & addressed

✅ **Critical Bugs = 0**
  - No app-launch crashes
  - No data loss issues
  - No payment flow crashes

✅ **Day 1 Retention ≥65%**
  - Users return within 24 hours
  - Engagement depth good (session ≥3 min)

✅ **User Feedback Positive**
  - No major UX complaints
  - Core loop understood
  - Personality system working

### NO-GO Conditions (Any one fails)

❌ **Crash-Free Rate <98.0%**
  - Indicates systemic stability issues
  - Action: Debug, hotfix, re-test

❌ **Aha Moment Rate <45%**
  - Indicates onboarding/UX issues
  - Action: Redesign tutorial, re-test

❌ **Critical Bugs Found**
  - App-launch crashes
  - Payment loop failures
  - Data integrity issues
  - Action: Fix + regression test

❌ **Day 1 Retention <50%**
  - Indicates fundamental engagement issue
  - Action: Investigate core loop, redesign if needed

### CAUTION Conditions (Requires Review)

⚠️ **Crash-Free Rate 98.0-99.5%**
  - Action: Identify non-critical crashes → fix or accept
  - Re-test to confirm stability

⚠️ **Aha Moment Rate 45-60%**
  - Action: Analyze drop-off points → optimize onboarding
  - A/B test faster tutorial → re-measure

⚠️ **Day 1 Retention 50-65%**
  - Action: Examine why users don't return
  - Add push notification? Adjust difficulty?

---

## Rollback & Hotfix Procedures

### If Critical Bug Found (Day 5)

```bash
# 1. Identify & reproduce
Bug: Affection interaction crashes (reproducible 100%)
Root cause: Memory leak in Lottie animation

# 2. Hotfix development
  - Branch: hotfix/affection-crash
  - Fix: Add animation cleanup + memory management
  - Test locally: 20 device types

# 3. Build & TestFlight
  - Increment build number: 1 → 2
  - Build Release: ./scripts/build_testflight.sh --build 2
  - Upload via Transporter

# 4. Re-test
  - Internal testers: Verify fix
  - Reproduce crash: ❌ (Fixed!)
  - Session duration: ≥3 min (OK)

# 5. Continue testing
  - Restart Day 1 clock? Or continue?
  - Recommendation: Continue (momentum), but reset crash metrics
```

### If Aha Rate Low (Day 7)

```
Analysis: Only 48% reach Aha (target: 60%)

Drop-off points:
  1. Onboarding: 100 → 85 (15% drop) ✅ OK
  2. First puzzle: 85 → 68 (20% drop) ⚠️ HIGH
  3. Animal appear: 68 → 55 (19% drop) ⚠️ HIGH
  4. Affection: 55 → 48 (13% drop) ⚠️ Aha! LOW

Hypothesis: First puzzle is too hard

Actions:
  1. A/B test: Easier first puzzle variant
  2. Remote Config: affection_unlock_puzzle_difficulty = "easy"
  3. Re-deploy build 2
  4. Measure again Day 8
```

---

## Checklist: Phase 9C 実行

### Pre-Launch (Day -2)

- [ ] TestFlight ビルド正常にアップロード
- [ ] Internal Testers メール招待送信
- [ ] Firebase Crashlytics ダッシュボード確認
- [ ] Analytics イベント (aha_moment_reached など) が送信されるか事前テスト
- [ ] Slack #testflight-feedback チャネル作成
- [ ] Google Sheet "Phase 9C Feedback Tracker" 作成
- [ ] Daily report テンプレート準備

### Phase 9C Execution (Day 1-7)

- [ ] Day 1: Internal testers 招待メール送信
- [ ] Day 1-7: 毎日 Crash-Free Rate 確認
- [ ] Day 1-7: 毎日 Aha Moment Rate 確認
- [ ] Day 2: Crash が発見されたら、根本原因調査
- [ ] Day 3-5: クリティカルなバグを修正 → hotfix build 作成
- [ ] Day 5: Crash-Free Rate ≥99% 確認後、外部テスト準備
- [ ] Day 7: 1 週間集計 → KPI 確認

### Day 8-14 Stabilization

- [ ] Day 8: External testers 100 人に配布 (友人枠)
- [ ] Day 8-14: Crash-Free Rate ≥99.5% 持続確認
- [ ] Day 8-14: Aha Moment Rate ≥60% 到達確認
- [ ] Day 10: 外部テスター フィードバック集約
- [ ] Day 12: 微調整 (リモートコンフィグ) 必要か判断
- [ ] Day 14: Go/No-Go 最終決定会議

### Go Decision時

- [ ] Phase 9D スケジューリング (App Store 準備)
- [ ] リリース日確定
- [ ] PRメッセージ作成
- [ ] App Store スクリーンショット準備
- [ ] App Store メタデータ最終確認

### No-Go Decision時

- [ ] 問題の根本原因分析
- [ ] 修正計画 → 実装 → 再テスト スケジュール
- [ ] ステークホルダー通知
- [ ] 新しいテスト開始日確定

---

## Success Metrics Summary

```
┌────────────────────────────────────────────────────┐
│         Phase 9C Success Indicators                │
├────────────────────────────────────────────────────┤
│                                                    │
│ 🎯 Primary KPIs (Go/No-Go Gating)                 │
│   • Crash-Free Rate: 99.5%+ ✅                    │
│   • Aha Moment Rate: 60%+ ✅                      │
│   • Critical Bugs: 0 ✅                           │
│                                                    │
│ 📊 Secondary Metrics (Health Check)               │
│   • Day 1 Retention: 65%+                        │
│   • Session Duration: 3+ min                      │
│   • Positive Feedback: 80%+                       │
│                                                    │
│ 🚀 Confidence Level (Go to Phase 9D)             │
│   • All primary KPIs met: HIGH confidence        │
│   • Ready for App Store release                  │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Related Documents

- **PHASE_9_TESTFLIGHT_STORE_SUBMISSION.md**: Phase 9 全体プレイブック
- **PHASE_9_PRELAUNCH_CHECKLIST.md**: 90+ 項目実行チェックリスト
- **PHASE_9C_FEEDBACK_ANALYSIS.md**: (Next) フィードバック分析テンプレート

---

**更新日**: 2026-09-02  
**ステータス**: Phase 9C Pre-Launch Validation Guide v1.0  
**責任者**: Claude Code - Phase 9C 実装設計
