import 'events/dispatcher.dart';
import 'game-state.dart';

class Context {
  final GameState state;
  final Dispatcher dispatcher;

  Context(this.state, this.dispatcher);
}
