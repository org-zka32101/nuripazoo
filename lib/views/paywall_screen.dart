import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/viewmodels/index.dart';

/// ペイウォール画面
/// 2体目動物完成後にトリガー
/// 有料プラン vs 無料プラン の選択肢を提示
class PaywallScreen extends ConsumerWidget {
  final String? animalId;
  final VoidCallback? onDismiss;

  const PaywallScreen({
    Key? key,
    this.animalId,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        onDismiss?.call();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ヘッダー
              _buildHeader(context),

              const SizedBox(height: 32),

              // プラン比較表
              _buildPlanComparison(context),

              const SizedBox(height: 32),

              // CTA ボタン
              _buildActionButtons(context, ref),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade50,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            '2体目のお友達をゲット！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'さらに楽しい機能が解放されます',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// プラン比較表
  Widget _buildPlanComparison(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 無料プラン
          _buildPlanCard(
            title: '無料プラン',
            price: '¥0',
            description: '基本プレイ無料',
            features: [
              '✓ パズル無制限プレイ',
              '✓ 動物の育成・交流',
              '✓ 動物図鑑の閲覧',
              '✓ 群れボーナスシーン',
              '→ 広告で追加アイテム獲得可能',
            ],
            isPrimary: false,
            onTap: () {
              onDismiss?.call();
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(height: 16),

          // プレミアムプラン（推奨）
          _buildPlanCard(
            title: 'プレミアムプラン',
            price: '¥480/月',
            description: '広告なし＋コスメアイテム',
            features: [
              '✓ 無料プランのすべて',
              '✓ 広告を完全削除',
              '✓ コスメアイテム解放',
              '✓ パズル難易度調整',
              '✓ 動物園カスタマイズ',
            ],
            isPrimary: true,
            onTap: () async {
              // 課金フロー
              try {
                // RevenueCat 統合予定
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('課金機能は近日実装予定です'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('エラー: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// プランカード
  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? Colors.orange.shade50 : Colors.white,
        border: Border.all(
          color: isPrimary ? Colors.orange : Colors.grey.shade300,
          width: isPrimary ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'おすすめ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 価格
          Text(
            price,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.orange : Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          // 機能リスト
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          )),

          const SizedBox(height: 20),

          // ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? Colors.orange : Colors.grey.shade200,
                foregroundColor:
                    isPrimary ? Colors.white : Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                isPrimary ? '今すぐ始める' : 'このまま続ける',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 後で決める
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                onDismiss?.call();
                Navigator.of(context).pop();
              },
              child: const Text(
                '後で決める',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 利用規約
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  '購読を開始すると',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('利用規約を表示'),
                          ),
                        );
                      },
                      child: Text(
                        '利用規約',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' と ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('プライバシーポリシーを表示'),
                          ),
                        );
                      },
                      child: Text(
                        'プライバシーポリシー',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'に同意したものとみなします',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
