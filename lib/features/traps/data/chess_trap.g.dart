// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chess_trap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChessTrap _$ChessTrapFromJson(Map<String, dynamic> json) => _ChessTrap(
  opening: json['opening'] as String,
  trapName: json['trap_name'] as String,
  cleanMoves: json['clean_moves'] as String,
  commentedMoves: json['commented_moves'] as String,
  metadata: json['metadata'] as String,
);

Map<String, dynamic> _$ChessTrapToJson(_ChessTrap instance) =>
    <String, dynamic>{
      'opening': instance.opening,
      'trap_name': instance.trapName,
      'clean_moves': instance.cleanMoves,
      'commented_moves': instance.commentedMoves,
      'metadata': instance.metadata,
    };
