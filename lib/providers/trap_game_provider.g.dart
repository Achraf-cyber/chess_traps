// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trap_game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trapGame)
final trapGameProvider = TrapGameFamily._();

final class TrapGameProvider
    extends $FunctionalProvider<ChessTrap?, ChessTrap?, ChessTrap?>
    with $Provider<ChessTrap?> {
  TrapGameProvider._({
    required TrapGameFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'trapGameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trapGameHash();

  @override
  String toString() {
    return r'trapGameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ChessTrap?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChessTrap? create(Ref ref) {
    final argument = this.argument as int;
    return trapGame(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChessTrap? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChessTrap?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrapGameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trapGameHash() => r'2f0ccddb35c28fbb749ef7b003d44396b433e760';

final class TrapGameFamily extends $Family
    with $FunctionalFamilyOverride<ChessTrap?, int> {
  TrapGameFamily._()
    : super(
        retry: null,
        name: r'trapGameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrapGameProvider call(int index) =>
      TrapGameProvider._(argument: index, from: this);

  @override
  String toString() => r'trapGameProvider';
}

@ProviderFor(trapPosition)
final trapPositionProvider = TrapPositionFamily._();

final class TrapPositionProvider
    extends $FunctionalProvider<Position, Position, Position>
    with $Provider<Position> {
  TrapPositionProvider._({
    required TrapPositionFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'trapPositionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trapPositionHash();

  @override
  String toString() {
    return r'trapPositionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Position create(Ref ref) {
    final argument = this.argument as (int, int);
    return trapPosition(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Position value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Position>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrapPositionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trapPositionHash() => r'0c308a7f3a599d7bac4d37ee4a531a6c73253591';

final class TrapPositionFamily extends $Family
    with $FunctionalFamilyOverride<Position, (int, int)> {
  TrapPositionFamily._()
    : super(
        retry: null,
        name: r'trapPositionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrapPositionProvider call(int index, int moveIndex) =>
      TrapPositionProvider._(argument: (index, moveIndex), from: this);

  @override
  String toString() => r'trapPositionProvider';
}
