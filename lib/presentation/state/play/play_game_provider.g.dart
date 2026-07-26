// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayGameNotifier)
final playGameProvider = PlayGameNotifierProvider._();

final class PlayGameNotifierProvider
    extends $NotifierProvider<PlayGameNotifier, PlayGameState> {
  PlayGameNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playGameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playGameNotifierHash();

  @$internal
  @override
  PlayGameNotifier create() => PlayGameNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayGameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayGameState>(value),
    );
  }
}

String _$playGameNotifierHash() => r'3b636a445ea43026f24617bc22f040f7956e0896';

abstract class _$PlayGameNotifier extends $Notifier<PlayGameState> {
  PlayGameState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlayGameState, PlayGameState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayGameState, PlayGameState>,
              PlayGameState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
