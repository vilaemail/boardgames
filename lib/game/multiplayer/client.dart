import '../../util/logging.dart';
import '../events/dispatcher.dart';
import '../events/event.dart';
import 'types.dart' ;

class Client implements MultiplayerHandler {
  final List<HistoryEntry> history = [];
  final ClientCommunicator _communicator;
  final Dispatcher _dispatcher;

  Client(this._communicator, this._dispatcher) {
    _dispatcher.nonPerformingActionEvents.listen(_onLocalNonPerformingActionEvent);
    _communicator.init(_incomingHistoryEntryFromHost);
  }

  void _onLocalNonPerformingActionEvent(final ActionEvent event) {
    // TODO: Validation if action can take place (i.e. cheaters, or race condition)
    // TODO: How should we handle futures in network communication, we need retrying mechanism...
    // ignore: discarded_futures
    _communicator.send(event);
  }

  void _incomingHistoryEntryFromHost(final HistoryEntry entry) {
    // TODO: Do we want to do something with incoming entry beforehand, i.e. spam protection
    // TODO: check if we are missing some id and have retry mechanisms for recovering
    history.add(entry);
    Log.debug(() => 'History [${entry.id}] ${entry.event}');
    _dispatcher.raiseEventComingFromHost(entry.event);
  }
}
