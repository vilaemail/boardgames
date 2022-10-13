import 'package:flame/components.dart' show PositionComponent, Vector2;

import '../../definition/types.dart' as game_definition;
import '../component.dart';
import 'slot-component.dart';

class SlotGridComponent extends PositionComponent with ComponentMixin<game_definition.GridSlot> implements Component {
  late List<List<SlotComponent>> _slots;
  List<List<SlotComponent>> get slots => _slots;

  SlotGridComponent(final ComponentArgs<game_definition.GridSlot> args) {
    this.args = args;
    position = Vector2(args.definition.position.x, args.definition.position.y) * sizeMultiplier;
    size = Vector2(args.definition.size.x, args.definition.size.y) * sizeMultiplier;
    final slotSpacingHorizontal = ((args.definition.size.x) - args.definition.dimensions[1] * args.definition.slot.size.x) / (args.definition.dimensions[1] - 1);
    final slotSpacingVertical = ((args.definition.size.y) - args.definition.dimensions[0] * args.definition.slot.size.y) / (args.definition.dimensions[0] - 1);
    _slots = [];
    for(var i = 0; i < args.definition.dimensions[0]; i++) {
      final row = <SlotComponent>[];
      for(var j = 0; j < args.definition.dimensions[1]; j++) {
        final slot = SlotComponent(ComponentArgs(args.context, '#${args.definition.slot.id}#${i*args.definition.dimensions[1]+j}#', args.definition.slot))
          ..position = Vector2(j * (args.definition.slot.size.x + slotSpacingHorizontal), i * (args.definition.slot.size.y + slotSpacingVertical)) * sizeMultiplier;
        row.add(slot);
      }
      _slots.add(row);
    }
  }


  @override
  Future<void> onLoad() => Future.wait(_slots.map(addAll));

  // TODO: This code is bad and duplicated with one in the RuleComponent
  bool pieceMatch(final List<String> accepted, final String candidatePiece) => accepted.any((final acceptedPiece) => candidatePiece == acceptedPiece || candidatePiece.startsWith('#$acceptedPiece#'));

  // TODO: Better interface for querying stuff on slot grid
  bool hasInARowNonDiagonally(final List<String> pieces, final int count) {
    var consecutive = 0;
    for(var i = 0; i < _slots.length; i++) {
      // Check row
      for(var j = 0; j< _slots[0].length; j++) {
        if(_slots[i][j].hasPiece() && pieceMatch(pieces, _slots[i][j].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
      // Check column
      for(var j = 0; j< _slots.length; j++) {
        if(_slots[j][i].hasPiece() && pieceMatch(pieces, _slots[j][i].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
    }
    return false;
  }

  bool hasInARowDiagonally(final List<String> pieces, final int count) {
    var consecutive = 0;
    for(var i = 0; i < _slots.length; i++) {
      // Check left-column down-right diagonal
      for(var j = 0; i+j < _slots.length && j< _slots[0].length; j++) {
        if(_slots[i+j][j].hasPiece() && pieceMatch(pieces, _slots[i+j][j].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
      // Check right-column down-right diagonal
      for(var j = 0; i+j < _slots.length && j<_slots[0].length; j++) {
        if(_slots[i+j][_slots[i].length-1-j].hasPiece() && pieceMatch(pieces, _slots[i+j][_slots[i].length-1-j].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
    }
    for(var i = 0; i < _slots[0].length; i++) {
      // Check top-row down-right diagonal
      for(var j = 0; j < _slots.length && i+j< _slots[0].length; j++) {
        if(_slots[j][i+j].hasPiece() && pieceMatch(pieces, _slots[j][i+j].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
      // Check top-row down-left diagonal
      for(var j = 0; j < _slots.length && i-j>=0; j++) {
        if(_slots[j][i-j].hasPiece() && pieceMatch(pieces, _slots[j][i-j].pieceId)) {
          consecutive++;
        } else {
          consecutive = 0;
        }
        if(consecutive == count) {
          return true;
        }
      }
      consecutive = 0;
    }
    return false;
  }

  bool allSlotsFilled() => _slots.every((final element) => element.every((final element) => element.hasPiece()));

  // TODO: Return enum
  String hasElementsInDirection(final SlotComponent slot, final String direction) {
    int? slotX;
    int? slotY;
    for(var i =0;i<_slots.length; i++) {
      for(var j=0;j<_slots[0].length; j++) {
        if(_slots[i][j] == slot) {
          slotX = j;
          slotY = i;
        }
      }
    }
    if(slotX == null || slotY == null) {
      throw Exception('Slot not in grid');
    }
    var tested = 0;
    var has = 0;
    if(direction == 'up') {
      for(var j=slotY-1;j>=0;j--) {
        tested++;
        if(_slots[j][slotX].hasPiece()) {
          has++;
        }
      }
    } else if(direction == 'down') {
      for(var j=slotY+1;j<_slots.length;j++) {
        tested++;
        if(_slots[j][slotX].hasPiece()) {
          has++;
        }
      }
    } else {
      throw Exception('Unsupported direction');
    }
    if(tested == 0) {
      return 'no-elements';
    }
    if(tested == has) {
      return 'yes';
    }
    if(has == 0) {
      return 'no';
    }
    return 'some';
  }
}
