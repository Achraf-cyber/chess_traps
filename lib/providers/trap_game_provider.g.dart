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
    extends $FunctionalProvider<Position, Position, Position>
    with $Provider<Position> {
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
  $ProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Position create(Ref ref) {
    final argument = this.argument as int;
    return trapGame(ref, argument);
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
    return other is TrapGameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trapGameHash() => r'dd839edef047d225d619d189e655a924b9e0cc15';

final class TrapGameFamily extends $Family
    with $FunctionalFamilyOverride<Position, int> {
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
