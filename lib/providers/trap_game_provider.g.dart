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
    extends $FunctionalProvider<ChessTrap, ChessTrap, ChessTrap>
    with $Provider<ChessTrap> {
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
  $ProviderElement<ChessTrap> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChessTrap create(Ref ref) {
    final argument = this.argument as int;
    return trapGame(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChessTrap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChessTrap>(value),
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

String _$trapGameHash() => r'a1b120f576544da31a0bcbdafc0b6a8c89f20e01';

final class TrapGameFamily extends $Family
    with $FunctionalFamilyOverride<ChessTrap, int> {
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
