import 'package:stream_transform/stream_transform.dart';

import '../../../util/helper.dart';
import '../../events/event.dart';
import '../../events/player-events.dart';
import '../../events/rule-exhausted-event.dart';
import 'rule-component.dart';

class ExhaustedLimitsCondition extends RuleComponent {
  bool _executedInThisTurn = false;

  ExhaustedLimitsCondition(super.args) {
    args.context.dispatcher.performingActionEvents.listen(_onPerformingActionEvent);
    args.context.dispatcher.stateChangeEvents.whereType<RuleExhaustedEvent>().listen(_onRuleExhaustedEvent);
  }

  void _onPerformingActionEvent(final ActionEvent event) {
    // TODO: This is something system rule should handle, in this rule we should just say we are completing the turn (code after this if)
    if(event is PlayerTurnEvent) {
      if(event.change == PlayerTurnChange.finish) {
        args.context.dispatcher.applyStateChange(event, () {
          args.context.state.players.moveToNextPlayer();
          _executedInThisTurn = false;
          args.context.dispatcher.raiseEvent(PlayerTurnEvent(args.context, PlayerTurnChange.start, perform: true));
        });
      }
      return;
    }
    
  }

  void _onRuleExhaustedEvent(final RuleExhaustedEvent _) {
    // TODO: Also stop doing this when game is over
    if(_executedInThisTurn) {
      return;
    }
    // TODO: Parse once in constructor
    // ignore: avoid_dynamic_calls
    final rules = dynamicListToList(args.definition.source['rules'], (final e) => e.toString());
    final rulesWhichNeedToBeExhausted = args.context.state.rules.where((final element) => rules.contains(element.id)); // TODO: Cache this
    if(!rulesWhichNeedToBeExhausted.every((final element) => element.exhausted())) {
      return;
    }
    _executedInThisTurn = true;
    args.context.dispatcher.raiseEvent(PlayerTurnEvent(args.context, PlayerTurnChange.finish, perform: true)); // TODO: Read action from JSON to determine what to do
  }
}
