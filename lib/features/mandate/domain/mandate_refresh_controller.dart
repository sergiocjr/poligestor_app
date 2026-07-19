import 'package:flutter/foundation.dart';

/// Sinaliza às telas do mandato/inteligência que devem recarregar.
/// Bumps em rajada (realtime) são coalescidos para evitar tempestade de REST.
class MandateRefreshController extends ChangeNotifier {
  int _generation = 0;
  DateTime? _lastBumpAt;

  int get generation => _generation;

  /// Intervalo mínimo entre bumps (resume/realtime).
  static const throttle = Duration(seconds: 3);

  void bump({String reason = 'manual', bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastBumpAt != null &&
        now.difference(_lastBumpAt!) < throttle) {
      if (kDebugMode) {
        debugPrint('[MandateRefresh] bump skipped reason=$reason');
      }
      return;
    }
    _lastBumpAt = now;
    _generation++;
    if (kDebugMode) {
      debugPrint('[MandateRefresh] bump reason=$reason gen=$_generation');
    }
    notifyListeners();
  }
}
