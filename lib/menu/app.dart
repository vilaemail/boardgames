import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../game/board-game.dart';
import '../game/definition/types.dart' as game_definition;
import '../network/network.dart';
import '../util/environment.dart';
import 'choose-game.dart';
import 'find-game.dart';
import 'game-over.dart';
import 'log-in.dart';
import 'main-menu.dart';
import 'waiting-for-players.dart';

class App extends StatelessWidget {
  late final GoRouter _router = _constructRouter();
  final List<game_definition.BoardGame> _games;
  final Network _network;

  App(this._games, this._network, {super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: 'Boardgames',
    );
  
  GoRouter _constructRouter() => GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (final context, final state) => MainMenu(_network),
        ),
        GoRoute(
          path: '/login',
          builder: (final context, final state) => LogIn(_network),
        ),
        GoRoute(
          path: '/chooseGame',
          builder: (final context, final state) => ChooseGame(_games, isLocal: state.queryParams['local'] == '1'),
        ),
        GoRoute(
          path: '/settings',
          builder: (final context, final state) {
            throw Exception('not yet implemented');
          },
        ),
        GoRoute(
          path: '/gameOver',
          builder: (final context, final state) => const GameOver(),
        ),
        GoRoute(
          name: 'find',
          path: '/find/:gameId',
          builder: (final context, final state) => FindGame(_games.firstWhere((final element) => element.metadata.name == state.params['gameId']!), _network),
        ),
        GoRoute(
          path: '/host/:gameId',
          builder: (final context, final state) => WaitingForPlayers(_games.firstWhere((final element) => element.metadata.name == state.params['gameId']!), _network),
        ),
        GoRoute(
          name: 'play',
          path: '/play/:gameId',
          builder: (final context, final state) => FutureBuilder<BoardGame>(
            // TODO: Fix this. Excerpt from documentation is below:
            // The [future] must have been obtained earlier, e.g. during [State.initState],
            // [State.didUpdateWidget], or [State.didChangeDependencies]. It must not be
            // created during the [State.build] or [StatelessWidget.build] method call when
            // constructing the [FutureBuilder]. If the [future] is created at the same
            // time as the [FutureBuilder], then every time the [FutureBuilder]'s parent is
            // rebuilt, the asynchronous task will be restarted.
            // ignore: discarded_futures
            future: BoardGame.create(gameDefinition: _games.firstWhere((final element) => element.metadata.name == state.params['gameId']!), isLocal: state.queryParams['local'] == '1', isHost: state.queryParams['host'] == '1', network: _network),
            builder: (final context, final snapshot) => GameWidget(
              // TODO: Figure out how to use gameId (unique identifier) and not the user facing string. Here and in other places.
              game: snapshot.requireData,
            ),
          ),
        ),
      ],
      initialLocation: '/',
      debugLogDiagnostics: Environment.instance.isDebug,
    );
}
