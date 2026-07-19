import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';
import '../../identity/domain/identity_deep_link.dart';
import '../data/devices_repository.dart';
import '../data/push_payload.dart';
import 'notification_router.dart';
import 'notifications_controller.dart';
import 'realtime_sync_service.dart';

/// Dispositivo FCM + deep links + orquestra Reverb (arquitetura Fase 7 intacta).
class PushNotificationService {
  PushNotificationService({
    required DevicesRepository devices,
    required AuthController auth,
    required NotificationsController notifications,
    required RealtimeSyncService realtime,
    NotificationRouter router = const NotificationRouter(),
  }) : _devices = devices,
       _auth = auth,
       _notifications = notifications,
       _realtime = realtime,
       _router = router;

  static const _kLastToken = 'push_last_device_token';
  static const _androidChannelId = 'poligestor_default';
  static const _androidChannelName = 'PoliGestor';

  final DevicesRepository _devices;
  final AuthController _auth;
  final NotificationsController _notifications;
  final RealtimeSyncService _realtime;
  final NotificationRouter _router;
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _appLinks = AppLinks();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  bool _initialized = false;
  bool _firebaseReady = false;
  AuthMode? _lastMode;
  PushPayload? _pendingPayload;
  void Function(String location)? _navigate;
  String? _lastFcmToken;

  bool get isInitialized => _initialized;
  bool get firebaseReady => _firebaseReady;
  bool get realtimeConnected => _realtime.isConnected;

  /// Token FCM mascarado (nunca expor completo em UI/logs de relatório).
  String? get maskedFcmToken {
    final t = _lastFcmToken;
    if (t == null || t.isEmpty) return null;
    return _maskToken(t);
  }

  PushPayload? get pendingPayload => _pendingPayload;

  void attachNavigator(void Function(String location) navigate) {
    _navigate = navigate;
    _flushPendingNavigation();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _bindDeepLinks();
    await _initFirebaseAndMessaging();
    if (kDebugMode) {
      debugPrint(
        '[Push] init firebaseReady=$_firebaseReady '
        'reverb=${AppConfig.reverbWsUrl}',
      );
    }
  }

  Future<void> onAuthenticated({bool soft = false}) async {
    await initialize();
    _lastMode = _auth.mode;
    // soft (resume): não força re-registro nem 2ª refresh de inbox.
    await _registerDeviceToken(force: !soft);
    if (!soft) {
      await _notifications.refresh();
    }
    await _realtime.start();
    _flushPendingNavigation();
  }

  /// Chamar **antes** de `auth.logout()` — precisa do Bearer ainda válido.
  Future<void> onLogout() async {
    final mode = _auth.isAuthenticated ? _auth.mode : _lastMode;
    final token = await _readStoredToken() ?? _lastFcmToken;

    if (mode != null) {
      try {
        await _devices.unregisterCurrent(mode: mode, token: token);
        if (kDebugMode) {
          debugPrint(
            '[Push] DELETE devices/current ok token=${_maskToken(token)}',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Push] unregister current failed: $e');
        }
      }
    }

    await _tearDownLocal(clearToken: true);
  }

  Future<void> onSessionEnded() async {
    await _tearDownLocal(clearToken: false);
  }

