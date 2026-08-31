import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_asset.freezed.dart';
part 'share_asset.g.dart';

@freezed
class ShareAsset with _$ShareAsset {
  const factory ShareAsset({
    required String id,
    required String uid,
    required DateTime generatedAt,
    required String imageUrl,
  }) = _ShareAsset;

  factory ShareAsset.fromJson(Map<String, dynamic> json) =>
      _$ShareAssetFromJson(json);
}
