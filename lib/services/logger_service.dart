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

  static void _log(LogLevel level, String name, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toString().split('.')[0];
    final levelStr = level.name.toUpperCase().padRight(7);
    final nameStr = '[$name]'.padRight(20);

    final logMessage = '$timestamp $levelStr $nameStr $message';

    switch (level) {
      case LogLevel.debug:
        debugPrint('🔍 $logMessage');
        break;
      case LogLevel.info:
        debugPrint('ℹ️  $logMessage');
        break;
      case LogLevel.warning:
        debugPrint('⚠️  $logMessage');
        break;
      case LogLevel.error:
        debugPrint('❌ $logMessage');
        if (error != null) {
          debugPrint('   Error: $error');
        }
        if (stackTrace != null) {
          debugPrint('   StackTrace: $stackTrace');
        }
        break;
      case LogLevel.fatal:
        debugPrint('💀 $logMessage');
        if (error != null) {
          debugPrint('   Error: $error');
        }
        if (stackTrace != null) {
          debugPrint('   StackTrace: $stackTrace');
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
