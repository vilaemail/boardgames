import 'event.dart';

class GameOverEvent extends ActionEvent {
  GameOverEvent(super.context, {required super.perform});

  @override
  GameOverEvent toPerformable() {
    if(perform == true) {
      throw Exception('already performable');
    }
    return GameOverEvent(context, perform: true);
  }
}
