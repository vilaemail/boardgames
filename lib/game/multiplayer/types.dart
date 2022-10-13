import '../events/event.dart';

class HistoryEntry {
  final ActionEvent event;
  final int id;

  HistoryEntry(this.event, this.id);
}

abstract class MultiplayerHandler {
  
}

abstract class HostCommunicator {
  Future<void> send(final HistoryEntry entry);
  void init(final Function(ActionEvent event) processor); // TODO: Replace with Stream
}

abstract class ClientCommunicator {
  Future<void> send(final ActionEvent entry);
  void init(final Function(HistoryEntry event) processor); // TODO: Replace with Stream
}
