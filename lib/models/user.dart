import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserPlan {
  free,
  pro,
}

@freezed
class User with _$User {
  const factory User({
    required String uid,
    @Default(UserPlan.free) UserPlan plan,
    @Default(0) int streakDays,
    required DateTime lastVisitAt,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
