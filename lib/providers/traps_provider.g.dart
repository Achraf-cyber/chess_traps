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
        $FunctionalProvider<List<ChessTrap>, List<ChessTrap>, List<ChessTrap>>
    with $Provider<List<ChessTrap>> {
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
  $ProviderElement<List<ChessTrap>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ChessTrap> create(Ref ref) {
    return traps(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ChessTrap> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChessTrap>>(value),
    );
  }
}

String _$trapsHash() => r'94ef39e446d260c77d24c3f8787e9a3d902c317c';

@ProviderFor(trapOfTheDay)
final trapOfTheDayProvider = TrapOfTheDayProvider._();

final class TrapOfTheDayProvider
    extends $FunctionalProvider<ChessTrap, ChessTrap, ChessTrap>
    with $Provider<ChessTrap> {
  TrapOfTheDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trapOfTheDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trapOfTheDayHash();

  @$internal
  @override
  $ProviderElement<ChessTrap> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChessTrap create(Ref ref) {
    return trapOfTheDay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChessTrap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChessTrap>(value),
    );
  }
}

String _$trapOfTheDayHash() => r'cdd0d938bc4f37575c675f30459d9625284797e4';
