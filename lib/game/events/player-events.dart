import '../players.dart';
import 'event.dart';

enum PlayerTurnChange {
  start,
  finish
}
class PlayerTurnEvent extends ActionEvent {

  PlayerTurnEvent(super.context, this.change, {required super.perform});
  final PlayerTurnChange change;

  @override
  String toString() {
    final baseToString = super.toString();
    // TODO: We can't use context for important event parts, as we keep events in history and send between host/client
    return '${baseToString.substring(0, baseToString.length - 1)}, change:$change, player:${context.state.players.active.id}}';
  }

  @override
  PlayerTurnEvent toPerformable() {
    if(perform == true) {
      throw Exception('already performable');
    }
    return PlayerTurnEvent(context, change, perform: true);
  }
}

class PlayerStateChangeEvent extends ActionEvent {
  final PlayerState oldState;
  final PlayerState newState;
  final Player player;

  PlayerStateChangeEvent(super.context, this.oldState, this.newState, this.player, {required super.perform});

  @override
  String toString() {
    final baseToString = super.toString();
    return '${baseToString.substring(0, baseToString.length - 1)}, old:$oldState, new:$newState, player:${player.id}}';
  }

  @override
  PlayerStateChangeEvent toPerformable() {
    if(perform == true) {
      throw Exception('already performable');
    }
    return PlayerStateChangeEvent(context, oldState, newState, player, perform: true);
  }
}
