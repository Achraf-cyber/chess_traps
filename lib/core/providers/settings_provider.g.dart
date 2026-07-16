// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChessSettingsNotifier)
final chessSettingsProvider = ChessSettingsNotifierProvider._();

final class ChessSettingsNotifierProvider
    extends $NotifierProvider<ChessSettingsNotifier, ChessSettings> {
  ChessSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chessSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chessSettingsNotifierHash();

  @$internal
  @override
  ChessSettingsNotifier create() => ChessSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChessSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChessSettings>(value),
    );
  }
}

String _$chessSettingsNotifierHash() =>
    r'865222959f7326815e1e9b8081105fa767eec76b';

abstract class _$ChessSettingsNotifier extends $Notifier<ChessSettings> {
  ChessSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChessSettings, ChessSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChessSettings, ChessSettings>,
              ChessSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
