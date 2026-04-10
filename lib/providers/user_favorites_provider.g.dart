// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserFavoritesNotifier)
final userFavoritesProvider = UserFavoritesNotifierProvider._();

final class UserFavoritesNotifierProvider
    extends $NotifierProvider<UserFavoritesNotifier, Set<int>> {
  UserFavoritesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userFavoritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userFavoritesNotifierHash();

  @$internal
  @override
  UserFavoritesNotifier create() => UserFavoritesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$userFavoritesNotifierHash() =>
    r'ebdb59ef465c423937bc1d42135120b7d383ef59';

abstract class _$UserFavoritesNotifier extends $Notifier<Set<int>> {
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
