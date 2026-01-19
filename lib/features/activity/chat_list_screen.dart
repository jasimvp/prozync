import 'package:flutter/material.dart';
import 'package:prozync/features/activity/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [],
      ),
      body: ListView.builder(
        itemCount: 15,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          final isUnread = index < 3;
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userName: 'User $index',
                    userImage: 'https://i.pravatar.cc/150?u=chat$index',
                  ),
                ),
              );
            },
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?u=chat$index'),
                ),
                if (index % 5 == 0) // Online indicator for some users
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              'User $index',
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    isUnread
                        ? 'Sent you a message • ${index}m'
                        : 'Seen • ${index}h',
                    style: TextStyle(
                      color: isUnread ? Colors.black87 : Colors.grey,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
