import 'dart:async';
import 'dart:collection';

import 'package:stream_transform/stream_transform.dart';

import '../../util/logging.dart';
import 'event.dart';

class Dispatcher {
  final StreamController<GameEvent> _events = StreamController<GameEvent>();
  final ListQueue<void Function()> _stateChanges = ListQueue<void Function()>(50);
  final bool _isHost;
  StreamSubscription<GameEvent>? _controller;
  late final Stream<GameEvent> events = _events.stream.asBroadcastStream(onListen: _onEventsListen);
  late final Stream<UxEvent> uxEvents = events.whereType<UxEvent>();
  late final Stream<StateChangeEvent> stateChangeEvents = events.whereType<StateChangeEvent>();
  late final Stream<ActionEvent> actionEvents = events.whereType<ActionEvent>();
  late final Stream<ActionEvent> performingActionEvents = actionEvents.where((final event) => event.perform);
  late final Stream<ActionEvent> nonPerformingActionEvents = actionEvents.where((final event) => !event.perform);

  Dispatcher({required final isHost}): _isHost = isHost {
    void loggingListener(final GameEvent event) => Log.debug(() => '  processing $event');
    // TODO: Should we remember the returned StreamSubscription (here and throughout code) and cancel it at later point in time?
    events.listen(loggingListener);
  }

  void _onEventsListen(final StreamSubscription<GameEvent> controller) {
    // TODO: Is there better way to do this
    // ignore: unnecessary_null_comparison
    if(_controller != null) {
      _controller = controller;
    }
  }

  void _exhaustStateChanges() {
    Log.debug(() => '    (applying ${_stateChanges.length} state changes)');
    final controller = _controller;
    controller?.pause();
    while(_stateChanges.isNotEmpty) {
      final stateChangeToApply = _stateChanges.removeLast();
      stateChangeToApply();
    }
    controller?.resume();
    Log.debug(() => '    (finished applying state changes)');
  }

  void raiseEvent(final GameEvent event) {
    void log(final String operation) => Log.debug(() => '    ($operation ${event.runtimeType}[${event.id}])'); // TODO: Replace with type name used for serialization
    if(event is UxEvent || event is StateChangeEvent) {
      log('queued');
      _events.add(event);
    } else if(event is ActionEvent) {
      if(event.perform) {
        if(_isHost) {
          log('queued');
          _events.add(event);
        } else {
          log('discard'); // Performing events will come from host via [raiseEventComingFromHost] method
        }
      } else {
        log('queued');
        _events.add(event);
      }
    } else {
      throw Exception('Unexpected event type raised');
    }
  }

  // TODO: Somehow enforce state changes are happening ONLY via this method
  void applyStateChange(final ActionEvent event, final void Function() applier) {
    if(!event.perform) {
      throw Exception('State can only be changed on ActionEvent which has perform set to true.');
    }
    Log.debug(() => '    (queued state change ${event.runtimeType}[${event.id}])'); // TODO: Replace with type name used for serialization
    _stateChanges.addFirst(applier);
    if(_stateChanges.length == 1) {
      Future.delayed(Duration.zero, _exhaustStateChanges);
    }
  }

  /// Use only from Host and Client classes
  /// TODO: Better way of "protecting" this method not being called outside Host/Client classes
  void raiseEventComingFromHost(final ActionEvent event) {
    if(!event.perform) {
      throw Exception('Host should only send events which perform');
    }
    Log.debug(() => '    (queued from host ${event.runtimeType}[${event.id}])'); // TODO: Replace with type name used for serialization
    _events.add(event);
  }
}
