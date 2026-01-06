import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_controller.dart';

class NotificationSyncOnResume extends ConsumerStatefulWidget {
  const NotificationSyncOnResume({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationSyncOnResume> createState() =>
      _NotificationSyncOnResumeState();
}

class _NotificationSyncOnResumeState extends ConsumerState<NotificationSyncOnResume>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationControllerProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
