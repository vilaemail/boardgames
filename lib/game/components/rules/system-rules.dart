import 'package:stream_transform/stream_transform.dart';

import '../../events/game-over-event.dart';
import '../../events/player-events.dart';
import '../../players.dart';
import 'rule-component.dart';

class PlayerStateChangeRule extends RuleComponent {
  PlayerStateChangeRule(super.args) {
    args.context.dispatcher.performingActionEvents.whereType<PlayerStateChangeEvent>().listen(_onPerformingPlayerStateChangeEvent);
  }
  
  void _onPerformingPlayerStateChangeEvent(final PlayerStateChangeEvent event) {
    if(event.player.state != event.newState) {
      args.context.dispatcher.applyStateChange(event, () {
        // TODO: different behavior when non-local multiplayer
        // TODO: Collect all win/lose information and then "end" the game
        // TODO: "caller" of the game should detect game "end" and then show win/draw/lose screen
        event.player.state = event.newState;
        if(args.context.state.players.list.every((final player) => player.state == PlayerState.drew || player.state == PlayerState.lost || player.state == PlayerState.won)) {
          // All players have win/lost/draw state -> finish the game
          // TODO: In multiplayer we want to finish for the current player immediatelly and allow him to watch
          // TODO: In multiplayer for other players we want to show info, and let them keep playing
          // TODO: Sound on game over
          // TODO: Show info who won, etc.
          event.context.dispatcher.raiseEvent(GameOverEvent(event.context, perform: true));
        }
      });
    }
  }
}
