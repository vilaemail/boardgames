// TODO: Parse dynamics in types.dart
// ignore_for_file: avoid_dynamic_calls

import '../../../util/helper.dart';
import '../../../util/script-transform.dart';
import '../../events/event.dart';
import '../../events/player-events.dart';
import '../../players.dart';
import 'rule-component.dart';

class GridSlotCondition extends RuleComponent {
  bool _winLoseDecided = false;
  
  GridSlotCondition(super.args) {
    args.context.dispatcher.performingActionEvents.listen(_onEvent);
  }

  void _onEvent(final ActionEvent event) {
    if(_winLoseDecided) {
      return;
    }
    // TODO: We should evaluate at specific times, not on all events.
    // TODO: We end up evaluating too much and matching multiple outcomes (i.e. if whole grid is filled player has both won and drew)
    if(event is PlayerStateChangeEvent) {
      return; // TODO: Hacky way to prevent infinite loop
    }

    // TODO: All of this code is specific to win/lose action, but this condition can have other actions
    // TODO: We should separate it such that any condition can have win/lose action and this similar behavior
    // If all players won/lost nothing to do here
    if(args.context.state.players.list.every((final player) => player.state == PlayerState.drew || player.state == PlayerState.lost || player.state == PlayerState.won)) {
      return;
    }

    // TODO: Figure out if we should evaluate for every player or once for the "game" for this particular rule
    // TODO: Actually search for slot grid component
    var playerIndex = -1;
    for(final player in args.context.state.players.list) {
      playerIndex++;
      if (player.state == PlayerState.drew || player.state == PlayerState.lost || player.state == PlayerState.won) {
        continue;
      }
      // TODO: here we are raising win/lose/etc events with current player id set to a player which turn is not right now, document that other rules know this and don't do something unexpected
      final context = TransformContext(playerIndex, args.context.state.players.list.map((final p) => p.id).toList());
      final slotGrid = args.context.state.boards.first.slots[0]; // TODO: Do not hardcode but use ids from JSON
      final conditions = dynamicListToList(args.definition.source['conditions'], (final e) => e); // TODO: Parse once in constructor
      final pieces = args.definition.source['pieces'] != null ? dynamicListToList(args.definition.source['pieces'], (final e) => scriptTransform(e.toString(), context)) : <String>[];
      var fulfilled = false;
      for(final condition in conditions) {
        switch(condition['type'].toString()) {
          case 'no-empty-slot':
            if(slotGrid.allSlotsFilled()) {
              fulfilled = true;
              break;
            }
            break;
          case 'in-a-row':
            // TODO: implement what is missing
            if(condition['consecutive'].toString() != 'true') {
              throw Exception('Unsupported in-a-row condition configuration');
            }
            final vertically = condition['vertically'].toString() == 'true';
            final horizontally = condition['horizontally'].toString() == 'true';
            final diagonally = condition['diagonally'].toString() == 'true';
            final count = int.parse(condition['count'].toString());
            if(vertically ^ horizontally) {
              throw Exception('Unsupported in-a-row condition configuration');
            }
            if(vertically && slotGrid.hasInARowNonDiagonally(pieces, count)) {
              fulfilled = true;
              break;
            }
            if(diagonally && slotGrid.hasInARowDiagonally(pieces, count)) {
              fulfilled = true;
              break;
            }
            break;
          default:
            throw Exception('Unknown grid-slot-condition');
        }
        if(fulfilled) {
          break;
        }
      }
      if(!fulfilled) {
        continue;
      }
      // TODO: client shouldn't pefrom this calculation at all, the host will let us know if someone won/lost
      // TODO: For this (^) we likely want to have special kind of code which comes up with performing events which just happen "automatically" in the system, not because of some user action
      switch(args.definition.source['action'].toString()) {
        case 'win': // TODO: Allow JSON to specify if one player win means others lose
          _winLoseDecided = true;
          args.context.dispatcher.raiseEvent(PlayerStateChangeEvent(args.context, player.state, PlayerState.won, player, perform: true));
          for(final losingPlayer in args.context.state.players.list) {
            if(player == losingPlayer || losingPlayer.state == PlayerState.drew || losingPlayer.state == PlayerState.lost || losingPlayer.state == PlayerState.won) {
              continue;
            }
            // TODO: here we are raising win/lose/etc events with current player id set to a player which turn is not right now, document that other rules know this and don't do something unexpected
            args.context.dispatcher.raiseEvent(PlayerStateChangeEvent(args.context, losingPlayer.state, PlayerState.lost, losingPlayer, perform: true));
          }
          break;
        case 'draw':
          _winLoseDecided = true;
          // TODO: Figure out how not to recompute draw for every player
          args.context.dispatcher.raiseEvent(PlayerStateChangeEvent(args.context, player.state, PlayerState.drew, player, perform: true));
          break;
        default:
          throw Exception('Unknown action');
      }
    }
  }
}
