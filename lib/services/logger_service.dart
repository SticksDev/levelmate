import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggerService {
  final String name;

  LoggerService(this.name);

  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  static void _log(LogLevel level, String name, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final levelStr = level.name.toUpperCase().padRight(5);

    String coloredLevel;
    String coloredName;

    switch (level) {
      case LogLevel.debug:
        coloredLevel = '$_gray$levelStr$_reset';
        coloredName = '$_gray[$name]$_reset';
        debugPrint('$_gray$timestamp$_reset $coloredLevel $coloredName $_gray$message$_reset');
        break;
      case LogLevel.info:
        coloredLevel = '$_cyan$levelStr$_reset';
        coloredName = '$_blue[$name]$_reset';
        debugPrint('$_gray$timestamp$_reset $coloredLevel $coloredName $message');
        break;
      case LogLevel.warning:
        coloredLevel = '$_yellow$levelStr$_reset';
        coloredName = '$_yellow[$name]$_reset';
        debugPrint('$_gray$timestamp$_reset $coloredLevel $coloredName $_yellow$message$_reset');
        break;
      case LogLevel.error:
        coloredLevel = '$_red$levelStr$_reset';
        coloredName = '$_red[$name]$_reset';
        debugPrint('$_gray$timestamp$_reset $coloredLevel $coloredName $_red$message$_reset');
        if (error != null) {
          debugPrint('  $_red└─ Error: $error$_reset');
        }
        if (stackTrace != null) {
          debugPrint('  $_gray└─ Stack: $stackTrace$_reset');
        }
        break;
      case LogLevel.fatal:
        coloredLevel = '$_magenta$levelStr$_reset';
        coloredName = '$_magenta[$name]$_reset';
        debugPrint('$_gray$timestamp$_reset $coloredLevel $coloredName $_magenta$message$_reset');
        if (error != null) {
          debugPrint('  $_magenta└─ Error: $error$_reset');
        }
        if (stackTrace != null) {
          debugPrint('  $_gray└─ Stack: $stackTrace$_reset');
        }
        break;
    }
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, name, message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, name, message, error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, name, message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, name, message, error, stackTrace);
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, name, message, error, stackTrace);
  }
}
