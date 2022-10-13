import 'dart:convert';

import '../../menu/find-game.dart';
import '../../network/network.dart';
import '../../util/logging.dart';
import '../context.dart';
import '../events/event.dart';
import '../events/game-over-event.dart';
import '../events/player-events.dart';
import '../events/slot-events.dart';
import '../players.dart';
import 'types.dart';

// TODO: We need to sync initial game state after initialization
class NetworkHost implements HostCommunicator {
  final Context _context;
  final Network _network;
  
  NetworkHost(this._context, this._network);
  
  @override
  void init(final Function(ActionEvent event) processor) {
    callbacks.registerOnData((final data) => processor(_deserialize(data.data)));
  }

  @override
  Future<void> send(final HistoryEntry entry) => _network.sendData(callbacks.matchId, _serialize(entry));

  // TODO: maintainable way of serialization/deserialization as we add new events/edit existing events
  // ignore_for_file: avoid_dynamic_calls
  ActionEvent _deserialize(final List<int> byteData) {
    final str = utf8.decode(byteData);
    Log.debug(() => 'Received: $str');
    final dynamic data = jsonDecode(str);    
    return _deserializeActionEvent(data, _context);
  }

  List<int> _serialize(final HistoryEntry entry) {
    final dynamic data = _serializeActionEvent(entry.event);
    data['id'] = entry.id;
    final str = jsonEncode(data);
    Log.debug(() => 'Sending: $str');
    final byteData = utf8.encode(str);
    return byteData;
  }
}

class NetworkClient implements ClientCommunicator {
  final Context _context;
  final Network _network;
  
  NetworkClient(this._context, this._network);
  
  @override
  void init(final Function(HistoryEntry event) processor) {
    callbacks.registerOnData((final data) => processor(_deserialize(data.data)));
  }

  @override
  Future<void> send(final ActionEvent entry) => _network.sendData(callbacks.matchId, _serialize(entry));

  HistoryEntry _deserialize(final List<int> byteData) {
    final str = utf8.decode(byteData);
    Log.debug(() => 'Received: $str');
    final dynamic data = jsonDecode(str);    
    final actionEvent = _deserializeActionEvent(data, _context);
    final id = int.parse(data['id'].toString());
    return HistoryEntry(actionEvent, id);
  }

  List<int> _serialize(final ActionEvent event) {
    final dynamic data = _serializeActionEvent(event);
    final str = jsonEncode(data);
    Log.debug(() => 'Sending: $str');
    final byteData = utf8.encode(str);
    return byteData;
  }
}

// TODO: Put these serialization/deserialization methods on event types, and do not use runtimeType (as it is unstable in production code)
ActionEvent _deserializeActionEvent(final data, final Context context) {
  switch(data['type'].toString()) {
    case 'GameOverEvent':
      return GameOverEvent(context, perform: data['perform'].toString() == 'true');
    case 'SlotFillEvent':
      return SlotFillEvent(context, perform: data['perform'].toString() == 'true', context.state.boards.first.slots.first.slots.firstWhere((final element) => element.any((final element) => element.id == data['slot'].toString())).firstWhere((final element) => element.id == data['slot'].toString()), context.state.pieces.get(data['piece'].toString()));
    case 'PlayerTurnEvent':
      return PlayerTurnEvent(context, perform: data['perform'].toString() == 'true', PlayerTurnChange.values[int.parse(data['change'].toString())]);
    case 'PlayerStateChangeEvent':
      return PlayerStateChangeEvent(context, perform: data['perform'].toString() == 'true', PlayerState.values[int.parse(data['oldState'].toString())], PlayerState.values[int.parse(data['newState'].toString())], context.state.players.list.firstWhere((final element) => element.id == data['player'].toString()));
    default:
      throw Exception('Unsupported event');
  }
}

dynamic _serializeActionEvent(final ActionEvent event) {
  final dynamic result = {};
  result['type'] = event.runtimeType.toString();
  result['perform'] = event.perform;
  if(event is GameOverEvent) {
    // No fields to serialize
  } else if(event is SlotFillEvent) {
    result['slot'] = event.slot.id;
    result['piece'] = event.piece.id;
  } else if(event is PlayerTurnEvent) {
    result['change'] = event.change.index;
  } else if(event is PlayerStateChangeEvent) {
    result['oldState'] = event.oldState.index;
    result['newState'] = event.newState.index;
    result['player'] = event.player.id;
  } else {
    throw Exception('Unsupported event');
  }
  return result;
}
