import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/models/index.dart';
import 'package:nuripazu/services/affection_service.dart';
import 'user_provider.dart';
import 'animal_provider.dart';

/// 動物と交流（なつき度を上昇させる）
final interactWithAnimalProvider = FutureProvider.family<void, String>(
  (ref, animalId) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    // Cloud Functions を呼び出し
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('interactWithAnimal');

    try {
      await callable.call({
        'uid': userId,
        'animalId': animalId,
        'interactionType': 'pet', // TODO: ランダムに選択
      });

      // 成功後、userAnimalsProvider をリフレッシュ
      ref.refresh(userAnimalsProvider);
    } catch (e) {
      throw Exception('Interaction failed: $e');
    }
  },
);

/// 特定の動物のなつき度レベル
final affectionLevelProvider =
    FutureProvider.family<int, String>((ref, animalId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 1;

  final userAnimal = await ref.watch(userAnimalProvider(animalId).future);
  return userAnimal?.affectionLevel ?? 1;
});

/// なつき度レベルの説明（Lv1-4）
final affectionLevelDescriptionProvider =
    Provider.family<String, int>((ref, level) {
  return AffectionService.getAffectionLevelDescription(level);
});

/// Lv4到達で専用ポーズが解放されたか
final isSpecialPoseUnlockedProvider =
    FutureProvider.family<bool, String>((ref, animalId) async {
  final level = await ref.watch(affectionLevelProvider(animalId).future);
  return AffectionService.isSpecialPoseUnlocked(level);
});

/// 本日の交流済み判定
final hasInteractedTodayProvider =
    FutureProvider.family<bool, String>((ref, animalId) async {
  final userAnimal = await ref.watch(userAnimalProvider(animalId).future);
  if (userAnimal == null) return false;

  return AffectionService.hasInteractedToday(userAnimal.lastInteractedAt);
});

/// なつき度が低下するまでの残り日数
final daysToAffectionDeclineProvider =
    FutureProvider.family<int, String>((ref, animalId) async {
  final userAnimal = await ref.watch(userAnimalProvider(animalId).future);
  if (userAnimal == null) return 3;

  final daysSinceInteraction = DateTime.now()
      .difference(userAnimal.lastInteractedAt)
      .inDays;

  return (3 - daysSinceInteraction).clamp(0, 3);
});

/// 動物と交流可能か判定（1日1回制限）
final canInteractProvider =
    FutureProvider.family<bool, String>((ref, animalId) async {
  final hasInteracted = await ref.watch(
    hasInteractedTodayProvider(animalId).future,
  );
  return !hasInteracted;
});

/// パズル完成後になつき度 Lv1で登録（Aha Moment）
final registerNewAnimalProvider = FutureProvider.family<void, String>(
  (ref, animalId) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    // Cloud Functions: completeAnimal を呼び出し
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('completeAnimal');

    try {
      final result = await callable.call({
        'uid': userId,
        'animalId': animalId,
      });

      // aha_moment_reached イベントが自動記録される
      // herd_bonus も自動判定される

      // userAnimalsProvider をリフレッシュ
      ref.refresh(userAnimalsProvider);

      return result.data;
    } catch (e) {
      throw Exception('Failed to register new animal: $e');
    }
  },
);

/// 群れボーナス判定（生息地3体揃い）
final herdBonusProvider = FutureProvider.family<bool, String>(
  (ref, habitat) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return false;

    final animals = await ref.watch(userAnimalsProvider.future);

    // 同じ生息地の動物マスタを取得
    final masters = await ref.watch(animalMastersProvider.future);

    final animalIdsInHabitat = masters
        .where((m) => m.habitat.toString() == habitat)
        .map((m) => m.id)
        .toSet();

    final ownedInHabitat = animals
        .where((ua) => animalIdsInHabitat.contains(ua.animalId))
        .length;

    return ownedInHabitat >= 3;
  },
);
