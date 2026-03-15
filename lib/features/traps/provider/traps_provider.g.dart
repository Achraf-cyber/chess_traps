// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traps_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trapsRepository)
final trapsRepositoryProvider = TrapsRepositoryProvider._();

final class TrapsRepositoryProvider
    extends
        $FunctionalProvider<TrapsRepository, TrapsRepository, TrapsRepository>
    with $Provider<TrapsRepository> {
  TrapsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trapsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trapsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrapsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrapsRepository create(Ref ref) {
    return trapsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrapsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrapsRepository>(value),
    );
  }
}

String _$trapsRepositoryHash() => r'89f214f6bd9fdf53d6fa73a518aeb55c647b1c8f';

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
        isAutoDispose: false,
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

String _$trapsHash() => r'be59b6aa27f7de6ba0bb36e1860e7b03c12d0bca';
