// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayHistoryNotifier)
final playHistoryProvider = PlayHistoryNotifierProvider._();

final class PlayHistoryNotifierProvider
    extends $NotifierProvider<PlayHistoryNotifier, PlayHistory> {
  PlayHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playHistoryNotifierHash();

  @$internal
  @override
  PlayHistoryNotifier create() => PlayHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayHistory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayHistory>(value),
    );
  }
}

String _$playHistoryNotifierHash() =>
    r'096af3b746a0cb991a44ed75c78afcb914132c9f';

abstract class _$PlayHistoryNotifier extends $Notifier<PlayHistory> {
  PlayHistory build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayHistory, PlayHistory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayHistory, PlayHistory>,
              PlayHistory,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
