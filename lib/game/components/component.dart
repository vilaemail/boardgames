import '../context.dart';

// TODO: Figure out how to access these global variables
int minimalScreenDimension = 1000;
double sizeMultiplier = 1;

typedef ComponentId = String;

abstract class Component {
  /// Unique id of the component in the game
  abstract final ComponentId id;
  /// Id of the component as defined in game.json. Does not need to be unique, as one definition can have multiple instances.
  abstract final ComponentId? definitionId;
}

mixin ComponentMixin<T extends Object> {
  late final ComponentArgs<T> args;
  late final ComponentId? definitionId = _initializeDefinitionId();
  ComponentId get id => args.id;

  ComponentId? _initializeDefinitionId() {
    try {
      // TODO: This is ugly way of fetching id, just for convenience of using mixin, consider alternate approaches.
      // ignore: avoid_dynamic_calls
      final defId = (args.definition as dynamic).id;
      if(defId is String) {
        return defId;
      }
    // TODO: This is ugly way of fetching id, just for convenience of using mixin, consider alternate approaches.
    // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      // TODO: This is ugly way of fetching id, just for convenience of using mixin, consider alternate approaches.
    }
    return null;
  }
}

class ComponentArgs<T extends Object> {
  final Context context;
  final ComponentId id;
  final T definition;

  ComponentArgs(this.context, this.id, this.definition);
}
