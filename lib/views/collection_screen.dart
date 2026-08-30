import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';

/// 図鑑・コレクション画面
/// 全動物マスター表示。所持/未所持の区別表示
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalMastersAsync = ref.watch(animalMastersProvider);
    final userAnimalsAsync = ref.watch(userAnimalsProvider);
    final completionRateAsync = ref.watch(animalCompletionRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('図鑑'),
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
      ),
      body: userAnimalsAsync.when(
        data: (userAnimals) => animalMastersAsync.when(
          data: (animalMasters) => completionRateAsync.when(
            data: (completionRate) {
              // 所持IDセット
              final ownedIds =
                  userAnimals.map((a) => a.animalId).toSet();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // コンプリート進捗
                    _buildProgressHeader(completionRate),

                    // フィルタタブ
                    _buildFilterTabs(context),

                    const SizedBox(height: 16),

                    // 動物グリッド
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: animalMasters.length,
                        itemBuilder: (context, index) {
                          final master = animalMasters[index];
                          final isOwned = ownedIds.contains(master.animalId);
                          final userAnimal = userAnimals.firstWhere(
                            (a) => a.animalId == master.animalId,
                            orElse: () => null,
                          );

                          return _buildAnimalGridItem(
                            context,
                            master,
                            isOwned,
                            userAnimal,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('エラー: $error'),
            ),
          ),
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('エラー: $error'),
          ),
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  /// 進捗ヘッダー
  Widget _buildProgressHeader(double completionRate) {
    return Container(
      color: Colors.amber.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'コンプリート度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(completionRate * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(
                Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// フィルタタブ（プレースホルダー）
  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterChip('全て'),
          _buildFilterChip('所持中'),
          _buildFilterChip('未入手'),
        ],
      ),
    );
  }

  /// フィルタチップ
  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  /// 動物グリッドアイテム
  Widget _buildAnimalGridItem(
    BuildContext context,
    dynamic animalMaster,
    bool isOwned,
    dynamic userAnimal,
  ) {
    return GestureDetector(
      onTap: () {
        if (isOwned) {
          Navigator.of(context).pushNamed(
            '/animal_detail',
            arguments: animalMaster.animalId,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOwned ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwned ? Colors.amber : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isOwned
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOwned
                    ? Colors.amber.shade100
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.pets,
                  size: 28,
                  color: isOwned ? Colors.amber : Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 名前
            Text(
              animalMaster?.name ?? '不明',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOwned ? Colors.black : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // なつき度またはロック表示
            if (isOwned && userAnimal != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lv${userAnimal.affectionLevel}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              )
            else if (!isOwned)
              const Icon(
                Icons.lock,
                size: 14,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
