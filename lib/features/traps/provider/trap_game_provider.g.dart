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
    extends
        $FunctionalProvider<AsyncValue<Position>, Position, FutureOr<Position>>
    with $FutureModifier<Position>, $FutureProvider<Position> {
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
  $FutureProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Position> create(Ref ref) {
    final argument = this.argument as int;
    return trapGame(ref, argument);
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

String _$trapGameHash() => r'7bfad6fae41223c402a4eeeea551bc6ad9f8b208';

final class TrapGameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Position>, int> {
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
