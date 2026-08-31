import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 課金・マネタイズ関連プロバイダ
/// RevenueCat 統合予定

/// ユーザーのサブスクリプション状態
class SubscriptionState {
  final bool isPremium;
  final bool isAdsRemoved;
  final DateTime? expiryDate;

  SubscriptionState({
    required this.isPremium,
    required this.isAdsRemoved,
    this.expiryDate,
  });

  factory SubscriptionState.free() => SubscriptionState(
    isPremium: false,
    isAdsRemoved: false,
  );
}

/// ユーザーのサブスクリプション状態を取得
/// 【実装予定】RevenueCat で fetchCustomerInfo()
final subscriptionStateProvider =
    FutureProvider<SubscriptionState>((ref) async {
  // TODO: RevenueCat 統合
  // final rc = Purchases.sharedInstance;
  // final customerInfo = await rc.getCustomerInfo();
  // return SubscriptionState(
  //   isPremium: customerInfo.entitlements.active.containsKey('premium'),
  //   isAdsRemoved: customerInfo.entitlements.active.containsKey('no_ads'),
  // );

  // 仮実装：無料プラン
  return SubscriptionState.free();
});

/// Premium サブスク購入
/// 【実装予定】RevenueCat で purchasePackage()
final purchasePremiumProvider =
    FutureProvider<bool>((ref) async {
  // TODO: RevenueCat 統合
  // final rc = Purchases.sharedInstance;
  // try {
  //   await rc.purchasePackage(package);
  //   return true;
  // } catch (e) {
  //   return false;
  // }

  return false;
});

/// 広告動画視聴完了イベント
/// 【実装予定】Google Mobile Ads で RewardedAd
final watchAdForRewardProvider =
    FutureProvider<int>((ref) async {
  // TODO: Google Mobile Ads 統合
  // final ad = RewardedAd(
  //   adUnitId: Platform.isAndroid
  //       ? 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'
  //       : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',
  //   request: AdRequest(),
  // );
  // return await ad.show(onUserEarnedReward: (ad, reward) {
  //   return reward.amount as int;
  // });

  return 0; // 報酬額
});

/// ユーザーの所持ゴールド/ポイント
final userPointsProvider =
    FutureProvider<int>((ref) async {
  // TODO: Firestore で user.points を取得
  return 0;
});

/// ポイント消費（IAP/課金実行）
final consumePointsProvider =
    FutureProvider.family<bool, int>((ref, points) async {
  // TODO: Cloud Functions で pointsDeductで実装
  return true;
});

/// コスメティックアイテム所持判定
final ownsCosmeticProvider =
    FutureProvider.family<bool, String>((ref, cosmeticId) async {
  // TODO: Firestore で user.cosmetics[cosmeticId] を確認
  return false;
});

/// ユーザーが見た広告数（日次）
final adWatchCountProvider =
    FutureProvider<int>((ref) async {
  // TODO: Firestore で user.adWatchCount を取得
  return 0;
});

/// 広告視聴上限（1日3回まで等）
final maxAdWatchesPerDayProvider =
    Provider<int>((ref) {
  return 3; // Remote Config で動的に設定可能
});

/// 本日の広告視聴可能回数
final remainingAdWatchesProvider = Provider<int>((ref) {
  final watched = ref.watch(adWatchCountProvider);
  final max = ref.watch(maxAdWatchesPerDayProvider);

  return watched.when(
    data: (count) => max - count,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// IAP 対応コスメティック一覧
class CosmeticItem {
  final String id;
  final String name;
  final String icon;
  final String category; // 'accessory' | 'decoration' | 'background'
  final int pricePoints;
  final String? description;

  CosmeticItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.pricePoints,
    this.description,
  });
}

/// IAP コスメティック一覧取得
final cosmeticItemsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  // TODO: Firestore から cosmetics コレクションを取得
  return [
    CosmeticItem(
      id: 'crown',
      name: '王冠',
      icon: '👑',
      category: 'accessory',
      pricePoints: 240,
    ),
    CosmeticItem(
      id: 'necklace',
      name: 'ネックレス',
      icon: '💎',
      category: 'accessory',
      pricePoints: 240,
    ),
    CosmeticItem(
      id: 'sunglasses',
      name: 'サングラス',
      icon: '😎',
      category: 'accessory',
      pricePoints: 240,
    ),
    CosmeticItem(
      id: 'ribbon',
      name: 'リボン',
      icon: '🎀',
      category: 'accessory',
      pricePoints: 180,
    ),
    CosmeticItem(
      id: 'bench',
      name: 'ベンチ',
      icon: '🪑',
      category: 'decoration',
      pricePoints: 480,
    ),
    CosmeticItem(
      id: 'light',
      name: 'ライト',
      icon: '💡',
      category: 'decoration',
      pricePoints: 480,
    ),
    CosmeticItem(
      id: 'pond',
      name: '池',
      icon: '💧',
      category: 'decoration',
      pricePoints: 720,
    ),
    CosmeticItem(
      id: 'flower',
      name: '花壇',
      icon: '🌸',
      category: 'decoration',
      pricePoints: 480,
    ),
  ];
});

/// 課金イベント記録（KPI）
final recordPaywallEventProvider =
    FutureProvider.family<void, String>((ref, action) async {
  // TODO: Firebase Analytics で paywall_viewed / paywall_converted を記録
  // Firebase Analytics で:
  // - action='viewed': ペイウォール表示時
  // - action='converted': 購読開始時
  // - action='dismissed': キャンセル時
});
