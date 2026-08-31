import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/models/index.dart';
import 'package:nuripazu/services/firestore_service.dart';
import 'user_provider.dart';

/// ユーザーが所有する動物リスト（ストリーム）
final userAnimalsProvider = StreamProvider<List<UserAnimal>>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    yield [];
    return;
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  yield* firestoreService.listUserAnimals(userId);
});

/// 動物マスタリスト（全動物、キャッシュ）
final animalMastersProvider = FutureProvider<List<AnimalMaster>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  // petit_ai生成動物も含まれる予定
  // 現在: placeholderとして1-3体のマスタデータを返す
  return []; // Firestore投入後に動的取得
});

/// 特定の動物マスタを取得
final animalMasterProvider =
    FutureProvider.family<AnimalMaster?, String>((ref, animalId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getAnimal(animalId);
});

/// ユーザーが所有する特定の動物情報
final userAnimalProvider =
    FutureProvider.family<UserAnimal?, String>((ref, animalId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUserAnimal(userId, animalId);
});

/// 所有動物数
final userAnimalCountProvider = Provider<int>((ref) {
  final animals = ref.watch(userAnimalsProvider);
  return animals.when(
    data: (list) => list.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// 全動物中の所有済み動物の割合（コンプ率）
final animalCompletionRateProvider = Provider<double>((ref) {
  final userAnimalsAsync = ref.watch(userAnimalsProvider);
  final animalMastersAsync = ref.watch(animalMastersProvider);

  return animalMastersAsync.when(
    data: (masters) {
      if (masters.isEmpty) return 0.0;
      return userAnimalsAsync.when(
        data: (owned) => owned.length / masters.length,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
