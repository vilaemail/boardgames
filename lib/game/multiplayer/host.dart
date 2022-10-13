import '../../util/logging.dart';
import '../events/dispatcher.dart';
import '../events/event.dart';
import 'types.dart';

class Host implements MultiplayerHandler {
  int nextId = 0;
  // TODO: History should be class of itsown and have checksums
  final List<HistoryEntry> history = []; // TODO: Purge old entries to save memory
  final HostCommunicator _communicator;
  final Dispatcher _dispatcher;
  
  Host(this._communicator, this._dispatcher) {
    _communicator.init(_onRemoteEvent);
    _dispatcher.actionEvents.listen(_onLocalActionEvent);
  }
  
  void _onRemoteEvent(final GameEvent event) {
    // TODO: Do we want to do something with incoming event beforehand, i.e. spam protection
    if(event is! ActionEvent) {
      Log.debug(() => 'Ignoring non-action event comming from client.');
      return;
    }
    if(event.perform) {
      Log.debug(() => 'Ignoring performing action event comming from client.');
      return;
    }
    // TODO: Validation if action can take place (i.e. cheaters, or race condition)
    Log.debug(() => 'Raising performing action event based on event from client.');
    final eventToPerform = event.toPerformable();
    _dispatcher.raiseEvent(eventToPerform);
  }

  void _onLocalActionEvent(final ActionEvent event) {
    if(event.perform) {
      // TODO: How should we handle futures in network communication, we need retrying mechanism...
      // ignore: discarded_futures
      _addEventToHistoryAndSendToClients(event);
      return;
    }
    // TODO: Should we do validation if action can take place here as well?
    Log.debug(() => 'Raising performing action event based on event from host.');
    final eventToPerform = event.toPerformable();
    _dispatcher.raiseEvent(eventToPerform);
  }

  Future<void> _addEventToHistoryAndSendToClients(final ActionEvent event) {
    Log.debug(() => 'History [$nextId] $event');
    final newHistoryEntry = HistoryEntry(event, nextId++);
    history.add(newHistoryEntry);
    return _communicator.send(newHistoryEntry);
  }
}
