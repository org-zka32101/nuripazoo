import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 群れミニシーン画面
/// 同じ生息地の3体の動物が揃ったときの特別な場面演出
/// （3-5秒のアニメーション + 音声）
class HerdSceneScreen extends ConsumerWidget {
  final String habitat;
  final List<String> animalIds;

  const HerdSceneScreen({
    Key? key,
    required this.habitat,
    required this.animalIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 自動で3秒後に前の画面に戻る
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: _habitatBackgroundColor(habitat),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 群れシーン（プレースホルダー）
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$habitat の\n仲間たち',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // 説明テキスト
            Text(
              '群れボーナス解放！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '3体揃うたびに、ここで会える',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 生息地別の背景色
  Color _habitatBackgroundColor(String habitat) {
    switch (habitat) {
      case 'forest':
        return Colors.green.shade600;
      case 'ocean':
        return Colors.blue.shade600;
      case 'grassland':
        return Colors.amber.shade600;
      case 'mountain':
        return Colors.grey.shade600;
      case 'sky':
        return Colors.cyan.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
