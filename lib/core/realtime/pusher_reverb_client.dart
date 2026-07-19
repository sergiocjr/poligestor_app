import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';

typedef ChannelAuthorizer = Future<String> Function(
  String socketId,
  String channelName,
);

class ProtocolRealtimeEvent {
  const ProtocolRealtimeEvent({
    required this.type,
    required this.protocolId,
    this.tenantId,
    this.occurredAt,
    this.data = const {},
    this.raw = const {},
  });

  final String type;
  final String protocolId;
  final String? tenantId;
  final DateTime? occurredAt;
  final Map<String, dynamic> data;
  final Map<String, dynamic> raw;

  factory ProtocolRealtimeEvent.fromPayload(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final type = (json['type'] ?? data['type'] ?? '').toString();
    final protocolId =
        (json['protocol_id'] ?? data['protocol_id'] ?? '').toString();
    final occurredRaw = json['occurred_at']?.toString();
    return ProtocolRealtimeEvent(
      type: type,
      protocolId: protocolId,
      tenantId: json['tenant_id']?.toString(),
      occurredAt:
          occurredRaw != null ? DateTime.tryParse(occurredRaw) : null,
      data: data,
      raw: json,
    );
  }
}

/// Cliente Pusher-compatible para Laravel Reverb (WSS + auth privado).
class PusherReverbClient {
  PusherReverbClient({
    required this.authorize,
    this.host = AppConfig.publicHost,
    this.appKey = AppConfig.reverbAppKey,
    this.port = AppConfig.reverbPort,
    this.useTls = AppConfig.reverbTls,
  });

  final ChannelAuthorizer authorize;
  final String host;
  final String appKey;
  final int port;
  final bool useTls;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Timer? _activityTimer;

  String? _socketId;
  bool _connecting = false;
  bool _disposed = false;
  bool _manualDisconnect = false;
  int _reconnectAttempt = 0;
  int _activityTimeoutSec = 120;

  final Set<String> _desiredChannels = {};
  final Set<String> _subscribedChannels = {};

  final _events = StreamController<ProtocolRealtimeEvent>.broadcast();
  final _connectionStates = StreamController<bool>.broadcast();

  Stream<ProtocolRealtimeEvent> get events => _events.stream;
  Stream<bool> get connectionStates => _connectionStates.stream;
  bool get isConnected => _socketId != null && _channel != null;
  String? get socketId => _socketId;

  Future<void> connect() async {
    if (_disposed) return;
    _manualDisconnect = false;
    if (_connecting || isConnected) return;
    _connecting = true;
    try {
      final uri = Uri(
        scheme: useTls ? 'wss' : 'ws',
        host: host,
        port: (useTls && port == 443) || (!useTls && port == 80) ? null : port,
        path: '/app/$appKey',
        queryParameters: const {
          'protocol': '7',
          'client': 'js',
          'version': '8.4.0',
          'flash': 'false',
        },
      );
      if (kDebugMode) {
        debugPrint('[Reverb] connect $uri');
      }
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      _sub = channel.stream.listen(
        _onMessage,
        onError: (Object e, StackTrace st) {
          if (kDebugMode) debugPrint('[Reverb] stream error: $e');
          _handleDisconnect();
        },
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
      _reconnectAttempt = 0;
    } catch (e) {
      if (kDebugMode) debugPrint('[Reverb] connect failed: $e');
      _connecting = false;
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _activityTimer?.cancel();
    _desiredChannels.clear();
    _subscribedChannels.clear();
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _socketId = null;
    _connectionStates.add(false);
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _events.close();
    await _connectionStates.close();
  }

  Future<void> subscribe(String channelName) async {
    _desiredChannels.add(channelName);
    await _ensureSubscribed(channelName);
  }

  Future<void> unsubscribe(String channelName) async {
    _desiredChannels.remove(channelName);
    if (!_subscribedChannels.contains(channelName)) return;
    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    });
    _subscribedChannels.remove(channelName);
  }

