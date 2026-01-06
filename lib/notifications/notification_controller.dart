import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_notification.dart';
import 'notification_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before use.',
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationState {
  const NotificationState({
    required this.items,
    required this.unreadCount,
    required this.badgeType,
    required this.isSyncing,
    required this.lastSyncFailed,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final NotificationBadgeType badgeType;
  final bool isSyncing;
  final bool lastSyncFailed;

  NotificationState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    NotificationBadgeType? badgeType,
    bool? isSyncing,
    bool? lastSyncFailed,
  }) {
    return NotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      badgeType: badgeType ?? this.badgeType,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncFailed: lastSyncFailed ?? this.lastSyncFailed,
    );
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );

class NotificationController extends Notifier<NotificationState> {
  static const _prefsKeyUnread = 'notifications_unread_count';
  int _syncToken = 0;

  @override
  NotificationState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final unread = prefs.getInt(_prefsKeyUnread) ?? 0;

    Future<void>.microtask(sync);

    return NotificationState(
      items: const <AppNotification>[],
      unreadCount: unread,
      badgeType: NotificationBadgeType.auto,
      isSyncing: false,
      lastSyncFailed: false,
    );
  }

  Future<void> sync() async {
    final token = ++_syncToken;
    final repo = ref.read(notificationRepositoryProvider);
    state = state.copyWith(isSyncing: true, lastSyncFailed: false);

    try {
      final results = await Future.wait<Object>([
        repo.fetchNotifications(),
        repo.fetchUnreadCount(),
      ]);

      if (token != _syncToken) return;

      final items = (results[0] as List<AppNotification>);
      final unread = results[1] as int;

      state = state.copyWith(
        items: items,
        unreadCount: unread,
        isSyncing: false,
      );
      await _persistUnread(unread);
    } catch (_) {
      if (token != _syncToken) return;
      state = state.copyWith(isSyncing: false, lastSyncFailed: true);
    }
  }

  Future<void> setBadgeType(NotificationBadgeType type) async {
    state = state.copyWith(badgeType: type);
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);

    try {
      await repo.markAllRead();
      final updated = state.items.map((e) => e.copyWith(isRead: true)).toList();
      state = state.copyWith(items: updated, unreadCount: 0);
      await _persistUnread(0);
    } catch (_) {
      await sync();
    }
  }

  Future<void> markRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);

    try {
      await repo.markRead(id);

      final updated = state.items
          .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
          .toList();
      final unread = updated.where((e) => !e.isRead).length;

      state = state.copyWith(items: updated, unreadCount: unread);
      await _persistUnread(unread);
    } catch (_) {
      await sync();
    }
  }

  Future<void> onPushReceived({required Map<String, dynamic> payload}) async {
    final nextUnread = state.unreadCount + 1;
    state = state.copyWith(unreadCount: nextUnread);
    await _persistUnread(nextUnread);
  }

  Future<void> _persistUnread(int unread) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_prefsKeyUnread, unread);
  }
}
