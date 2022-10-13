import 'logging.dart';

class TransformContext {
  int? currentPlayer;
  List<String> playerIds;

  TransformContext(this.currentPlayer, this.playerIds);
}

String scriptTransform(final String input, final TransformContext context) {
  final tokens = tokenize(input);
  if(tokens.length == 1 && !tokens[0].startsWith('#')) {
    return tokens[0];
  }
  var state = 'text';
  var result = '';
  for(var token in tokens) {
    switch(token) {
      case '#start#':
        if(state != 'text') {
          throw Exception('Single level of script supported');
        }
        state = 'script';
        break;
      case '#end#':
        if(state != 'script') {
          throw Exception('Single level of script supported');
        }
        state = 'text';
        break;
      default:
        if(token.contains('#')) {
          throw Exception('Unexpected token $token');
        }
        if(state == 'text') {
          result += token;
        } else {
          token = token.trim();
          if(token.startsWith('players[') && token.endsWith(']') && int.tryParse(token.substring(8, token.length - 1)) != null) {
            final playerNumber = int.parse(token.substring(8, token.length - 1));
            result += context.playerIds[playerNumber];
          } else if(token == 'player' && context.currentPlayer != null) {
            result += context.playerIds[context.currentPlayer!];
          } else {
            throw Exception('Unsupported script contents $token');
          }
        }
        break;
    }
  }
  Log.spam(() => '=>String: $input -> $tokens -> $result');
  return result;
}

List<String> tokenize(final String input) {
  final result = <String>[];
  var start=0;
  for(var i = 0; i < input.length; i++) {
    if(input[i] == '<' && i + 1 < input.length && input[i+1] == '%') {
      if(i-start > 0) {
        result.add(input.substring(start, i));
      }
      result.add('#start#');
      i+=2;
      start = i;
    } else if(input[i] == '%' && i + 1 < input.length && input[i+1] == '>') {
      if(i-start > 0) {
        result.add(input.substring(start, i));
      }
      result.add('#end#');
      i+=2;
      start = i;
    } else if(input[i] == '%' || input[i] == '#') {
      throw Exception('Reserved symbol used');
    }
  }
  
  if(input.length-start > 0) {
    result.add(input.substring(start, input.length));
  }
  return result;
}