  void _onMessage(dynamic raw) {
    try {
      final text = raw is String ? raw : raw.toString();
      final msg = jsonDecode(text);
      if (msg is! Map) return;
      final map = Map<String, dynamic>.from(msg);
      final event = map['event']?.toString() ?? '';
      final dataRaw = map['data'];
      final channel = map['channel']?.toString();

      if (event == 'pusher:connection_established') {
        final data = _decodeData(dataRaw);
        _socketId = data['socket_id']?.toString();
        final timeout = data['activity_timeout'];
        if (timeout is num) _activityTimeoutSec = timeout.toInt();
        _connectionStates.add(true);
        _armActivityTimer();
        if (kDebugMode) {
          debugPrint('[Reverb] connected socket_id=$_socketId');
        }
        // ignore: discarded_futures
        _resubscribeAll();
        return;
      }

      if (event == 'pusher:ping') {
        _send({'event': 'pusher:pong', 'data': {}});
        _armActivityTimer();
        return;
      }

      if (event == 'pusher:error') {
        if (kDebugMode) debugPrint('[Reverb] pusher:error data=$dataRaw');
        return;
      }

      if (event == 'pusher_internal:subscription_succeeded' ||
          event == 'pusher:subscription_succeeded') {
        if (channel != null) _subscribedChannels.add(channel);
        return;
      }

      final isRealtime = event == 'protocol.realtime' ||
          event == '.protocol.realtime' ||
          event.endsWith('protocol.realtime');
      if (!isRealtime) return;

      final payload = _decodeData(dataRaw);
      if (payload.isEmpty) return;
      final parsed = ProtocolRealtimeEvent.fromPayload(payload);
      if (parsed.protocolId.isEmpty && channel != null) {
        // Fallback: private-protocol.{id}
        final prefix = 'private-protocol.';
        if (channel.startsWith(prefix)) {
          _events.add(
            ProtocolRealtimeEvent(
              type: parsed.type,
              protocolId: channel.substring(prefix.length),
              tenantId: parsed.tenantId,
              occurredAt: parsed.occurredAt,
              data: parsed.data,
              raw: parsed.raw,
            ),
          );
          return;
        }
      }
      _events.add(parsed);
    } catch (e) {
      if (kDebugMode) debugPrint('[Reverb] parse error: $e');
    }
  }

  Future<void> _resubscribeAll() async {
    _subscribedChannels.clear();
    for (final name in _desiredChannels.toList()) {
      await _ensureSubscribed(name);
    }
  }

  Future<void> _ensureSubscribed(String channelName) async {
    final socketId = _socketId;
    final channel = _channel;
    if (socketId == null || channel == null) return;
    if (_subscribedChannels.contains(channelName)) return;
    try {
      final auth = await authorize(socketId, channelName);
      _send({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
          'auth': auth,
        },
      });
      _subscribedChannels.add(channelName);
      if (kDebugMode) {
        debugPrint('[Reverb] subscribed $channelName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Reverb] subscribe failed $channelName: $e');
      }
    }
  }

  void _send(Map<String, dynamic> message) {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      if (kDebugMode) debugPrint('[Reverb] send failed: $e');
    }
  }

  void _armActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = Timer(
      Duration(seconds: _activityTimeoutSec + 5),
      () {
        if (kDebugMode) debugPrint('[Reverb] activity timeout');
        _handleDisconnect();
      },
    );
  }

  void _handleDisconnect() {
    final wasConnected = _socketId != null;
    _activityTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _socketId = null;
    _subscribedChannels.clear();
    if (wasConnected) _connectionStates.add(false);
    if (!_manualDisconnect && !_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delaySec = (2 << _reconnectAttempt.clamp(0, 4)).clamp(2, 32);
    _reconnectAttempt++;
    if (kDebugMode) {
      debugPrint('[Reverb] reconnect in ${delaySec}s');
    }
    _reconnectTimer = Timer(Duration(seconds: delaySec), () {
      // ignore: discarded_futures
      connect();
    });
  }

  Map<String, dynamic> _decodeData(dynamic dataRaw) {
    if (dataRaw is Map) return Map<String, dynamic>.from(dataRaw);
    if (dataRaw is String && dataRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(dataRaw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}
