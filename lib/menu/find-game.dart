import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nakama/rtapi.dart';
import 'package:go_router/go_router.dart';

import '../game/definition/types.dart' as game_definition;
import '../network/network.dart';
import '../util/logging.dart';

class FindGame extends StatefulWidget {
  final game_definition.BoardGame _gameDefinition;
  final Network _network;

  const FindGame(this._gameDefinition, this._network, {super.key});

  @override
  // TODO: Investigate how to implement what we want in better way
  // ignore: no_logic_in_create_state
  State<FindGame> createState() => FindGameState(_gameDefinition, _network);
}

class FindGameState extends State<FindGame> {
  final game_definition.BoardGame _gameDefinition;
  final Network _network;

  FindGameState(this._gameDefinition, this._network);
  
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final TextEditingController myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Boardgames')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go('/host/${_gameDefinition.metadata.name}'),
            child: const Text('Create Game'),
          ),
          ElevatedButton(
            onPressed: () => throw Exception('not implemented'),
            child: const Text('Scan QR Code'),
          ),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter game id',
            ),
            controller: myController,
          ),
          ElevatedButton(
            onPressed: () => {
              // TODO: Error handling and loading UX
              // ignore: discarded_futures
              _network.joinMatch(myController.text, ClientMatchCallbacks(context, '/play/${_gameDefinition.metadata.name}', myController.text, _network))
            },
            child: const Text('Join With Game Id'),
          ),
        ],
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('myController', myController));
  }
}

// TODO: when refactoring network+UX code remove use of this global variable
late ClientMatchCallbacks callbacks;

class ClientMatchCallbacks implements MatchCallbacks {
  final BuildContext _context;
  final String _playUrl;
  @override
  String matchId;
  final Network _network;
  late Function(MatchData data) _callback;

  ClientMatchCallbacks(this._context, this._playUrl, this.matchId, this._network) {
    callbacks = this;
  }

  // TODO: This whole class is a hack, ignore until we remove the whole class
  // ignore: use_setters_to_change_properties
  void registerOnData(final Function(MatchData data) callback) {
    _callback = callback;
  }

  @override
  void onData(final MatchData data) {
    _callback(data);
  }

  @override
  void onFinished() {
    // TODO: Handle this through dispatcher events maybe?
    Log.debug(() => 'Game is finished, other player left!');
    // TODO: Error handling and loading UX
    // ignore: discarded_futures
    _network.leaveMatch(matchId);
  }

  @override
  void onReady() {
    _context.go(_playUrl);
  }
}
