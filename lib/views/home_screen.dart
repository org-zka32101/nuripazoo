import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';

/// 動物園ホーム画面
/// ユーザーが集めた動物が住む園を眺める
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAnimalsAsync = ref.watch(userAnimalsProvider);
    final completionRate = ref.watch(animalCompletionRateProvider);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('ぬりパズ動物園'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: userAnimalsAsync.when(
        data: (animals) => SingleChildScrollView(
          child: Column(
            children: [
              // 動物園全景（園への入口）
              Container(
                height: 200,
                color: Colors.green.shade100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.forest,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'あなたの動物園 (${animals.length}体)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // コンプリート進捗
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'コンプリート度',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(completionRate * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: completionRate,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 集めた動物リスト
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '集めた動物たち',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    animals.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'まずは最初のパズルに挑戦しよう!',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: animals.length,
                            itemBuilder: (context, index) {
                              final animal = animals[index];
                              return _buildAnimalCard(context, animal);
                            },
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // パズル画面へ遷移
          Navigator.of(context).pushNamed('/puzzle');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimalCard(BuildContext context, dynamic animal) {
    return GestureDetector(
      onTap: () {
        // 動物詳細画面へ遷移
        Navigator.of(context).pushNamed(
          '/animal_detail',
          arguments: animal.animalId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 動物アイコン（placeholder）
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.pets,
                  size: 30,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 動物名
            Text(
              'ペット${animal.animalId}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // なつき度表示
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Lv${animal.affectionLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
