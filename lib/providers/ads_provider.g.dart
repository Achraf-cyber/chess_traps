// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdsStateNotifier)
final adsStateProvider = AdsStateNotifierProvider._();

final class AdsStateNotifierProvider
    extends $NotifierProvider<AdsStateNotifier, void> {
  AdsStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsStateNotifierHash();

  @$internal
  @override
  AdsStateNotifier create() => AdsStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$adsStateNotifierHash() => r'94430c9e743cbf8bc057aa9f1700d56c3f9372ca';

abstract class _$AdsStateNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
