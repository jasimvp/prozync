import 'package:flutter/material.dart';
import 'package:prozync/core/services/notification_service.dart';
import 'package:prozync/models/notification_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notificationService,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity'),
            actions: [
              IconButton(
                onPressed: () => _notificationService.fetchNotifications(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _notificationService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _notificationService.notifications.isEmpty
                        ? const Center(child: Text('No recent activity'))
                        : ListView.separated(
                            itemCount: _notificationService.notifications.length,
                            separatorBuilder: (context, index) => const Divider(indent: 72),
                            itemBuilder: (context, index) {
                              return _buildActivityTile(_notificationService.notifications[index]);
                            },
                          ),
                  ),
                ),
        );
      },
    );
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'just now';
  }

  Widget _buildActivityTile(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.status) {
      case 'ACCEPTED':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'REJECTED':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    return ListTile(
      onTap: () => _notificationService.markAsRead(notification.id),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${notification.senderName}&background=random'),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.grey : Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(icon, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(text: '${notification.senderName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: notification.message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      subtitle: Text(_timeAgo(notification.createdAt), style: const TextStyle(fontSize: 12)),
      trailing: notification.status == 'PENDING'
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 12)),
                ),
              ],
            )
          : null,
    );
  }
}
