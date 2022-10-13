// TODO: Autogenerate from JSON schema
// TODO: Codegen serialization
// ignore_for_file: avoid_dynamic_calls
import '../../util/helper.dart';

class Slot {
  String? id;
  String type;
  Vector2 size;
  
  Slot(final slot) : id = slot['id']?.toString(), type = slot['type'].toString(), size = Vector2(slot['size']);

  factory Slot.fromDynamic(final slot) {
    switch(slot['type'].toString()) {
      case 'grid':
        return GridSlot(slot);
      case 'single':
        return Slot(slot);
      default:
        throw Exception("Unsupported slot type ${slot['type'].toString()}");
    }
  }
}

class Vector2 {
  double x;
  double y;

  Vector2(final vector2) : x = double.parse(vector2['x'].toString()), y = double.parse(vector2['y'].toString());
}

class GridSlot extends Slot {
  List<int> dimensions;
  Vector2 position;
  Slot slot;

  GridSlot(super.gridSlot) : dimensions = dynamicListToList(gridSlot['dimensions'], (final el) => int.parse(el.toString())), position = Vector2(gridSlot['position']), slot = Slot.fromDynamic(gridSlot['slot']);
}

class Board {
  String id;
  List<String> images;
  Vector2 size;
  List<Slot> slots;

  Board(final board) : id = board['id'].toString(), images = dynamicListToStringList(board['images']), slots = dynamicListToList(board['slots'], Slot.fromDynamic), size = Vector2(board['size']);
}

class BoardRef {
  String id;
  Vector2 position;

  BoardRef(final boardRef): id = boardRef['id'].toString(), position = Vector2(boardRef['position']);
}

class PieceState {
  String id;
  Vector2 size;

  PieceState(final e) : id = e['id'].toString(), size = Vector2(e['size']);
}

class PieceTransition {
  String from;
  String to;
  List<String> sounds;

  PieceTransition(final e) : from = e['from'].toString(), to = e['to'].toString(), sounds = dynamicListToList(e['sounds'], (final e) => e.toString());
}

class Piece {
  String id;
  String owner;
  int count;
  List<String> images;
  List<PieceState> states;
  List<PieceTransition> transitions;
  dynamic temp;

  Piece(final e) : id = e['id'].toString(), owner = e['owner'].toString(), count = int.parse(e['count'].toString()), images = dynamicListToList(e['images'], (final e) => e.toString()), states = dynamicListToList(e['states'], PieceState.new), transitions = dynamicListToList(e['transitions'], PieceTransition.new), temp = e;
}

class View {
  String id;
  Vector2 position;
  Vector2 size;
  String anchor;
  List<BoardRef> boards;

  View(final view) : id = view['id'].toString(), position = Vector2(view['position']), size = Vector2(view['size']), anchor = view['anchor'].toString(), boards = dynamicListToList(view['boards'], BoardRef.new);
}

class Stage {
  String id;

  Stage(final stage) : id = stage['id'].toString();
}

class Rule {
  String? id;
  String type;
  dynamic source;

  Rule(final rule) : id = rule['id']?.toString(), type = rule['type'].toString(), source = rule;
}

class Author {
  String name;
  String handle;
  String email;
  String website;

  Author(final author): name = author['name'].toString(), handle = author['handle'].toString(), email = author['email'].toString(), website = author['website'].toString();
}

class Metadata {
  Author author;
  String license;
  String name;
  String longDescription;
  String shortDescription;

  Metadata(final game): author = Author(game['attribution']['author']), license = game['license'].toString(), name = game['name'].toString(), longDescription = game['description']['long'].toString(), shortDescription = game['description']['short'].toString();
}

class BoardGame {
  Metadata metadata;
  String startStage;
  String startView;
  Vector2 resolution;
  List<Board> boards;
  List<View> views;
  List<Rule> rules;
  List<Stage> stages;
  List<Piece> pieces;

  BoardGame(final game): metadata = Metadata(game), startStage = game['game']['startStage'].toString(), startView = game['game']['startView'].toString(), boards = dynamicListToList(game['boards'], Board.new), views = dynamicListToList(game['views'], View.new), rules = dynamicListToList(game['rules'], Rule.new), stages = dynamicListToList(game['stages'], Stage.new), pieces = dynamicListToList(game['pieces'], Piece.new), resolution = Vector2(game['game']['resolution']);
}
