# Phase 9C: Pre-Launch Validation - Quick Reference

**用途**: 7-14 日間の KPI ゲート検証のチェックリスト  
**対象**: QA・Analytics・Product マネージャー  

---

## 🎯 3 つの KPI Gate

| Gate | Target | Measurement | Go/No-Go |
|------|--------|-------------|----------|
| **Crash-Free Rate** | ≥99.5% | Firebase Crashlytics | <98%: NO-GO |
| **Aha Moment Rate** | ≥60% | Firebase Analytics | <45%: NO-GO |
| **Critical Bugs** | = 0 | Manual testing | Any found: NO-GO |

---

## 📅 7-Day Testing Timeline

### Day 1-2: Setup + Internal Testing

```bash
✓ TestFlight ビルド → App Store Connect アップロード
✓ Internal testers (5-10人) 招待メール送信
✓ Firebase Crashlytics ダッシュボード確認
✓ Analytics イベント送信テスト
```

**チェック項目**:
- [ ] App launch (no crash)
- [ ] Tutorial completion
- [ ] First puzzle complete
- [ ] First animal interaction
- [ ] Affection level increase
- [ ] Ads display (banner, rewarded)
- [ ] Payment flow (dummy)

### Day 3-7: KPI Monitoring

```bash
Daily Check (morning + evening):
  ✓ Firebase > Crashlytics: Crash-Free Rate
  ✓ Firebase > Analytics > aha_moment_reached: Aha Rate
  ✓ Slack #testflight-feedback: New issues
```

**Daily Targets**:
- Crash-Free: Keep ≥99.0%
- Aha Rate: Track trend (50% → 55% → 60%)
- Critical Bugs: Fix same day

---

## 📊 Firebase Queries (Copy-Paste)

### Query 1: Crash-Free Rate
```
Firebase Console > Crashlytics > Dashboard
  Filter: Last 7 days
  Metric: Crash-free users (%)
  Target: ≥99.5%
```

### Query 2: Aha Moment Rate
```
Firebase Console > Analytics > Events
  Event: aha_moment_reached
  Count: Total events (last 7 days)
  Divide by: Total app installs (same period)
  Formula: (Aha events / Total installs) * 100
  Target: ≥60%
```

### Query 3: Day 1 Retention
```
Firebase Console > Analytics > Retention
  Start event: first_open
  Return event: user_engagement
  Result: Day 1 cohort return %
  Target: ≥65%
```

---

## 🔴 Crisis Response

### If Crash-Free Rate < 98%

```
1. Identify crash type
   Firebase > Crashlytics > Latest crash > Stack trace

2. Reproduce locally
   - Device type
   - Steps to reproduce
   - Frequency (random? 100% reproducible?)

3. Fix & Test
   - Branch: hotfix/[issue-name]
   - Local test: ≥10 runs
   - Build number: Increment
   - Build release: ./scripts/build_testflight.sh --build N

4. Deploy & Verify
   - Upload to TestFlight
   - Internal testers: Test fix
   - Wait: Crash count → 0
   - Confirm: Crash-Free ≥99.5%
```

### If Aha Rate < 50%

```
1. Find drop-off point
   Firebase > Events funnel:
   - app_launched (100%)
   - onboarding_completed (?)
   - first_puzzle_completed (?)
   - animal_appeared (?)
   - aha_moment_reached (?)

2. Analyze the leak
   Example: 80% → 65% (15% drop at first_puzzle)
   Hypothesis: First puzzle too hard

3. A/B Test Quick Fix
   Firebase > Remote Config
   Set: first_puzzle_difficulty = "easy"
   Deploy: Push new settings
   Measure: Day +1 Aha rate

4. Iterate
   If Aha ≥60%: Keep change
   If Aha <60%: Try next improvement
```

---

## ✅ Go/No-Go Checklist (Day 7)

### Must Pass All ✅

```
□ Crash-Free Rate ≥99.5%
  Evidence: Crashlytics screenshot
  
□ Aha Moment Rate ≥60%
  Evidence: Analytics query result
  
□ Critical Bugs = 0
  Evidence: No P0 issues open
  
□ Day 1 Retention ≥65%
  Evidence: Retention report
  
□ Testers Happy
  Evidence: Feedback positive, no 🔴 reviews
```

### Result

```
All ✅? → 🟢 GO TO PHASE 9D (App Store)

Missing any? → 🔴 NO-GO
  Action: Fix + retry Phase 9C
  Duration: +3-7 days
```

---

## 📝 Daily Report Template

```markdown
## Phase 9C - Day 3 Report

### KPI Status
- Crash-Free Rate: 98.8% (target: 99.5%) ⚠️
- Aha Moment Rate: 52% (target: 60%) ⚠️
- Critical Bugs: 1 (FIXING)

### Issues Found
1. **Affection interaction crash** (HIGH)
   - Reproduce: Tap animal 2x quickly
   - Fix: Double-tap guard
   - Status: Fix deployed to build 2

2. **Long onboarding** (MEDIUM)
   - Issue: 3 min to first puzzle
   - Fix: Skip dialog
   - Status: Testing

### Actions for Day 4
- [ ] Build 2 deployed, re-test crash
- [ ] Monitor Crash-Free rate
- [ ] Test onboarding skip

### Metrics
- Total Sessions: 150
- Crashes: 2 (1 affection, 1 memory)
- Installs: 95
- Aha events: 48
- D1 Retention: 68%
```

---

## 🚨 Escalation Path

| Issue | Severity | Action | Owner |
|-------|----------|--------|-------|
| Crash-Free <98% | 🔴 CRITICAL | Stop testing, debug now | Dev Lead |
| Aha Rate <45% | 🔴 CRITICAL | Redesign onboarding | Product |
| Payment crash | 🔴 CRITICAL | Revert, fix, re-test | Dev |
| Memory leak | 🟠 HIGH | Fix + hotfix deploy | Dev |
| UI bug | 🟡 MEDIUM | Log + next version | Dev |
| Typo | 🟢 LOW | Ignore (or fix later) | - |

---

## 📞 Key Links

- **Firebase Crashlytics**: https://console.firebase.google.com/
- **TestFlight**: https://appstoreconnect.apple.com/
- **Slack #testflight-feedback**: (Internal)
- **Spreadsheet - Feedback Tracker**: (Shared doc)

---

## ⏱️ Timeline Summary

```
Day 1-2   → Internal Testing Setup
Day 3-7   → KPI Monitoring + Hotfixes
Day 8-14  → External Testing + Final Verification
Day 14    → Go/No-Go Decision

GO?
  ✅ Yes → Phase 9D (App Store, Day 15)
  ❌ No  → Fix + Phase 9C retry
```

---

**Version**: 1.0  
**Phase**: 9C Pre-Launch Validation  
**Duration**: 7-14 days
