import 'package:flutter/foundation.dart';

/// Sinaliza às telas do mandato que devem recarregar (resume / realtime).
class MandateRefreshController extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void bump({String reason = 'manual'}) {
    _generation++;
    if (kDebugMode) {
      debugPrint('[MandateRefresh] bump reason=$reason gen=$_generation');
    }
    notifyListeners();
  }
}
