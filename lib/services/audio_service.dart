import 'package:audioplayers/audioplayers.dart';

/// オーディオ再生管理サービス
/// SE・BGM・動物音声の再生・停止を一元管理
class AudioService {
  static final AudioService _instance = AudioService._internal();

  late final AudioPlayer _sePlayer;      // 効果音プレイヤー
  late final AudioPlayer _bgmPlayer;     // BGM プレイヤー
  late final AudioPlayer _voicePlayer;   // 動物音声プレイヤー

  bool _soundEnabled = true;
  bool _bgmEnabled = true;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _sePlayer = AudioPlayer();
    _bgmPlayer = AudioPlayer();
    _voicePlayer = AudioPlayer();
  }

  /// SE 再生（上書き）
  Future<void> playSoundEffect(String assetPath) async {
    if (!_soundEnabled) return;

    try {
      await _sePlayer.play(
        AssetSource(assetPath),
        volume: 0.7,
      );
    } catch (e) {
      print('Error playing sound effect: $e');
    }
  }

  /// BGM 再生（ループ）
  Future<void> playBGM(String assetPath) async {
    if (!_bgmEnabled) return;

    try {
      // 既存 BGM を停止
      await _bgmPlayer.stop();

      await _bgmPlayer.play(
        AssetSource(assetPath),
        volume: 0.3, // 環境音なので音量低め
      );

      // ループ設定
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  /// BGM 停止
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  /// 動物音声 再生
  Future<void> playAnimalVoice(String assetPath) async {
    if (!_soundEnabled) return;

    try {
      await _voicePlayer.play(
        AssetSource(assetPath),
        volume: 0.8,
      );
    } catch (e) {
      print('Error playing animal voice: $e');
    }
  }

  /// 動物音声 停止
  Future<void> stopAnimalVoice() async {
    try {
      await _voicePlayer.stop();
    } catch (e) {
      print('Error stopping animal voice: $e');
    }
  }

  /// SE 有効/無効 設定
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// BGM 有効/無効 設定
  void setBGMEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBGM();
    }
  }

  /// すべてのオーディオ停止（アプリ終了時など）
  Future<void> stopAll() async {
    try {
      await _sePlayer.stop();
      await _bgmPlayer.stop();
      await _voicePlayer.stop();
    } catch (e) {
      print('Error stopping all audio: $e');
    }
  }

  /// 音量調整（0.0 - 1.0）
  Future<void> setSEVolume(double volume) async {
    try {
      await _sePlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting SE volume: $e');
    }
  }

  Future<void> setBGMVolume(double volume) async {
    try {
      await _bgmPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting BGM volume: $e');
    }
  }

  /// デバッグ用：現在の再生状態取得
  Future<PlayerState> getSEState() async {
    return await _sePlayer.state;
  }

  Future<PlayerState> getBGMState() async {
    return await _bgmPlayer.state;
  }
}
