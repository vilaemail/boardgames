// TODO: Parse dynamics in types.dart
// ignore_for_file: avoid_dynamic_calls

import 'package:stream_transform/stream_transform.dart';

import '../../../util/helper.dart';
import '../../../util/script-transform.dart';
import '../../events/slot-events.dart';
import 'rule-component.dart';

class FillSlotActionRule extends RuleComponent {
  FillSlotActionRule(super.args) {
    args.context.dispatcher.performingActionEvents.whereType<SlotFillEvent>().listen(_onPerformedSlotFillEvent);
    args.context.dispatcher.uxEvents.whereType<SlotClickEvent>().listen(_onSlotClickEvent);
  }

  void _onPerformedSlotFillEvent(final SlotFillEvent event) {
    args.context.dispatcher.applyStateChange(event, () {
      incrementUsage();
      // TODO: Handle futures and actions (should be postponed) in event handlers
      // ignore: discarded_futures
      event.piece.transition('played'); // TODO: Do not hard code, but provide in JSON
      // TODO: Handle futures and actions (should be postponed) in event handlers
      // ignore: discarded_futures
      event.slot.putPiece(event.piece);
    });
  }

  void _onSlotClickEvent(final SlotClickEvent event) {
    if(!args.context.state.players.canPlayForThisUser) {
      return; // TODO: Maybe notify user
    }
    final applicableSlots = dynamicListToList(args.definition.source['slots'], (final e) => e.toString()); // TODO: Parse once in constructor
    if(!applicableSlots.any((final acceptedSlot) => acceptedSlot == event.component.id || event.component.id.startsWith('#$acceptedSlot#'))) {
      return;
    }
    final pieces = dynamicListToList(args.definition.source['pieces'], (final e) => scriptTransform(e.toString(), TransformContext(args.context.state.players.activeIndex, args.context.state.players.list.map((final p) => p.id).toList()))); // TODO: Do we want to evaluate script here?
    // TODO: The startswith condition is not correct, we need to do better
    // TODO: the way we use # for multiple things might be security vulnerability, investigate that and update accordingly
    var possiblePieces = args.context.state.pieces.where((final candidatePiece) => pieces.any((final acceptedPiece) => candidatePiece.id == acceptedPiece || candidatePiece.id.startsWith('#$acceptedPiece#'))).toList(); // TODO: Do not hard code state value, but specify that in conditions field in JSON
    if(possiblePieces.isEmpty) {
      return; // TODO: Maybe inform user
    }
    final conditions = dynamicListToList(args.definition.source['conditions'], (final e) => e); // TODO: Parse once in constructor
    for(final condition in conditions) {
      switch(condition['type'].toString()) {
        case 'slot-empty':
          if(event.component.hasPiece()) {
            return; // TODO: Maybe inform user
          }
          break;
        case 'piece-not-played':
          possiblePieces = args.context.state.pieces.where((final element) => possiblePieces.any((final e) => e.id == element.id) && element.state == 'not-played').toList(); // TODO: Do not hard code state value, but specify that in conditions field in JSON
          if(possiblePieces.isEmpty) {
            return; // TODO: Maybe inform user
          }
          break;
        case 'neighbours-condition':
          final up = condition['up'].toString() == 'true';
          final down = condition['down'].toString() == 'true';
          if(!(up ^ down)) {
            throw Exception('Unsupported direction');
          }
          if(condition['count'].toString() != 'maximum') {
            throw Exception('Unsupported count');
          }
          final subConditions = dynamicListToList(condition['conditions'], (final e) => e);
          if(subConditions.length != 1) {
            throw Exception('Unsupported conditions');
          }
          final subCondition = subConditions[0]['type'].toString();
          if(subCondition != 'slot-empty' && subCondition != 'slot-filled') {
            throw Exception('Unsupported condition');
          }
          final slotGrid = args.context.state.boards.first.slots[0]; // TODO: Do not hardcode but use ids from JSON
          final hasElements = slotGrid.hasElementsInDirection(event.component, up ? 'up' : 'down');
          if(hasElements != 'yes' && hasElements != 'no-elements' && subCondition == 'slot-filled') {
            return; // TODO: Maybe inform user
          }
          if(hasElements != 'no' && hasElements != 'no-elements' && subCondition == 'slot-empty') {
            return; // TODO: Maybe inform user
          }
          break;
        default:
          throw Exception('unsupported condition in fill-slot-action rule');
      }
    }
    if(exhausted()) {
      return; // TODO: Maybe inform user
    }
    final piece = possiblePieces[0];
    args.context.dispatcher.raiseEvent(SlotFillEvent(args.context, event.component, piece, perform: false));
  }
}
