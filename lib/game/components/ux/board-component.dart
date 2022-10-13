import 'package:flame/components.dart' show PositionComponent, Vector2;

import '../../definition/types.dart' as game_definition;
import '../component.dart';
import 'slot-grid-component.dart';

class BoardComponent extends PositionComponent with ComponentMixin<game_definition.Board> implements Component {
  List<SlotGridComponent> slots = [];

  BoardComponent(final ComponentArgs<game_definition.Board> args) {
    this.args = args;
    super.size = Vector2(args.definition.size.x, args.definition.size.y) * sizeMultiplier;
    for (final slot in args.definition.slots) {
      final component = SlotGridComponent(ComponentArgs(args.context, slot.id ?? args.context.state.generateUniqueId(), slot as game_definition.GridSlot));
      slots.add(component);
    }
  }

  @override
  Future<void> onLoad() async {
    await _loadBackground(); // TODO: Unify how we load assets and preload them before starting game
    await addAll(slots);
  }

  Future<PositionComponent> _loadBackground() async {
    final background = await args.context.state.assetsHandler.loadImageToComponent(args.definition.images)
      ..changePriorityWithoutResorting(-1)
      ..size = super.size
      ..position = Vector2(0, 0);
    await super.add(background);
    return background;
  }
}
