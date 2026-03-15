// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chess_trap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChessTrap {

 String get opening;@JsonKey(name: 'trap_name') String get trapName;@JsonKey(name: 'clean_moves') String get cleanMoves;@JsonKey(name: 'commented_moves') String get commentedMoves; String get metadata;
/// Create a copy of ChessTrap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChessTrapCopyWith<ChessTrap> get copyWith => _$ChessTrapCopyWithImpl<ChessTrap>(this as ChessTrap, _$identity);

  /// Serializes this ChessTrap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChessTrap&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.trapName, trapName) || other.trapName == trapName)&&(identical(other.cleanMoves, cleanMoves) || other.cleanMoves == cleanMoves)&&(identical(other.commentedMoves, commentedMoves) || other.commentedMoves == commentedMoves)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,opening,trapName,cleanMoves,commentedMoves,metadata);

@override
String toString() {
  return 'ChessTrap(opening: $opening, trapName: $trapName, cleanMoves: $cleanMoves, commentedMoves: $commentedMoves, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ChessTrapCopyWith<$Res>  {
  factory $ChessTrapCopyWith(ChessTrap value, $Res Function(ChessTrap) _then) = _$ChessTrapCopyWithImpl;
@useResult
$Res call({
 String opening,@JsonKey(name: 'trap_name') String trapName,@JsonKey(name: 'clean_moves') String cleanMoves,@JsonKey(name: 'commented_moves') String commentedMoves, String metadata
});




}
/// @nodoc
class _$ChessTrapCopyWithImpl<$Res>
    implements $ChessTrapCopyWith<$Res> {
  _$ChessTrapCopyWithImpl(this._self, this._then);

  final ChessTrap _self;
  final $Res Function(ChessTrap) _then;

/// Create a copy of ChessTrap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? opening = null,Object? trapName = null,Object? cleanMoves = null,Object? commentedMoves = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as String,trapName: null == trapName ? _self.trapName : trapName // ignore: cast_nullable_to_non_nullable
as String,cleanMoves: null == cleanMoves ? _self.cleanMoves : cleanMoves // ignore: cast_nullable_to_non_nullable
as String,commentedMoves: null == commentedMoves ? _self.commentedMoves : commentedMoves // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChessTrap].
extension ChessTrapPatterns on ChessTrap {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChessTrap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChessTrap() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChessTrap value)  $default,){
final _that = this;
switch (_that) {
case _ChessTrap():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChessTrap value)?  $default,){
final _that = this;
switch (_that) {
case _ChessTrap() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String opening, @JsonKey(name: 'trap_name')  String trapName, @JsonKey(name: 'clean_moves')  String cleanMoves, @JsonKey(name: 'commented_moves')  String commentedMoves,  String metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChessTrap() when $default != null:
return $default(_that.opening,_that.trapName,_that.cleanMoves,_that.commentedMoves,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String opening, @JsonKey(name: 'trap_name')  String trapName, @JsonKey(name: 'clean_moves')  String cleanMoves, @JsonKey(name: 'commented_moves')  String commentedMoves,  String metadata)  $default,) {final _that = this;
switch (_that) {
case _ChessTrap():
return $default(_that.opening,_that.trapName,_that.cleanMoves,_that.commentedMoves,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String opening, @JsonKey(name: 'trap_name')  String trapName, @JsonKey(name: 'clean_moves')  String cleanMoves, @JsonKey(name: 'commented_moves')  String commentedMoves,  String metadata)?  $default,) {final _that = this;
switch (_that) {
case _ChessTrap() when $default != null:
return $default(_that.opening,_that.trapName,_that.cleanMoves,_that.commentedMoves,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChessTrap implements ChessTrap {
  const _ChessTrap({required this.opening, @JsonKey(name: 'trap_name') required this.trapName, @JsonKey(name: 'clean_moves') required this.cleanMoves, @JsonKey(name: 'commented_moves') required this.commentedMoves, required this.metadata});
  factory _ChessTrap.fromJson(Map<String, dynamic> json) => _$ChessTrapFromJson(json);

@override final  String opening;
@override@JsonKey(name: 'trap_name') final  String trapName;
@override@JsonKey(name: 'clean_moves') final  String cleanMoves;
@override@JsonKey(name: 'commented_moves') final  String commentedMoves;
@override final  String metadata;

/// Create a copy of ChessTrap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChessTrapCopyWith<_ChessTrap> get copyWith => __$ChessTrapCopyWithImpl<_ChessTrap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChessTrapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChessTrap&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.trapName, trapName) || other.trapName == trapName)&&(identical(other.cleanMoves, cleanMoves) || other.cleanMoves == cleanMoves)&&(identical(other.commentedMoves, commentedMoves) || other.commentedMoves == commentedMoves)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,opening,trapName,cleanMoves,commentedMoves,metadata);

@override
String toString() {
  return 'ChessTrap(opening: $opening, trapName: $trapName, cleanMoves: $cleanMoves, commentedMoves: $commentedMoves, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ChessTrapCopyWith<$Res> implements $ChessTrapCopyWith<$Res> {
  factory _$ChessTrapCopyWith(_ChessTrap value, $Res Function(_ChessTrap) _then) = __$ChessTrapCopyWithImpl;
@override @useResult
$Res call({
 String opening,@JsonKey(name: 'trap_name') String trapName,@JsonKey(name: 'clean_moves') String cleanMoves,@JsonKey(name: 'commented_moves') String commentedMoves, String metadata
});




}
/// @nodoc
class __$ChessTrapCopyWithImpl<$Res>
    implements _$ChessTrapCopyWith<$Res> {
  __$ChessTrapCopyWithImpl(this._self, this._then);

  final _ChessTrap _self;
  final $Res Function(_ChessTrap) _then;

/// Create a copy of ChessTrap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? opening = null,Object? trapName = null,Object? cleanMoves = null,Object? commentedMoves = null,Object? metadata = null,}) {
  return _then(_ChessTrap(
opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as String,trapName: null == trapName ? _self.trapName : trapName // ignore: cast_nullable_to_non_nullable
as String,cleanMoves: null == cleanMoves ? _self.cleanMoves : cleanMoves // ignore: cast_nullable_to_non_nullable
as String,commentedMoves: null == commentedMoves ? _self.commentedMoves : commentedMoves // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
