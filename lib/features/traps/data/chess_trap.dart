import 'package:freezed_annotation/freezed_annotation.dart';

part 'chess_trap.freezed.dart';
part 'chess_trap.g.dart';

@freezed
abstract class ChessTrap with _$ChessTrap {
  const factory ChessTrap({
    required String opening,
    @JsonKey(name: 'trap_name') required String trapName,
    @JsonKey(name: 'clean_moves') required String cleanMoves,
    @JsonKey(name: 'commented_moves') required String commentedMoves,
    required String metadata,
  }) = _ChessTrap;

  factory ChessTrap.fromJson(Map<String, dynamic> json) => _$ChessTrapFromJson(json);
}
