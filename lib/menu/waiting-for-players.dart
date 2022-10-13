import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../game/definition/types.dart' as game_definition;
import '../network/network.dart';
import 'find-game.dart';

class WaitingForPlayers extends StatefulWidget {
  final game_definition.BoardGame _gameDefinition;
  final Network _network;

  const WaitingForPlayers(this._gameDefinition, this._network, {super.key});

  @override
  // TODO: Investigate how to implement what we want in better way
  // ignore: no_logic_in_create_state
  State<WaitingForPlayers> createState() => WaitingForPlayersState(_gameDefinition, _network);
}

class WaitingForPlayersState extends State<WaitingForPlayers> {
  final game_definition.BoardGame _gameDefinition;
  final Network _network;

  WaitingForPlayersState(this._gameDefinition, this._network);
  
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
            onPressed: () => {
              // TODO: Error handling and loading UX
              // ignore: discarded_futures
              _network.createMatch(ClientMatchCallbacks(context, '/play/${_gameDefinition.metadata.name}?host=1', myController.text, _network)).then((final id) => { myController.text = id })
            },
            child: const Text('Create'),
          ),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Game id will appear here when you click on Create',
            ),
            controller: myController,
          ),
          ElevatedButton(
            onPressed: () => {
              // TODO: Error handling and loading UX
              // ignore: discarded_futures
              _network.leaveMatch(myController.text), context.go('/')
            },
            child: const Text('Cancel'),
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
