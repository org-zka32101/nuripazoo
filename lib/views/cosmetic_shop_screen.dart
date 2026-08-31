import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// コスメティックショップ画面
/// 動物用アクセサリー・園内装飾品などの購入
/// Premium プランユーザー向け
class CosmeticShopScreen extends ConsumerWidget {
  const CosmeticShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コスメティックショップ'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // バナー
            _buildShopBanner(),

            const SizedBox(height: 24),

            // カテゴリータブ
            _buildCategoryTabs(),

            const SizedBox(height: 16),

            // アイテムグリッド
            _buildItemsGrid(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// ショップバナー
  Widget _buildShopBanner() {
    return Container(
      color: Colors.pink.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_bag,
            size: 48,
            color: Colors.pink,
          ),
          const SizedBox(height: 12),
          const Text(
            'あなたの動物園をカスタマイズ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Premium プランで全てのアイテムが利用できます',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// カテゴリータブ
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _buildCategoryChip('全て', true),
            _buildCategoryChip('アクセサリー', false),
            _buildCategoryChip('園内装飾', false),
            _buildCategoryChip('背景', false),
          ],
        ),
      ),
    );
  }

  /// カテゴリーチップ
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.pink,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {},
      ),
    );
  }

  /// アイテムグリッド
  Widget _buildItemsGrid() {
    final items = [
      {'name': '王冠', 'price': '¥240', 'icon': '👑', 'tag': 'アクセサリー'},
      {'name': 'ネックレス', 'price': '¥240', 'icon': '💎', 'tag': 'アクセサリー'},
      {'name': 'サングラス', 'price': '¥240', 'icon': '😎', 'tag': 'アクセサリー'},
      {'name': 'リボン', 'price': '¥180', 'icon': '🎀', 'tag': 'アクセサリー'},
      {'name': 'ベンチ', 'price': '¥480', 'icon': '🪑', 'tag': '園内装飾'},
      {'name': 'ライト', 'price': '¥480', 'icon': '💡', 'tag': '園内装飾'},
      {'name': '池', 'price': '¥720', 'icon': '💧', 'tag': '園内装飾'},
      {'name': '花壇', 'price': '¥480', 'icon': '🌸', 'tag': '園内装飾'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(
            context,
            name: item['name']!,
            price: item['price']!,
            icon: item['icon']!,
            tag: item['tag']!,
          );
        },
      ),
    );
  }

  /// アイテムカード
  Widget _buildItemCard(
    BuildContext context, {
    required String name,
    required String price,
    required String icon,
    required String tag,
  }) {
    return GestureDetector(
      onTap: () {
        _showItemDetail(context, name, price, icon, tag);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.pink.shade200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            // 名前
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // タグ
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.pink.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 価格
            Text(
              price,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// アイテム詳細ダイアログ
  void _showItemDetail(
    BuildContext context,
    String name,
    String price,
    String icon,
    String tag,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'このアイテムについて',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'あなたの動物園を彩ります。\nPremium プランに加入すると購入できます。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name を購入しました！'),
                      backgroundColor: Colors.pink,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  '$price で購入',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
