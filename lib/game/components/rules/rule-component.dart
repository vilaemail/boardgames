// TODO: Parse dynamics in types.dart
// ignore_for_file: avoid_dynamic_calls

import 'package:stream_transform/stream_transform.dart';

import '../../definition/types.dart';
import '../../events/player-events.dart';
import '../../events/rule-exhausted-event.dart';
import '../component.dart';
import 'exhausted-limits-condition.dart';
import 'fill-slot-action-rule.dart';
import 'grid-slot-condition.dart';

abstract class RuleComponent with ComponentMixin<Rule> implements Component {
  int _used = 0;
  int? _limit;

  RuleComponent(final ComponentArgs<Rule> args) {
    this.args = args;
    if(args.definition.source['limit'] != null) {
      _limit = int.tryParse(args.definition.source['limit']['perTurn'].toString());
    }
    args.context.dispatcher.performingActionEvents.whereType<PlayerTurnEvent>().listen(_onPerformingPlayerTurnEvent);
    // TODO: Figure out when to unsubscribe
  }
  
  void _onPerformingPlayerTurnEvent(final PlayerTurnEvent event) {
    if(event.change == PlayerTurnChange.start && event.perform) {
      args.context.dispatcher.applyStateChange(event, () {
        _used = 0;
      });
    }
  }

  bool exhausted() => _limit != null && _used >= _limit!;

  void incrementUsage() {
    _used++;
    if(exhausted()) {
      args.context.dispatcher.raiseEvent(RuleExhaustedEvent(args.context));
    }
  }

  static RuleComponent fromDynamic(final ComponentArgs<Rule> args) {
    switch(args.definition.type) {
      case 'fill-slot-action':
        return FillSlotActionRule(args);
      case 'exhausted-limits-condition':
        return ExhaustedLimitsCondition(args);
      case 'grid-slot-condition':
        return GridSlotCondition(args);
      default:
        throw Exception('Unsupported rule type ${args.definition.type}');
    }
  }
}
