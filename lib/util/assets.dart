import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/services.dart';

class Assets {
  final String gameId;
  final List<String> _music = ['music/cave_theme_1.mp3', 'music/cave_theme_2.mp3', 'music/sea_theme_1.mp3', 'music/sea_theme_2.mp3'];
  final Random _random = Random();
  final Bgm _bgm = Bgm();

  Assets(this.gameId);

  static Future<dynamic> loadGame(final String name) async {
    final jsonContent = await rootBundle.loadString('assets/games/$name/game.json');
    final Map<String, dynamic> game = jsonDecode(jsonContent);
    return game;
  }

  Future<void> playAudio(final List<String> audioNames) => FlameAudio.play('games/$gameId/sfx/${_chooseAtRandom(audioNames)}');

  Future<void> playMusic() => _bgm.play(_chooseAtRandom(_music));

  Future<void> stopMusic() => _bgm.stop();

  // TODO: Unify how we load assets and preload them before starting game
  Future<PositionComponent> loadImageToComponent(final List<String> imageNames) async {
    final imageName = _chooseAtRandom(imageNames);
    if(imageName.endsWith('.svg')) {
      final svg = await Svg.load('games/$gameId/gfx/$imageName');
      return SvgComponent(svg: svg);
    } else {
      final sprite = await Sprite.load('games/$gameId/gfx/$imageName');
      return SpriteComponent(sprite: sprite);
    }
  }

  T _chooseAtRandom<T>(final List<T> items) => items[_random.nextInt(items.length)];
}
