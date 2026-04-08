// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_premium_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserPremiumNotifier)
final userPremiumProvider = UserPremiumNotifierProvider._();

final class UserPremiumNotifierProvider
    extends $NotifierProvider<UserPremiumNotifier, bool> {
  UserPremiumNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPremiumProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPremiumNotifierHash();

  @$internal
  @override
  UserPremiumNotifier create() => UserPremiumNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$userPremiumNotifierHash() =>
    r'fbc0480c550587e6e47bd2aeff15b72b2438a4f8';

abstract class _$UserPremiumNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
