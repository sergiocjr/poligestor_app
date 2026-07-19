import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_controller.dart';
import '../data/notifications_repository.dart';

enum NotificationFilter { all, unread, messages, requests, notices }

/// Estado da central de avisos + badge (REST; tempo real via Reverb + fallback).
class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required NotificationsRepository repository,
    required AuthController auth,
  }) : _repository = repository,
       _auth = auth;

  final NotificationsRepository _repository;
  final AuthController _auth;

  List<AppNotification> _items = const [];
  NotificationFilter _filter = NotificationFilter.all;
  bool _loading = false;
  bool _loadingMore = false;
  bool _loadedOnce = false;
  Object? _error;
  int _unreadCount = 0;
  int _page = 1;
  int _lastPage = 1;
  Future<void>? _refreshInFlight;

  List<AppNotification> get items => _items;
  NotificationFilter get filter => _filter;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get loadedOnce => _loadedOnce;
  Object? get error => _error;
  bool get hasMore => _page < _lastPage;

  int get unreadCount => _unreadCount < 0 ? 0 : _unreadCount;

  /// Itens já filtrados pelo servidor (`filter` query).
  List<AppNotification> get visibleItems => _items;

  String get _apiFilter => switch (_filter) {
    NotificationFilter.all => 'all',
    NotificationFilter.unread => 'unread',
    NotificationFilter.messages => 'messages',
    NotificationFilter.requests => 'requests',
    NotificationFilter.notices => 'system',
  };

  Future<void> setFilter(NotificationFilter value) async {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
    await refresh();
  }

  /// Coalescido: chamadas concorrentes compartilham a mesma Future.
  Future<void> refresh() {
    if (_refreshInFlight != null) return _refreshInFlight!;
    _refreshInFlight = _refreshBody().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<void> _refreshBody() async {
    if (!_auth.isAuthenticated) {
      _items = const [];
      _unreadCount = 0;
      _error = null;
      _loadedOnce = true;
      _page = 1;
      _lastPage = 1;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repository.list(
        mode: _auth.mode,
        filter: _apiFilter,
        unreadOnly: _filter == NotificationFilter.unread ? true : null,
        page: 1,
        perPage: 20,
      );
      _items = page.items;
      _page = page.currentPage;
      _lastPage = page.lastPage;
      try {
        _unreadCount = await _repository.unreadCount(mode: _auth.mode);
      } catch (_) {
        _unreadCount = _items.where((e) => e.isUnread).length;
      }
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

  Future<void> loadMore() async {
    if (!_auth.isAuthenticated || _loadingMore || !hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final next = _page + 1;
      final page = await _repository.list(
        mode: _auth.mode,
        filter: _apiFilter,
        unreadOnly: _filter == NotificationFilter.unread ? true : null,
        page: next,
        perPage: 20,
      );
      final existingIds = _items.map((e) => e.id).toSet();
      _items = [
        ..._items,
        ...page.items.where((e) => !existingIds.contains(e.id)),
      ];
      _page = page.currentPage;
      _lastPage = page.lastPage;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsController] loadMore error=$e');
      }
    } finally {
      _loadingMore = false;
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
      if (_unreadCount > 0) _unreadCount -= 1;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsController] markRead error=$e');
      }
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (!_auth.isAuthenticated) return false;
    try {
      await _repository.markAllRead(mode: _auth.mode);
      _items = [
        for (final n in _items)
          AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            readAt: n.readAt ?? DateTime.now(),
            createdAt: n.createdAt,
            link: n.link,
            protocolId: n.protocolId,
            protocolNumber: n.protocolNumber,
            kind: n.kind,
          ),
      ];
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationsController] markAllRead error=$e');
      }
      return false;
    }
  }

  void clear() {
    _items = const [];
    _error = null;
    _loadedOnce = false;
    _filter = NotificationFilter.all;
    _unreadCount = 0;
    _page = 1;
    _lastPage = 1;
    notifyListeners();
  }
}
