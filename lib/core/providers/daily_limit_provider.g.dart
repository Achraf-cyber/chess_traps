// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_limit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyLimitNotifier)
final dailyLimitProvider = DailyLimitNotifierProvider._();

final class DailyLimitNotifierProvider
    extends $NotifierProvider<DailyLimitNotifier, DailyLimitState> {
  DailyLimitNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyLimitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyLimitNotifierHash();

  @$internal
  @override
  DailyLimitNotifier create() => DailyLimitNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyLimitState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyLimitState>(value),
    );
  }
}

String _$dailyLimitNotifierHash() =>
    r'8246625fcb8214d66e4d594f92e4d4a83344c0fe';

abstract class _$DailyLimitNotifier extends $Notifier<DailyLimitState> {
  DailyLimitState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DailyLimitState, DailyLimitState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DailyLimitState, DailyLimitState>,
              DailyLimitState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
