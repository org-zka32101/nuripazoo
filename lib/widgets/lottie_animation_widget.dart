import 'package:flutter/material.dart';

/// Lottie アニメーション表示ウィジェット
/// 【実装予定】lottie パッケージで Lottie ファイルをレンダリング
///
/// 使用例:
/// ```dart
/// LottieAnimationWidget(
///   assetPath: 'assets/lottie/reactions/sweettooth_happy_lv2.json',
///   width: 200,
///   height: 200,
///   repeat: true,
///   onComplete: () { print('Animation done'); },
/// )
/// ```
class LottieAnimationWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final VoidCallback? onComplete;
  final bool autoplay;
  final Duration? duration;

  const LottieAnimationWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.onComplete,
    this.autoplay = true,
    this.duration,
  }) : super(key: key);

  @override
  State<LottieAnimationWidget> createState() => _LottieAnimationWidgetState();
}

class _LottieAnimationWidgetState extends State<LottieAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(seconds: 2),
    );

    if (widget.autoplay) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Lottie パッケージのインポートと実装
    // import 'package:lottie/lottie.dart';
    //
    // return Lottie.asset(
    //   widget.assetPath,
    //   controller: _controller,
    //   width: widget.width,
    //   height: widget.height,
    //   repeat: widget.repeat,
    //   onLoaded: (composition) {
    //     _controller.duration = composition.duration;
    //   },
    // );

    // 暫定実装: プレースホルダー
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.animation,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              widget.assetPath.split('/').last,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// アニメーションコンポーザー（複数アニメーション順序実行）
class AnimationSequence extends StatefulWidget {
  final List<String> animationPaths;
  final List<Duration>? durations;
  final VoidCallback? onSequenceComplete;

  const AnimationSequence({
    Key? key,
    required this.animationPaths,
    this.durations,
    this.onSequenceComplete,
  }) : super(key: key);

  @override
  State<AnimationSequence> createState() => _AnimationSequenceState();
}

class _AnimationSequenceState extends State<AnimationSequence> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _playNextAnimation();
  }

  void _playNextAnimation() {
    if (_currentIndex < widget.animationPaths.length) {
      Future.delayed(
        widget.durations?[_currentIndex] ??
            const Duration(seconds: 2),
        () {
          if (mounted) {
            setState(() {
              _currentIndex++;
            });
            if (_currentIndex < widget.animationPaths.length) {
              _playNextAnimation();
            } else {
              widget.onSequenceComplete?.call();
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.animationPaths.length) {
      return const SizedBox.shrink();
    }

    return LottieAnimationWidget(
      assetPath: widget.animationPaths[_currentIndex],
      repeat: false,
      autoplay: true,
    );
  }
}
