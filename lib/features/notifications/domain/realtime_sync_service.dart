import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_mode.dart';
import '../../../core/config.dart';
import '../../../core/realtime/pusher_reverb_client.dart';
import '../../mandate/domain/mandate_refresh_controller.dart';
import 'notifications_controller.dart';

/// Conecta Reverb, autentica canais privados e propaga `protocol.realtime`.
class RealtimeSyncService {
  RealtimeSyncService({
    required ApiClient api,
    required AuthController auth,
    required NotificationsController notifications,
    MandateRefreshController? mandateRefresh,
  })  : _api = api,
        _auth = auth,
        _notifications = notifications,
        _mandateRefresh = mandateRefresh;

  final ApiClient _api;
  final AuthController _auth;
  final NotificationsController _notifications;
  final MandateRefreshController? _mandateRefresh;

  PusherReverbClient? _client;
  StreamSubscription<ProtocolRealtimeEvent>? _eventsSub;
  StreamSubscription<bool>? _connSub;
  final _protocolWatchers =
      <String, void Function(ProtocolRealtimeEvent event)>{};

  bool _started = false;
  bool get isConnected => _client?.isConnected ?? false;

  Future<void> start() async {
    if (!_auth.isAuthenticated) return;
    if (_started && _client != null) {
      await _ensureUserChannel();
      return;
    }
    _started = true;

    _client = PusherReverbClient(
      authorize: _authorizeChannel,
    );
    _eventsSub = _client!.events.listen(_onRealtimeEvent);
    _connSub = _client!.connectionStates.listen((connected) {
      if (kDebugMode) {
        debugPrint('[Realtime] connected=$connected');
      }
      if (!connected) {
        // Fallback REST: refresh inbox quando o WSS cai.
        // ignore: discarded_futures
        _notifications.refresh();
      }
    });
    await _client!.connect();
    await _ensureUserChannel();
  }

  Future<void> stop() async {
    _started = false;
    _protocolWatchers.clear();
    await _eventsSub?.cancel();
    await _connSub?.cancel();
    _eventsSub = null;
    _connSub = null;
    await _client?.dispose();
    _client = null;
  }

  Future<void> watchProtocol(
    String protocolId, {
    void Function(ProtocolRealtimeEvent event)? onEvent,
  }) async {
    final id = protocolId.trim();
    if (id.isEmpty) return;
    if (onEvent != null) _protocolWatchers[id] = onEvent;
    final client = _client;
    if (client == null) return;
    await client.subscribe('private-protocol.$id');
  }

  Future<void> unwatchProtocol(String protocolId) async {
    final id = protocolId.trim();
    _protocolWatchers.remove(id);
    await _client?.unsubscribe('private-protocol.$id');
  }

  Future<void> _ensureUserChannel() async {
    final user = _auth.session?.user;
    final client = _client;
    if (user == null || client == null) return;
    final channel = _auth.mode.privateUserChannel(user.id);
    await client.subscribe(channel);
  }

  Future<String> _authorizeChannel(String socketId, String channelName) async {
    final body = await _api.postRawMap(
      AppConfig.broadcastingAuthUrl,
      data: {
        'socket_id': socketId,
        'channel_name': channelName,
      },
      mode: _auth.mode,
      tenantSlug: _auth.session?.tenantSlug,
    );
    final auth = body['auth']?.toString();
    if (auth == null || auth.isEmpty) {
      throw StateError('broadcasting auth sem campo auth');
    }
    return auth;
  }

  void _onRealtimeEvent(ProtocolRealtimeEvent event) {
    if (kDebugMode) {
      debugPrint(
        '[Realtime] protocol.realtime type=${event.type} '
        'protocol_id=${event.protocolId}',
      );
    }
    // ignore: discarded_futures
    _notifications.refresh();
    if (_auth.mode == AuthMode.staff) {
      _mandateRefresh?.bump(reason: 'realtime');
    }
    final watcher = _protocolWatchers[event.protocolId];
    watcher?.call(event);
  }
}
