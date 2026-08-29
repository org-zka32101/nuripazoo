import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_master.freezed.dart';
part 'animal_master.g.dart';

enum AnimalHabitat {
  forest,    // 森
  ocean,     // 海
  grassland, // 草原
  mountain,  // 山
  sky,       // 空
}

enum PersonalityTag {
  sweetTooth,      // 甘えん坊
  independant,     // マイペース
  shy,             // 人見知り
  playful,         // やんちゃ
  calm,            // おっとり
}

enum AnimalRarity {
  common,
  uncommon,
  rare,
  superRare,
  legendary,
}

@freezed
class AnimalMaster with _$AnimalMaster {
  const factory AnimalMaster({
    required String id,
    required String name,
    required AnimalHabitat habitat,
    required PersonalityTag personalityTag,
    required String pixelArtId,
    @Default(AnimalRarity.common) AnimalRarity rarity,
    required String reactionSetId,
  }) = _AnimalMaster;

  factory AnimalMaster.fromJson(Map<String, dynamic> json) =>
      _$AnimalMasterFromJson(json);
}
