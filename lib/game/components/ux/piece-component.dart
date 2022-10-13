// We are using firstWhereOrNull extension which linter doesn't see
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'package:flame/components.dart' show PositionComponent, Vector2;

import '../../../util/future-value.dart';
import '../../definition/types.dart' as game_definition;
import '../component.dart';

class PieceComponent extends PositionComponent with ComponentMixin<game_definition.Piece> implements Component {
  String _state;
  String get state => _state;
  late FutureValue<PositionComponent> _graphics;

  PieceComponent(final ComponentArgs<game_definition.Piece> args) : _state = args.definition.states[0].id {
    this.args = args;
    final state = args.definition.states.firstWhere((final e) => e.id == _state);
    position = Vector2(0, 0);
    size = Vector2(state.size.x, state.size.y) * sizeMultiplier;
    // TODO: Unify how we load assets and preload them before starting game
    // ignore: discarded_futures
    _graphics = FutureValue(_loadGraphics());
  }

  Future<PositionComponent> _loadGraphics() async {
    final graphics = await args.context.state.assetsHandler.loadImageToComponent(args.definition.images)
      ..size = super.size
      ..position = Vector2(0, 0);
    await super.add(graphics);
    return graphics;
  }

  Future<void> transition(final String newState) async {
    final oldState = _state;
    final transition = args.definition.transitions.firstWhereOrNull((final e) => e.from == oldState && e.to == newState);
    if(transition != null) {
      await args.context.state.assetsHandler.playAudio(transition.sounds);
    }
    _state = newState;
    final state = args.definition.states.firstWhere((final e) => e.id == _state);
    size = Vector2(state.size.x, state.size.y) * sizeMultiplier;
    if(_graphics.isCompleted) {
      _graphics.result.size = size;
    }
  }
}
