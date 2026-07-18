import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_controller.dart';
import '../data/notifications_repository.dart';

enum NotificationFilter { all, messages, requests, notices }

/// Estado da central de avisos + badge (REST; tempo real via sync/fallback).
class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required NotificationsRepository repository,
    required AuthController auth,
  })  : _repository = repository,
        _auth = auth;

  final NotificationsRepository _repository;
  final AuthController _auth;

  List<AppNotification> _items = const [];
  NotificationFilter _filter = NotificationFilter.all;
  bool _loading = false;
  bool _loadedOnce = false;
  Object? _error;

  List<AppNotification> get items => _items;
  NotificationFilter get filter => _filter;
  bool get loading => _loading;
  bool get loadedOnce => _loadedOnce;
  Object? get error => _error;

  int get unreadCount {
    final n = _items.where((e) => e.isUnread).length;
    return n < 0 ? 0 : n;
  }

  List<AppNotification> get visibleItems {
    return _items.where((n) {
      return switch (_filter) {
        NotificationFilter.all => true,
        NotificationFilter.messages =>
          n.kind == NotificationKind.newReply ||
              n.kind == NotificationKind.infoRequest,
        NotificationFilter.requests =>
          n.kind == NotificationKind.statusChange ||
              n.kind == NotificationKind.resolved ||
              n.kind == NotificationKind.ratingAvailable,
        NotificationFilter.notices => n.kind == NotificationKind.generic,
      };
    }).toList();
  }

  void setFilter(NotificationFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!_auth.isAuthenticated) {
      _items = const [];
      _error = null;
      _loadedOnce = true;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _repository.list(mode: _auth.mode);
      _items = list;
      _error = null;
    } catch (e) {
      _error = e;
      if (kDebugMode) {
        debugPrint('[NotificationsController] refresh error=$e');
      }
    } finally {
      _loading = false;
      _loadedOnce = true;
      notifyListeners();
    }
  }

  Future<bool> markRead(dynamic id) async {
    if (!_auth.isAuthenticated) return false;
    try {
      await _repository.markRead(mode: _auth.mode, id: id);
      _items = [
        for (final n in _items)
          if (n.id == id)
            AppNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              link: n.link,
              protocolId: n.protocolId,
              protocolNumber: n.protocolNumber,
              kind: n.kind,
            )
          else
            n,
      ];
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsController] markRead error=$e');
      }
      return false;
    }
  }

  void clear() {
    _items = const [];
    _error = null;
    _loadedOnce = false;
    _filter = NotificationFilter.all;
    notifyListeners();
  }
}
