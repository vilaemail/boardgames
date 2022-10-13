import 'package:flame/components.dart' show Anchor, Vector2;
import 'package:flame/experimental.dart' show CameraComponent, World;

import '../definition/types.dart' as game_definition;
import 'component.dart';

class ViewComponent extends CameraComponent with ComponentMixin<game_definition.View> implements Component {
  ViewComponent(final ComponentArgs<game_definition.View> args, final World world): super(world: world) {
    this.args = args;
    for (final boardRef in args.definition.boards) {
      args.context.state.boards.get(boardRef.id).position = Vector2(boardRef.position.x, boardRef.position.y) * sizeMultiplier;
    }
    viewfinder
      ..visibleGameSize = Vector2(args.definition.size.x, args.definition.size.y) * sizeMultiplier
      ..position = Vector2(args.definition.position.x, args.definition.position.y) * sizeMultiplier
      ..anchor = anchorMapping[args.definition.anchor]!;
  }

  static Map<String, Anchor> anchorMapping = {
    'center': Anchor.center
  };
}
