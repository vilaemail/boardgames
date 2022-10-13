import '../util/assets.dart';
import 'components/component-collection.dart';
import 'components/component.dart';
import 'components/rules/rule-component.dart';
import 'components/ux/board-component.dart';
import 'components/ux/piece-component.dart';
import 'components/view-component.dart';
import 'players.dart';

abstract class GameState {
  abstract final Players players;
  abstract final ComponentCollection<BoardComponent> boards;
  abstract final ComponentCollection<ViewComponent> views;
  abstract final ComponentCollection<PieceComponent> pieces;
  abstract final ComponentCollection<RuleComponent> rules;
  
  // TODO: Consider moving below methods/fields to another abstraction
  ComponentId generateUniqueId();
  abstract final Assets assetsHandler;
}
