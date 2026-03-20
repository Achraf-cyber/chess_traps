// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traps_group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trapsGroupSource)
final trapsGroupSourceProvider = TrapsGroupSourceProvider._();

final class TrapsGroupSourceProvider
    extends
        $FunctionalProvider<
          Map<String, List<int>>,
          Map<String, List<int>>,
          Map<String, List<int>>
        >
    with $Provider<Map<String, List<int>>> {
  TrapsGroupSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trapsGroupSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trapsGroupSourceHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<int>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<int>> create(Ref ref) {
    return trapsGroupSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<int>>>(value),
    );
  }
}

String _$trapsGroupSourceHash() => r'f056212c5ce3b9b042fc24df337432fd3d280d0c';

@ProviderFor(trapsOfGroup)
final trapsOfGroupProvider = TrapsOfGroupFamily._();

final class TrapsOfGroupProvider
    extends
        $FunctionalProvider<List<ChessTrap>, List<ChessTrap>, List<ChessTrap>>
    with $Provider<List<ChessTrap>> {
  TrapsOfGroupProvider._({
    required TrapsOfGroupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trapsOfGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trapsOfGroupHash();

  @override
  String toString() {
    return r'trapsOfGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ChessTrap>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ChessTrap> create(Ref ref) {
    final argument = this.argument as String;
    return trapsOfGroup(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ChessTrap> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChessTrap>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrapsOfGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trapsOfGroupHash() => r'38e0d00c429c75b4ce4d39d2f152b3e257477bec';

final class TrapsOfGroupFamily extends $Family
    with $FunctionalFamilyOverride<List<ChessTrap>, String> {
  TrapsOfGroupFamily._()
    : super(
        retry: null,
        name: r'trapsOfGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrapsOfGroupProvider call(String groupName) =>
      TrapsOfGroupProvider._(argument: groupName, from: this);

  @override
  String toString() => r'trapsOfGroupProvider';
}
