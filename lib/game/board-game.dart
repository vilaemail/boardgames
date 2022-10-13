import 'dart:math';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_transform/stream_transform.dart';

import '../network/network.dart';
import '../util/assets.dart';
import '../util/environment.dart';
import '../util/logging.dart';
import '../util/script-transform.dart';
import 'components/component-collection.dart';
import 'components/component.dart';
import 'components/rules/rule-component.dart';
import 'components/rules/system-rules.dart';
import 'components/ux/board-component.dart';
import 'components/ux/piece-component.dart';
import 'components/view-component.dart';
import 'context.dart';
import 'definition/types.dart';
import 'definition/types.dart' as game_definition;
import 'events/dispatcher.dart';
import 'events/event.dart';
import 'events/game-over-event.dart';
import 'game-state.dart';
import 'multiplayer/client.dart';
import 'multiplayer/host.dart';
import 'multiplayer/network-communicator.dart';
import 'multiplayer/null-communicator.dart';
import 'multiplayer/types.dart';
import 'players.dart';

class BoardGame extends FlameGame with HasTappableComponents implements GameState {
  int _nextId = 0;
  @override
  ComponentId generateUniqueId() => '#${_nextId++}#';
  
  @override
  late final Players players;
  final ComponentCollection<Component> components;
  @override
  final ComponentCollection<BoardComponent> boards;
  @override
  final ComponentCollection<ViewComponent> views;
  @override
  final ComponentCollection<PieceComponent> pieces;
  @override
  final ComponentCollection<RuleComponent> rules;
  late ViewComponent activeView;
  @override
  final Assets assetsHandler;
  bool _gameOver = false;

  // Connects everything
  BoardGame._({
    required this.components,
    required this.boards,
    required this.views,
    required this.pieces,
    required this.rules,
    required this.assetsHandler,
  }) {
    debugMode = Environment.instance.isDebug;
  }

  static Future<BoardGame> create({
    required final game_definition.BoardGame gameDefinition,
    required final Network network,
    required final bool isLocal,
    required final bool isHost,
  }) async {
    final components = ComponentCollection<Component>();
    final boards = ComponentCollection<BoardComponent>(parents: [components]);
    final views = ComponentCollection<ViewComponent>(parents: [components]);
    final pieces = ComponentCollection<PieceComponent>(parents: [components]);
    final rules = ComponentCollection<RuleComponent>(parents: [components]);
    final assetsHandler = Assets(gameDefinition.metadata.name == 'Tic Tac Toe' ? 'tic-tac-toe' : 'connect-four'); // TODO: Do not hard code game id
    final world = World();
    final result = BoardGame._(
      components: components,
      boards: boards,
      views: views,
      pieces: pieces,
      rules: rules,
      assetsHandler: assetsHandler,
    );
    final context = Context(result, Dispatcher(isHost: isLocal || isHost));
    // TODO: Do not hardcode players but use actual data and game definition
    final playerOne = Player(result.generateUniqueId(), 'useridgoeshere', 'namegoeshere', PlayerState.playing);
    final playerTwo = Player(result.generateUniqueId(), 'useridgoeshere', 'namegoeshere', PlayerState.playing);
    final players = Players([playerOne, playerTwo], !isLocal && !isHost ? playerTwo : playerOne, isLocal: isLocal);
    result.players = players;

    final num screenHeight = max(WidgetsBinding.instance.window.physicalSize.height, minimalScreenDimension);
    final num screenWidth = max(WidgetsBinding.instance.window.physicalSize.width, minimalScreenDimension);
    sizeMultiplier = max(screenWidth / gameDefinition.resolution.x, screenHeight / gameDefinition.resolution.y);

    await assetsHandler.playMusic(); // TODO: Play music on whole app level, rather than game level (as we want player to get music immediatelly, not just while in game)

    for(final boardDefinition in gameDefinition.boards) {
      boards.add(BoardComponent(ComponentArgs(context, boardDefinition.id, boardDefinition)));
    }
    // TODO: Consider adding components in onLoad method
    await world.addAll(boards);
    for(final viewDefinition in gameDefinition.views) {
      views.add(ViewComponent(ComponentArgs(context, viewDefinition.id, viewDefinition), world));
    }
    final activeView = views.get(gameDefinition.startView);
    result.activeView = activeView;
    for (final pieceDefinition in gameDefinition.pieces) {
      for (var i = 0; i < pieceDefinition.count; i++) {
        // TODO Script transform should be part of deserialization
        final transformContext = TransformContext(null, players.list.map((final p) => p.id).toList());
        // TODO Solve cloning on broader level
        final clonedPiece = Piece(pieceDefinition.temp)
          ..id = scriptTransform(pieceDefinition.id, transformContext)
          ..owner = scriptTransform(pieceDefinition.owner, transformContext);
        pieces.add(PieceComponent(ComponentArgs(context, '#${clonedPiece.id}#$i#', clonedPiece))); // TODO: Restrict incoming id to not contain #
      }
    }
    await result.add(world);
    await result.add(activeView);
    for(final ruleDefinition in gameDefinition.rules) {
      rules.add(RuleComponent.fromDynamic(ComponentArgs(context, ruleDefinition.id ?? result.generateUniqueId(), ruleDefinition)));
    }

    // TODO: Should we remember these system rules somewhere
    PlayerStateChangeRule(ComponentArgs(context, result.generateUniqueId(), Rule({'type': 'player-state-change'})));
    context.dispatcher.performingActionEvents.whereType<GameOverEvent>().listen(result._onPerformingGameOverEvent);
    // TODO: Dispose of this variable on game end (maybe we don't need to do it explicitly and can just construct a class, but need to check)
    // ignore: unused_local_variable
    final MultiplayerHandler multiplayerHandler;
    if(isLocal) {
      multiplayerHandler = Host(NullCommunicator(), context.dispatcher);
    } else {
      if(isHost) {
        // Multiplayer host
        multiplayerHandler = Host(NetworkHost(context, network), context.dispatcher);
      } else {
        // Multiplayer client
        multiplayerHandler = Client(NetworkClient(context, network), context.dispatcher);
      }
    }

    return result;
  }

  @override
  void onRemove() {
    // TODO: How should we handle future here
    // ignore: discarded_futures
    assetsHandler.stopMusic();
    GameEvent.nextId = 0; // TODO: better way to handle ids per game (not static variable for whole program)
  }

  // Called by rules to influence game
  void _onPerformingGameOverEvent(final GameOverEvent event) {
    if(!_gameOver) {
      Log.info(() => 'game over!');
      _gameOver = true;
      GoRouter.of(buildContext!).go('/gameOver');
    }
  }
}
