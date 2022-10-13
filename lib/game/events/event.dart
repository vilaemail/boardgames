import '../context.dart';

class GameEvent {
  final Context context;
  static int nextId = 0;
  final int id = nextId++;

  GameEvent(this.context);

  @override
  // TODO: Replace with type name used for serialization
  // ignore: no_runtimetype_tostring
  String toString() => '{$runtimeType[$id]}';
}

class UxEvent extends GameEvent {
  UxEvent(super.context);
}

class StateChangeEvent extends GameEvent {
  StateChangeEvent(super.context);
}

abstract class ActionEvent extends GameEvent {
  /// Set to true if event should be executed.
  /// Set to false if event is a "desired" action event, yet to be "confirmed". This is done by the match host, to ensure consistent state across all clients.
  final bool perform;

  ActionEvent(super.context, {required this.perform});
  
  @override
  String toString() {
    final baseToString = super.toString();
    return '${baseToString.substring(0, baseToString.length - 1)}, perform:$perform}';
  }

  ActionEvent toPerformable();
}
