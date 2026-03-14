// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traps_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(traps)
final trapsProvider = TrapsProvider._();

final class TrapsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChessTrap>>,
          List<ChessTrap>,
          FutureOr<List<ChessTrap>>
        >
    with $FutureModifier<List<ChessTrap>>, $FutureProvider<List<ChessTrap>> {
  TrapsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trapsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trapsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChessTrap>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChessTrap>> create(Ref ref) {
    return traps(ref);
  }
}

String _$trapsHash() => r'f4679b29f39136993538650a368607ce4caf79d0';
