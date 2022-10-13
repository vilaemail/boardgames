import '../events/event.dart';
import 'types.dart';

class NullCommunicator implements HostCommunicator {
  @override
  void init(final Function(ActionEvent event) processor) {
  }

  @override
  Future<void> send(final HistoryEntry entry) async {}
}
