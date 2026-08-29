import 'dart:typed_data';
import 'package:nuripazu/models/share_asset.dart';

/// 動物園スクショ生成・SNS シェア機能
class ShareService {
  /// 動物園全景のスクショを生成
  ///
  /// 戻り値: 生成されたスクショの Uint8List
  /// （Widget render → PNG変換をここで実装予定）
  Future<Uint8List> generateZooScreenshot() async {
    // flutter.widgets.WidgetBinding.instance.window.physicalSize
    // ui.PictureRecorder + Canvas で描画
    // PNG エンコード
    await Future.delayed(const Duration(milliseconds: 500));
    return Uint8List(0); // placeholder
  }

  /// スクショにフレーム付きでデコレーション
  ///
  /// 戻り値: フレーム付きスクショ
  Future<Uint8List> addFrameDecoration(
    Uint8List screenshot, {
    String frameType = 'default', // 'gold', 'silver', 'cute' など
  }) async {
    // image パッケージで枠を合成
    // ブランド色・デザイン統一
    await Future.delayed(const Duration(milliseconds: 300));
    return screenshot;
  }

  /// SNS シェアシート（ネイティブ）を起動
  ///
  /// 対応: LINE, Twitter, Instagram, Facebook
  Future<void> shareToSocial(
    Uint8List imageData, {
    String? message,
    String? hashtags,
  }) async {
    // share_plus パッケージで実装
    // message: "ぬりパズ動物園で○○匹集めました！ #ぬりパズ動物園"
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 生成されたスクショを記録（オンライン時のみ）
  Future<void> recordShareEvent(ShareAsset asset) async {
    // Firestore に記録
    // Firebase Analytics に share_created イベント送信
    // Viral Coefficient トラッキング用
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// デバッグ用: ダミースクショ生成
  static Uint8List generateDummyScreenshot() {
    return Uint8List(100);
  }
}
