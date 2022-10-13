import 'package:audioplayers/audioplayers.dart' show AudioCache;
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/definition/types.dart' as game_definition;
import 'menu/app.dart';
import 'network/network.dart';
import 'util/assets.dart';
import 'util/logging.dart';

List<String> gameIds = ['tic-tac-toe', 'connect-four'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Log.init([ConsoleLogger(LogLevel.debug)]);
  FlameAudio.audioCache = AudioCache();
  Flame.images = Images(prefix: 'assets/');
  final gamesFutures = gameIds.map(Assets.loadGame);
  await Flame.device.fullScreen();
  await Flame.device.setOrientation(DeviceOrientation.portraitUp);
  final games = (await Future.wait(gamesFutures)).map(game_definition.BoardGame.new).toList();
  final network = Network();
  runApp(App(games, network));
}
