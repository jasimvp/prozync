import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.separated(
            itemCount: 15,
            separatorBuilder: (context, index) => const Divider(indent: 72),
            itemBuilder: (context, index) {
              return _buildActivityTile(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(int index) {
    final types = ['like', 'follow', 'collab', 'comment'];
    final type = types[index % 4];

    IconData icon;
    Color color;
    String message;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        color = Colors.red;
        message = 'liked your post "New UI Design"';
        break;
      case 'follow':
        icon = Icons.person_add;
        color = Colors.blue;
        message = 'started following you';
        break;
      case 'collab':
        icon = Icons.handshake;
        color = Colors.orange;
        message = 'invited you to collaborate on "ProSync App"';
        break;
      default:
        icon = Icons.chat_bubble;
        color = Colors.green;
        message = 'commented: "Great work on the backend!"';
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$index'),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 10, color: color),
            ),
          ),
        ],
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            const TextSpan(text: 'John Doe ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      subtitle: const Text('2h ago', style: TextStyle(fontSize: 12)),
      trailing: type == 'collab'
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
                  child: const Text('Accept', style: TextStyle(fontSize: 12)),
                ),
              ],
            )
          : null,
    );
  }
}
