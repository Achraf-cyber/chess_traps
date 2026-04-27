// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chessEngineService)
final chessEngineServiceProvider = ChessEngineServiceProvider._();

final class ChessEngineServiceProvider
    extends
        $FunctionalProvider<
          ChessEngineService,
          ChessEngineService,
          ChessEngineService
        >
    with $Provider<ChessEngineService> {
  ChessEngineServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chessEngineServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chessEngineServiceHash();

  @$internal
  @override
  $ProviderElement<ChessEngineService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChessEngineService create(Ref ref) {
    return chessEngineService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChessEngineService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChessEngineService>(value),
    );
  }
}

String _$chessEngineServiceHash() =>
    r'60eee4712ea8233613de5321143e00fd1a07963b';

@ProviderFor(EngineAnalysis)
final engineAnalysisProvider = EngineAnalysisFamily._();

final class EngineAnalysisProvider
    extends $NotifierProvider<EngineAnalysis, EngineAnalysisState> {
  EngineAnalysisProvider._({
    required EngineAnalysisFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'engineAnalysisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$engineAnalysisHash();

  @override
  String toString() {
    return r'engineAnalysisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EngineAnalysis create() => EngineAnalysis();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineAnalysisState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineAnalysisState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EngineAnalysisProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$engineAnalysisHash() => r'533eb7c40cbba7b28c41b5926ed5124b3fe003ea';

final class EngineAnalysisFamily extends $Family
    with
        $ClassFamilyOverride<
          EngineAnalysis,
          EngineAnalysisState,
          EngineAnalysisState,
          EngineAnalysisState,
          String
        > {
  EngineAnalysisFamily._()
    : super(
        retry: null,
        name: r'engineAnalysisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EngineAnalysisProvider call(String fen) =>
      EngineAnalysisProvider._(argument: fen, from: this);

  @override
  String toString() => r'engineAnalysisProvider';
}

abstract class _$EngineAnalysis extends $Notifier<EngineAnalysisState> {
  late final _$args = ref.$arg as String;
  String get fen => _$args;

  EngineAnalysisState build(String fen);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EngineAnalysisState, EngineAnalysisState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EngineAnalysisState, EngineAnalysisState>,
              EngineAnalysisState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
