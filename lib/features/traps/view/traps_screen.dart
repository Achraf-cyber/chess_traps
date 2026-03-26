import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router.dart';
import '../../../utils.dart';

class TrapsScreen extends ConsumerStatefulWidget {
  const TrapsScreen({super.key});

  @override
  ConsumerState<TrapsScreen> createState() => _TrapsScreenState();
}

class _TrapsScreenState extends ConsumerState<TrapsScreen> {
  final controler = TextEditingController();
  var searchValue = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controler.dispose();
  }

  void updateChessResultList(String value) {
    setState(() {
      searchValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trapsGroups = ref.watch(trapsGroupSourceProvider);
    final trapsSearched = ref.watch(trapsSearchByNameProvider(searchValue));
    return SafeArea(
      child: Column(
        children: [
          Text(
            context.phrase.chessTraps,
            style: context.textTheme.titleLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: SearchBar(
              controller: controler,
              hintText: context.phrase.wildGambit,
              onChanged: (value) => updateChessResultList(value),
            ),
          ),
          if (searchValue.isEmpty)
            ChessGroupList(trapsGroups: trapsGroups)
          else
            ChessTrapsList(traps: trapsSearched),
        ],
      ),
    );
  }
}

class ChessGroupList extends StatelessWidget {
  const ChessGroupList({super.key, required this.trapsGroups});

  final Map<String, List<int>> trapsGroups;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,

        children: [
          for (final MapEntry(:key, :value) in trapsGroups.entries)
            Card(
              child: InkWell(
                onTap: () {
                  TrapGroupRoute(name: key).push<void>(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth * 0.8;
                        return StaticChessboard(
                          size: width,
                          orientation: .white,
                          fen: Position.initialPosition(.chess).fen,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        key,
                        style: context.textTheme.bodySmall!.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChessTrapsList extends StatelessWidget {
  const ChessTrapsList({super.key, required this.traps});

  final List<ChessTrap> traps;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,

        children: [
          for (final trap in traps)
            Card(
              child: InkWell(
                onTap: () {
                  TrapDetailRoute(index: trap.id).push<void>(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth * 0.8;
                        return StaticChessboard(
                          size: width,
                          orientation: .white,
                          fen: Position.initialPosition(.chess).fen,
                        );
                      },
                    ),
                    Center(
                      child: Text(
                        trap.trapName,
                        style: context.textTheme.bodySmall!.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
