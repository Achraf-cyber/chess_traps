import 'package:chess_traps/presentation/state/play/play_game_provider.dart';
import 'package:chess_traps/presentation/state/play/play_history_provider.dart';
import 'package:chess_traps/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which games the list is showing.
enum _GameFilter { all, engine, friend }

/// Full-screen browser for saved games.
///
/// The bottom sheet on the play screen stays as the quick way to resume the
/// last few games. It is a poor place to *look through* a long history: it
/// caps at roughly half the screen and has no way to separate engine games
/// from pass-and-play ones. This screen exists for people with enough games
/// that scrolling the sheet stopped being reasonable.
class GameHistoryScreen extends ConsumerStatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  ConsumerState<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends ConsumerState<GameHistoryScreen> {
  _GameFilter _filter = _GameFilter.all;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(playHistoryProvider);
    final notifier = ref.read(playGameProvider.notifier);

    // Newest first: the game you most likely want is the one you just played.
    final games = history.savedGames.reversed.where((g) {
      return switch (_filter) {
        _GameFilter.all => true,
        _GameFilter.engine => !g.isFriendGame,
        _GameFilter.friend => g.isFriendGame,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.phrase.gameHistoryTitle)),
      body: Column(
        children: [
          _SummaryBar(history: history),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _FilterChip(
                  label: context.phrase.allGames,
                  selected: _filter == _GameFilter.all,
                  onSelected: () => setState(() => _filter = _GameFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: context.phrase.vsStockfish,
                  selected: _filter == _GameFilter.engine,
                  onSelected: () =>
                      setState(() => _filter = _GameFilter.engine),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: context.phrase.vsFriend,
                  selected: _filter == _GameFilter.friend,
                  onSelected: () =>
                      setState(() => _filter = _GameFilter.friend),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: games.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 48,
                          color: context.colors.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.phrase.noSavedGames,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: games.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return _GameTile(
                        game: game,
                        onTap: () {
                          notifier.viewSavedGame(game);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.history});

  final PlayHistory history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(context, context.phrase.wins, history.wins, Colors.green),
          _stat(context, context.phrase.draws, history.draws, Colors.orange),
          _stat(context, context.phrase.losses, history.losses, Colors.red),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: context.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.game, required this.onTap});

  final SavedGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(game.date);
    final (icon, color) = game.isFriendGame
        ? switch (game.result) {
            'white' || 'black' => (Icons.emoji_events_rounded, Colors.blueGrey),
            _ => (Icons.handshake_rounded, Colors.orange),
          }
        : switch (game.result) {
            'win' => (Icons.emoji_events_rounded, Colors.green),
            'loss' => (Icons.psychology_rounded, Colors.red),
            _ => (Icons.handshake_rounded, Colors.orange),
          };

    final resultLabel = game.isFriendGame
        ? switch (game.result) {
            'white' => context.phrase.whiteWins,
            'black' => context.phrase.blackWins,
            _ => context.phrase.draw,
          }
        : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        date != null
            ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
            : game.date,
      ),
      subtitle: Text(
        // pgnMoves counts plies; chess counts a move as White plus Black.
        '${(game.pgnMoves.length / 2).ceil()} ${context.phrase.moves}'
        '${resultLabel != null ? ' · $resultLabel' : ''}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          game.isFriendGame
              ? context.phrase.vsFriend
              : context.phrase.vsStockfish,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
