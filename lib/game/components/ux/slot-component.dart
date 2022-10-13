import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flame/experimental.dart';

import '../../definition/types.dart' as game_definition;
import '../../events/slot-events.dart';
import '../component.dart';
import 'piece-component.dart';

class SlotComponent extends PositionComponent with ComponentMixin<game_definition.Slot>, TapCallbacks implements Component {
  String get pieceId => _piece!.id;
  PieceComponent? _piece;

  SlotComponent(final ComponentArgs<game_definition.Slot> args) {
    this.args = args;
    size = Vector2(args.definition.size.x, args.definition.size.y) * sizeMultiplier;
  }

  bool hasPiece() => _piece != null;

  Future<void> putPiece(final PieceComponent pieceToPut) async {
    if(_piece != null) {
      throw Exception('Can not put piece into filled slot');
    }
    _piece = pieceToPut;
    await add(pieceToPut);
  }

  PieceComponent removePiece() {
    if(_piece == null) {
      throw Exception('Can not remove piece when there is none in the slot');
    }
    final piece = _piece!;
    _piece = null;
    remove(piece);
    return piece;
  }

  @override
  void onTapUp(final TapUpEvent event) {
    args.context.dispatcher.raiseEvent(SlotClickEvent(args.context, this));
  }
}
