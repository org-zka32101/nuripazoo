import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle_session.freezed.dart';
part 'puzzle_session.g.dart';

@freezed
class PuzzleSession with _$PuzzleSession {
  const factory PuzzleSession({
    required String id,
    required String uid,
    required String animalId,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0) int mistakeCount,
  }) = _PuzzleSession;

  factory PuzzleSession.fromJson(Map<String, dynamic> json) =>
      _$PuzzleSessionFromJson(json);
}
