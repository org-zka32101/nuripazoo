import 'package:freezed_annotation/freezed_annotation.dart';
import 'animal_master.dart';

part 'herd_bonus.freezed.dart';
part 'herd_bonus.g.dart';

@freezed
class HerdBonus with _$HerdBonus {
  const factory HerdBonus({
    required String uid,
    required AnimalHabitat habitat,
    @Default(0) int completedCount,
    DateTime? sceneUnlockedAt,
  }) = _HerdBonus;

  factory HerdBonus.fromJson(Map<String, dynamic> json) =>
      _$HerdBonusFromJson(json);
}
