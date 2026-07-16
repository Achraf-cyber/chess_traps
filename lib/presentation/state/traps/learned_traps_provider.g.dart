// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learned_traps_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LearnedTraps)
final learnedTrapsProvider = LearnedTrapsProvider._();

final class LearnedTrapsProvider
    extends $NotifierProvider<LearnedTraps, Set<int>> {
  LearnedTrapsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learnedTrapsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learnedTrapsHash();

  @$internal
  @override
  LearnedTraps create() => LearnedTraps();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$learnedTrapsHash() => r'de0699ac0a95bc73ea4ab01d2bda5480dc961732';

abstract class _$LearnedTraps extends $Notifier<Set<int>> {
  Set<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<int>, Set<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<int>, Set<int>>,
              Set<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
