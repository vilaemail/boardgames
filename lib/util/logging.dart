import 'dart:core';

abstract class Metric {
  final String name;
  final Map<String, String> _dimensions;

  Metric(this.name, [final Map<String, String>? dimensions]): _dimensions = dimensions ?? {};

  void setDimension(final String key, final String value) {
    _dimensions[key] = value;
  }

  void setDimensions(final Map<String, String> kvps) {
    _dimensions.addAll(kvps);
  }
}

class EventMetric extends Metric {
  Stopwatch? _stopwatch;
  bool success = true;
  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  EventMetric(super.name, [super.dimensions]);

  void start() {
    _stopwatch = _stopwatch ?? Stopwatch();
    _stopwatch!.start();
  }

  void stop({final bool? success}) {
    final stopwatch = _stopwatch!
      ..stop();
    _duration += stopwatch.elapsed;
    stopwatch.reset();

    this.success = success ?? this.success;
  }
}

class GaugeMetric extends Metric {
  final num _value;
  num get value => _value;

  GaugeMetric(super.name, this._value, [super.dimensions]);
}

// This is a project level choice how to do logging
// ignore: avoid_classes_with_only_static_members
class Log {
  static late final List<Logger> _loggers;
  static Future<void> init(final List<Logger> loggers) {
    _loggers = loggers;
    return Future.wait(_loggers.map((final logger) => logger.init()));
  }
  static Future<void> close() => Future.wait(_loggers.map((final logger) => logger.close()));

  static void metric(final Metric metric) {
    for(final logger in _loggers) {
      logger.logMetric(metric);
    }
  }

  static void spam(final String Function() messageFactory) {
    _logMessageFactory(LogLevel.spam, messageFactory);
  }
  static void debug(final String Function() messageFactory) {
    _logMessageFactory(LogLevel.debug, messageFactory);
  }
  static void info(final String Function() messageFactory) {
    _logMessageFactory(LogLevel.info, messageFactory);
  }
  static void warn(final String message) {
    _logMessage(LogLevel.warn, message);
  }
  static void error(final String message) {
    _logMessage(LogLevel.error, message);
  }

  static void _logMessage(final LogLevel level, final String message) {
    for(final logger in _loggers) {
      logger.logMessage(level, message);
    }
  }

  static void _logMessageFactory(final LogLevel level, final String Function() messageFactory) {
    String? message;
    for(final logger in _loggers) {
      if(logger.wouldLog(level)) {
        message = message ?? messageFactory();
        logger.logMessage(level, message);
      }
    }
  }
}

enum LogLevel {
  spam,
  debug,
  info,
  metric,
  warn,
  error
}

abstract class Logger {
  Future<void> init();
  bool wouldLog(final LogLevel level);
  void logMessage(final LogLevel level, final String message);
  void logMetric(final Metric metric);
  Future<void> flush();
  Future<void> close();
}

class ConsoleLogger implements Logger {
  final LogLevel _logLevel;

  ConsoleLogger(this._logLevel);
  
  @override
  Future<void> init() async{}

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}

  @override
  bool wouldLog(final LogLevel level) => level.index >= _logLevel.index;

  @override
  void logMessage(final LogLevel level, final String message) {
    if(!wouldLog(level)) {
      return;
    }
    if(level == LogLevel.metric) {
      return;
    }
    final now = DateTime.now().toUtc().toIso8601String();
    _printToConsole(level, '[$now] [${level.name}] $message');
  }

  @override
  void logMetric(final Metric metric) {
    final now = DateTime.now().toUtc().toIso8601String();
    if(metric is EventMetric) {
      final toPrint = '[$now] [metric] [${metric.success}] [${_eventMetricDurationToHumanReadable(metric)}] ${metric.name}';
      _printToConsole(metric.success ? LogLevel.metric : LogLevel.warn, toPrint);
    } else if (metric is GaugeMetric) {
      final toPrint = '[$now] [metric] [${metric.value}] ${metric.name}';
      _printToConsole(LogLevel.metric, toPrint);
    } else {
      return;
    }
  }

  String _padInt(final int value, final int pads) => value.toString().padLeft(pads, '0');

  String _eventMetricDurationToHumanReadable(final EventMetric metric) {
    final ms = metric.duration.inMilliseconds;
    final seconds = ms ~/ 1000;
    if(seconds == 0) {
      if(ms < 10) {
        final us = metric.duration.inMicroseconds;
        return '0.${_padInt(us, 6)}';
      } else {
        return '0.${_padInt(ms, 3)}';
      }
    } else if(seconds < 60) {
      return '${_padInt(seconds, 2)}.${_padInt(ms, 3)}';
    }
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    if(hours < 24) {
      return '${_padInt(hours, 2)}:${_padInt(minutes, 2)}:${_padInt(seconds, 2)}';
    } else {
      final days = hours ~/ 24;
      return '$days.${_padInt(hours, 2)}:${_padInt(minutes, 2)}';
    }
  }

  void _printToConsole(final LogLevel level, final String text) {
    // We will be ignoring linter avoid_print rule in this method, as this class is used for debugging (logging to console)
    if(level.index >= LogLevel.error.index) {
      // ignore: avoid_print
      print('\x1B[31m$text\x1B[0m'); // red
    } else if(level.index >= LogLevel.warn.index) {
      // ignore: avoid_print
      print('\x1B[33m$text\x1B[0m'); // yellow
    } else if(level.index >= LogLevel.info.index) {
      // ignore: avoid_print
      print(text); // default
    } else {
      // ignore: avoid_print
      print('\x1B[34m$text\x1B[0m'); // cyan
    }
  }
}
