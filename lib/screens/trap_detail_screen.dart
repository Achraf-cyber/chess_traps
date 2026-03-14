import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chessground/chessground.dart' as cg;

class TrapDetailScreen extends ConsumerWidget {
  final int trapIndex;
  
  const TrapDetailScreen({super.key, required this.trapIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Trap Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: cg.Board(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trap Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Move list will go here...', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.fast_rewind)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.fast_forward)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
