import 'dart:io' show Platform; // TODO: This library does not exist for web, better organize code to avoid exceptions

import 'package:flutter/foundation.dart';

class Environment {
  late final String loopbackAddress = _computeLoopback();
  late final bool isDebug = _computeIsDebug();
  late final bool isProfile = _computeIsProfile();
  late final bool isRelease = _computeIsRelease();

  Environment._();

  static final Environment instance = Environment._();

  bool _computeIsDebug() => kDebugMode;

  bool _computeIsProfile() => kProfileMode;

  bool _computeIsRelease() => kReleaseMode;

  // TODO: This won't work if we run on non-emulator, figure out how to query if we are on emulator
  String _computeLoopback() {
    if(!isDebug) {
      return '127.0.0.1';
    }
    if(kIsWeb) {
      return '127.0.0.1';
    }
    if(Platform.isAndroid) {
      return '10.0.2.2';
    }
    return '127.0.0.1';
  }
}
