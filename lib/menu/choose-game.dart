import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../game/definition/types.dart' as game_definition;

class ChooseGame extends StatelessWidget {
  final List<game_definition.BoardGame> _games;
  final bool _isLocal;

  const ChooseGame(this._games, {required final bool isLocal, super.key}): _isLocal = isLocal;

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Boardgames')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ..._games.map((final game) =>
            ElevatedButton(
              onPressed: () => _isLocal ? context.go('/play/${game.metadata.name}?local=1') : context.go('/find/${game.metadata.name}'),
              child: Text('Play ${game.metadata.name}'),
            ),
          ),
        ],
      ),
    ),
  );
}
