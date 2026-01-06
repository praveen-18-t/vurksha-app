import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/notification_controller.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).sync();
      ref.read(notificationControllerProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: state.items.isEmpty && state.isSyncing
          ? Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: item.isRead
                        ? null
                        : theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  subtitle: Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: item.isRead
                      ? null
                      : TextButton(
                          onPressed: () {
                            ref
                                .read(notificationControllerProvider.notifier)
                                .markRead(item.id);
                          },
                          child: const Text('Mark read'),
                        ),
                  onTap: () {
                    ref
                        .read(notificationControllerProvider.notifier)
                        .markRead(item.id);
                  },
                );
              },
            ),
    );
  }
}
