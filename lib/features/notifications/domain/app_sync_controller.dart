import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/auth/auth_controller.dart';
import 'notifications_controller.dart';
import 'push_notification_service.dart';

/// Sincronização ao retomar o app (REST + rearme do Reverb).
class AppSyncController with WidgetsBindingObserver {
  AppSyncController({
    required AuthController auth,
    required NotificationsController notifications,
    required PushNotificationService push,
  })  : _auth = auth,
        _notifications = notifications,
        _push = push;

  final AuthController _auth;
  final NotificationsController _notifications;
  final PushNotificationService _push;

  bool _listening = false;
  DateTime? _lastSyncAt;

  void start() {
    if (_listening) return;
    WidgetsBinding.instance.addObserver(this);
    _listening = true;
  }

  void stop() {
    if (!_listening) return;
    WidgetsBinding.instance.removeObserver(this);
    _listening = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ignore: discarded_futures
      sync(reason: 'resume');
    }
  }

  Future<void> sync({String reason = 'manual'}) async {
    if (!_auth.isAuthenticated) return;
    final now = DateTime.now();
    if (_lastSyncAt != null &&
        now.difference(_lastSyncAt!) < const Duration(seconds: 4)) {
      return;
    }
    _lastSyncAt = now;
    if (kDebugMode) {
      debugPrint('[AppSync] sync reason=$reason');
    }
    await _notifications.refresh();
    await _push.onAuthenticated();
  }
}
