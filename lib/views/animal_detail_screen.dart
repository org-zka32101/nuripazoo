import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';
import 'package:nuripazu/widgets/lottie_animation_widget.dart';

/// 動物詳細画面・交流画面
/// なつき度Lv表示、日替わり交流アクション、群れボーナス確認
class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;

  const AnimalDetailScreen({
    Key? key,
    required this.animalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAnimalAsync = ref.watch(userAnimalProvider(animalId));
    final animalMasterAsync = ref.watch(animalMasterProvider(animalId));
    final hasInteractedAsync = ref.watch(hasInteractedTodayProvider(animalId));
    final daysUntilDeclineAsync = ref.watch(daysToAffectionDeclineProvider(animalId));
    final herdBonusAsync = ref.watch(herdBonusProvider(animalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('動物詳細'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: userAnimalAsync.when(
        data: (userAnimal) => animalMasterAsync.when(
          data: (animalMaster) => SingleChildScrollView(
            child: Column(
              children: [
                // 動物情報
                _buildAnimalHeader(context, userAnimal, animalMaster),

                const SizedBox(height: 24),

                // なつき度表示
                _buildAffectionDisplay(
                  context,
                  userAnimal,
                  daysUntilDeclineAsync,
                ),

                const SizedBox(height: 24),

                // 交流アクション
                _buildInteractionSection(
                  context,
                  ref,
                  userAnimal,
                  hasInteractedAsync,
                  animalMaster,
                ),

                const SizedBox(height: 24),

                // 群れボーナス情報
                _buildHerdBonusInfo(context, herdBonusAsync, animalMaster),

                const SizedBox(height: 32),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('エラー: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  /// 動物ヘッダー情報
  Widget _buildAnimalHeader(
    BuildContext context,
    dynamic userAnimal,
    dynamic animalMaster,
  ) {
    return Container(
      color: Colors.orange.shade50,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 動物アイコン
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.pets,
                size: 60,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 動物名
          Text(
            animalMaster?.name ?? 'ペット${userAnimal.animalId}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 個性タグ表示
          if (animalMaster?.personalityTag != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                animalMaster!.personalityTag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// なつき度表示セクション
  Widget _buildAffectionDisplay(
    BuildContext context,
    dynamic userAnimal,
    AsyncValue<int> daysUntilDeclineAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'なつき度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Lvバッジ
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _affectionColor(userAnimal.affectionLevel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lv${userAnimal.affectionLevel}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _affectionDescription(userAnimal.affectionLevel),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 低下警告
          daysUntilDeclineAsync.when(
            data: (days) => days <= 1
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚠️ あと${days}日で交流できなくなります',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : days > 0
                    ? Text(
                        '次の低下まで あと${days}日',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : const Text(
                        '交流できなくなっています（パズルをプレイしてLvを上げましょう）',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            loading: () => const Text('読み込み中...'),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 交流アクションセクション
  Widget _buildInteractionSection(
    BuildContext context,
    WidgetRef ref,
    dynamic userAnimal,
    AsyncValue<bool> hasInteractedAsync,
    dynamic animalMaster,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日の交流',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          hasInteractedAsync.when(
            data: (hasInteracted) => hasInteracted
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓ 今日は既に交流しました。\n明日も遊びに来てね！',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _buildInteractionButton(
                        context,
                        ref,
                        userAnimal,
                        animalMaster,
                        'エサをあげる',
                        Icons.restaurant,
                      ),
                      const SizedBox(height: 12),
                      _buildInteractionButton(
                        context,
                        ref,
                        userAnimal,
                        animalMaster,
                        'なでなで',
                        Icons.pets,
                      ),
                      const SizedBox(height: 12),
                      _buildInteractionButton(
                        context,
                        ref,
                        userAnimal,
                        animalMaster,
                        '遊ぶ',
                        Icons.sports_football,
                      ),
                    ],
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('エラー: $error'),
          ),
        ],
      ),
    );
  }

  /// 交流ボタン
  Widget _buildInteractionButton(
    BuildContext context,
    WidgetRef ref,
    dynamic userAnimal,
    dynamic animalMaster,
    String label,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () async {
        try {
          // タップ時の軽いハプティクス
          if (ref.watch(hapticEnabledProvider)) {
            await HapticFeedback.lightImpact();
          }

          // Cloud Functions呼び出し
          await ref
              .read(
                interactWithAnimalProvider(userAnimal.animalId).future,
              )
              .then((_) {
            // 交流タイプ判定
            String interactionType = _getInteractionType(label);

            // 性格別リアクションアニメーション取得
            final reactionPath = ref.watch(
              interactionReactionProvider(
                (animalMaster.personalityTag, interactionType),
              ),
            );

            // ハプティクス（中程度）
            if (ref.watch(hapticEnabledProvider)) {
              HapticFeedback.mediumImpact();
            }

            // 反応演出ダイアログ表示
            _showInteractionReactionDialog(
              context,
              ref,
              animalMaster.name,
              reactionPath,
              animalMaster.id,
            );

            // 画面リセット（再ロード）
            Future.delayed(const Duration(seconds: 2), () {
              ref.refresh(userAnimalProvider(userAnimal.animalId));
              ref.refresh(hasInteractedTodayProvider(userAnimal.animalId));
            });
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラー: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  /// ボタンラベルから交流タイプを判定
  String _getInteractionType(String label) {
    if (label == 'エサをあげる') {
      return 'feed';
    } else if (label == 'なでなで') {
      return 'pet';
    } else if (label == '遊ぶ') {
      return 'play';
    }
    return 'feed'; // デフォルト
  }

  /// 交流リアクション演出ダイアログ
  void _showInteractionReactionDialog(
    BuildContext context,
    WidgetRef ref,
    String animalName,
    String animationPath,
    String animalId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottieアニメーション表示
                LottieAnimationWidget(
                  assetPath: animationPath,
                  width: 250,
                  height: 250,
                  repeat: false,
                  autoplay: true,
                  onComplete: () {
                    // アニメーション完了後にダイアログを閉じる
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),
                // メッセージ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$animalName が喜んでいる！',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'なつき度が上がった！',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 群れボーナス情報
  Widget _buildHerdBonusInfo(
    BuildContext context,
    AsyncValue<dynamic> herdBonusAsync,
    dynamic animalMaster,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '群れボーナス',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          herdBonusAsync.when(
            data: (herdBonus) {
              if (herdBonus == null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'このエリアの${animalMaster?.habitat ?? ''}に3体',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '動物がいると、特別なシーンが見られます',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '群れボーナス解放済み',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// なつき度Lv別の色
  Color _affectionColor(int level) {
    switch (level) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.deepOrange;
      case 4:
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  /// なつき度Lv別の説明
  String _affectionDescription(int level) {
    switch (level) {
      case 1:
        return '初対面...';
      case 2:
        return 'そこそこ仲良し';
      case 3:
        return '本当の友達';
      case 4:
        return '心の友！';
      default:
        return '';
    }
  }
}
