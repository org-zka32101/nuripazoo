import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_animal.freezed.dart';
part 'user_animal.g.dart';

@freezed
class UserAnimal with _$UserAnimal {
  const factory UserAnimal({
    required String uid,
    required String animalId,
    required DateTime unlockedAt,
    @Default(1) int affectionLevel,
    required DateTime lastInteractedAt,
    @Default(false) bool isDeclineWarned,
  }) = _UserAnimal;

  factory UserAnimal.fromJson(Map<String, dynamic> json) =>
      _$UserAnimalFromJson(json);
}