  Future<void> _tearDownLocal({required bool clearToken}) async {
    _pendingPayload = null;
    _notifications.clear();
    await _realtime.stop();
    if (clearToken) {
      _lastFcmToken = null;
      await _secure.delete(key: _kLastToken);
      // Limpa legado em SharedPreferences (versão pré-9.5).
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastToken);
    }
  }

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
    // Se Reverb já atualiza a inbox, evita refresh REST duplicado no push.
    if (!_realtime.isConnected) {
      // ignore: discarded_futures
      _notifications.refresh();
    }
    if (fromUserTap) {
      enqueueNavigation(payload);
    }
  }

  void handleDeepLinkUri(Uri uri) {
    if (kDebugMode) debugPrint('[Push] deep link $uri');
    // Org / tenant: navega sem exigir sessão (fluxo org-first Sprint 10.2).
    if (IdentityDeepLink.isIdentityUri(uri)) {
      final location = IdentityDeepLink.toOrgLocation(uri);
      final nav = _navigate;
      if (nav != null) {
        nav(location);
      } else {
        _pendingPayload = PushPayload(
          type: PushEventType.unknown,
          deepLink: uri.toString(),
          link: location,
        );
      }
      return;
    }
    enqueueNavigation(PushPayload.fromUri(uri));
  }

  void enqueueNavigation(PushPayload payload) {
    // Deep link de organização pode chegar antes do login.
    final deep = payload.deepLink ?? payload.link;
    if (deep != null) {
      final uri = Uri.tryParse(deep);
      if (uri != null && IdentityDeepLink.isIdentityUri(uri)) {
        final location = IdentityDeepLink.toOrgLocation(uri);
        final nav = _navigate;
        if (nav != null) {
          nav(location);
        } else {
          _pendingPayload = payload;
        }
        return;
      }
      if (deep.startsWith('/org')) {
        final nav = _navigate;
        if (nav != null) {
          nav(deep);
        } else {
          _pendingPayload = payload;
        }
        return;
      }
    }
    if (!_auth.isAuthenticated) {
      _pendingPayload = payload;
      return;
    }
    _navigateTo(payload);
  }

  void _flushPendingNavigation() {
    final pending = _pendingPayload;
    if (pending == null) return;
    final deep = pending.deepLink ?? pending.link;
    if (deep != null) {
      final uri = Uri.tryParse(deep);
      if ((uri != null && IdentityDeepLink.isIdentityUri(uri)) ||
          deep.startsWith('/org')) {
        _pendingPayload = null;
        final location = uri != null && IdentityDeepLink.isIdentityUri(uri)
            ? IdentityDeepLink.toOrgLocation(uri)
            : deep;
        _navigate?.call(location);
        return;
      }
    }
    if (!_auth.isAuthenticated) return;
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

  Future<void> _initFirebaseAndMessaging() async {
    if (kIsWeb) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await _initLocalNotifications();
      await _requestNotificationPermission();

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _onMessageSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      await _onOpenedSub?.cancel();
      _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _onMessageOpened,
      );

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _onMessageOpened(initial);
      }

      await _tokenSub?.cancel();
      _tokenSub = messaging.onTokenRefresh.listen((token) async {
        if (kDebugMode) {
          debugPrint('[Push] FCM token refresh ${_maskToken(token)}');
        }
        _lastFcmToken = token;
        if (_auth.isAuthenticated) {
          await _registerDeviceToken(force: true, tokenOverride: token);
        }
      });

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _lastFcmToken = token;
        if (kDebugMode) {
          debugPrint('[Push] FCM token obtained ${_maskToken(token)}');
        }
      }

      _firebaseReady = true;
    } catch (e) {
      _firebaseReady = false;
      if (kDebugMode) {
        debugPrint('[Push] Firebase init failed: $e');
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          if (payload.startsWith('poligestor://') ||
              payload.startsWith('http')) {
            handleDeepLinkUri(Uri.parse(payload));
            return;
          }
          handleIncomingPayload({
            'deep_link': payload,
            'type': 'protocol_message',
          }, fromUserTap: true);
        } catch (e) {
          if (kDebugMode) debugPrint('[Push] local tap parse error: $e');
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Avisos e atualizações de solicitações',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    if (!kIsWeb && Platform.isAndroid) {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    handleIncomingPayload(data, fromUserTap: false);

    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'PoliGestor';
    final body =
        message.notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        'Nova atualização';
    final deepLink = (data['deep_link'] ?? data['link'] ?? '').toString();

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Avisos e atualizações de solicitações',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF0D9488),
        ),
      ),
      payload: deepLink.isNotEmpty ? deepLink : null,
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    handleIncomingPayload(data, fromUserTap: true);
  }

  Future<void> _bindDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        handleDeepLinkUri(initial);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] initial link error: $e');
    }
    await _linkSub?.cancel();
    _linkSub = _appLinks.uriLinkStream.listen(
      handleDeepLinkUri,
      onError: (Object e) {
        if (kDebugMode) debugPrint('[Push] link stream error: $e');
      },
    );
  }

  Future<void> _registerDeviceToken({
    bool force = false,
    String? tokenOverride,
  }) async {
    if (!_auth.isAuthenticated) return;
    try {
      final token = tokenOverride ?? await _resolveFcmToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[Push] sem token FCM — registro omitido (sem install-id)',
          );
        }
        return;
      }

      final last = await _readStoredToken();
      if (!force && last == token) return;

      await _devices.register(mode: _auth.mode, token: token);
      _lastFcmToken = token;
      await _secure.write(key: _kLastToken, value: token);
      // Remove cópia legada em claro.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastToken);
      if (kDebugMode) {
        debugPrint(
          '[Push] device registered platform=android token=${_maskToken(token)}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Push] register device failed: $e');
      }
    }
  }

  Future<String?> _readStoredToken() async {
    final secure = await _secure.read(key: _kLastToken);
    if (secure != null && secure.isNotEmpty) return secure;
    // Migração one-shot do prefs legado.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_kLastToken);
    if (legacy != null && legacy.isNotEmpty) {
      await _secure.write(key: _kLastToken, value: legacy);
      await prefs.remove(_kLastToken);
      return legacy;
    }
    return null;
  }

  /// Somente token FCM real — sem substituto local.
  Future<String?> _resolveFcmToken() async {
    if (!_firebaseReady) {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        _firebaseReady = true;
      } catch (_) {
        return null;
      }
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      _lastFcmToken = token;
    }
    return token;
  }

  static String _maskToken(String? token) {
    if (token == null || token.isEmpty) return '(vazio)';
    if (token.length < 12) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }

  Future<void> dispose() async {
    await _linkSub?.cancel();
    await _tokenSub?.cancel();
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _realtime.stop();
  }
}
