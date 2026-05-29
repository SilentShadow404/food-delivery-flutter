import 'package:logger/logger.dart';

/// Centralised logging service used across the app.
/// Wraps the `logger` package with a named singleton so every layer
/// (services, providers, screens) writes to one consistent output.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void info(String message, [dynamic extra]) =>
      _logger.i(message, error: extra);

  void warning(String message, [dynamic extra]) =>
      _logger.w(message, error: extra);

  void error(String message, [dynamic err, StackTrace? stack]) =>
      _logger.e(message, error: err, stackTrace: stack);

  void debug(String message, [dynamic extra]) =>
      _logger.d(message, error: extra);
}

/// Convenience top-level accessor so callers can write: `log.info(...)`.
final log = AppLogger.instance;
