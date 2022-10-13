import '../components/ux/piece-component.dart';
import '../components/ux/slot-component.dart';
import 'event.dart';

class SlotClickEvent extends UxEvent {
  final SlotComponent component;

  SlotClickEvent(super.context, this.component);

  @override
  String toString() {
    final baseToString = super.toString();
    return '${baseToString.substring(0, baseToString.length - 1)}, slot:${component.id}}';
  }
}

class SlotFillEvent extends ActionEvent {
  final SlotComponent slot;
  final PieceComponent piece;

  SlotFillEvent(super.context, this.slot, this.piece, {required super.perform});
  
  @override
  String toString() {
    final baseToString = super.toString();
    return '${baseToString.substring(0, baseToString.length - 1)}, slot:${slot.id}, piece:${piece.id}}';
  }

  @override
  SlotFillEvent toPerformable() {
    if(perform == true) {
      throw Exception('already performable');
    }
    return SlotFillEvent(context, slot, piece, perform: true);
  }
}
