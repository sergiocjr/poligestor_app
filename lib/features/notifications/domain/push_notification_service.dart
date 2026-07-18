import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config.dart';
import '../data/devices_repository.dart';
import '../data/push_payload.dart';
import 'notification_router.dart';
import 'notifications_controller.dart';

/// Camada de push. Sem `google-services.json` / contrato FCM, opera em modo stub:
/// - não obtém token FCM;
/// - registra apenas um install-id estável no endpoint `/devices` já existente;
/// - enfileira deep link pendente para após autenticação.
class PushNotificationService {
  PushNotificationService({
    required DevicesRepository devices,
    required AuthController auth,
    required NotificationsController notifications,
    NotificationRouter router = const NotificationRouter(),
  })  : _devices = devices,
        _auth = auth,
        _notifications = notifications,
        _router = router;

  static const _kInstallId = 'push_install_id';
  static const _kLastToken = 'push_last_device_token';

  final DevicesRepository _devices;
  final AuthController _auth;
  final NotificationsController _notifications;
  final NotificationRouter _router;

  bool _initialized = false;
  PushPayload? _pendingPayload;
  void Function(String location)? _navigate;

  bool get isInitialized => _initialized;
  bool get firebaseReady => AppConfig.pushEnabled;

  /// Deep link aguardando login/bootstrap.
  PushPayload? get pendingPayload => _pendingPayload;

  void attachNavigator(void Function(String location) navigate) {
    _navigate = navigate;
    _flushPendingNavigation();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (kDebugMode) {
      debugPrint(
        '[Push] init stub firebaseReady=$firebaseReady '
        '(aguardando contrato FASE_7 + google-services.json)',
      );
    }
  }

  Future<void> onAuthenticated() async {
    await initialize();
    await _registerDeviceToken();
    await _notifications.refresh();
    _flushPendingNavigation();
  }

  Future<void> onLogout() async {
    _pendingPayload = null;
    _notifications.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastToken);
    // Remoção remota do device depende do contrato — não inventar DELETE.
  }

  /// Entrada de payload (teste / futuro FCM onMessageOpenedApp).
  void handleIncomingPayload(
    Map<String, dynamic> data, {
    bool fromUserTap = false,
  }) {
    final payload = PushPayload.fromMap(data);
    if (kDebugMode) {
      debugPrint(
        '[Push] incoming type=${payload.type.name} '
        'protocol_id=${payload.protocolId} fromTap=$fromUserTap',
      );
    }
    // ignore: discarded_futures
    _notifications.refresh();

    if (fromUserTap) {
      enqueueNavigation(payload);
    }
  }

  void enqueueNavigation(PushPayload payload) {
    if (!_auth.isAuthenticated) {
      _pendingPayload = payload;
      return;
    }
    _navigateTo(payload);
  }

  void _flushPendingNavigation() {
    final pending = _pendingPayload;
    if (pending == null || !_auth.isAuthenticated) return;
    _pendingPayload = null;
    _navigateTo(pending);
  }

  void _navigateTo(PushPayload payload) {
    final target = _router.resolve(payload);
    if (target == null) {
      if (kDebugMode) {
        debugPrint('[Push] payload sem destino válido');
      }
      return;
    }
    final nav = _navigate;
    if (nav == null) {
      _pendingPayload = payload;
      return;
    }
    nav(target.location);
  }

  Future<void> _registerDeviceToken() async {
    if (!_auth.isAuthenticated) return;
    try {
      final token = await _resolveRegistrationToken();
      if (token == null || token.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_kLastToken);
      if (last == token) {
        // Evita POST duplicado do mesmo token.
        return;
      }

      await _devices.register(
        mode: _auth.mode,
        token: token,
      );
      await prefs.setString(_kLastToken, token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push] register device failed: $e');
      }
    }
  }

  Future<String?> _resolveRegistrationToken() async {
    // Quando Firebase estiver habilitado, obter FCM aqui.
    if (firebaseReady) {
      if (kDebugMode) {
        debugPrint('[Push] PUSH_ENABLED=true mas FCM ainda não ligado');
      }
    }
    // Fallback: install-id estável (não é token FCM; evita placeholder a cada login).
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kInstallId);
    if (id == null || id.isEmpty) {
      id = 'poligestor-install-${DateTime.now().microsecondsSinceEpoch}';
      await prefs.setString(_kInstallId, id);
    }
    return id;
  }
}
