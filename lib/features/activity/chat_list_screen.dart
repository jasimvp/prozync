import 'package:flutter/material.dart';
import 'package:prozync/features/activity/chat_screen.dart';
import 'package:prozync/core/services/chat_service.dart';
import 'package:prozync/core/theme/app_theme.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _chatService.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chatService,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_note_rounded, size: 28)),
              const SizedBox(width: 8),
            ],
          ),
          body: _chatService.isLoading && _chatService.chats.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _chatService.fetchChats(),
                  child: ListView.builder(
                    itemCount: _chatService.chats.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      final chat = _chatService.chats[index];
                      final isUnread = chat.unreadCount > 0;
                      
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chat.id,
                                userName: chat.otherUserName,
                                userImage: chat.otherUserImage,
                              ),
                            ),
                          );
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(chat.otherUserImage),
                            ),
                            if (index % 3 == 0) // Mock online status
                              Positioned(
                                right: 0,
                                bottom: 2,
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
                          chat.otherUserName,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(chat.lastMessageTime),
                              style: TextStyle(
                                color: isUnread ? AppTheme.primaryColor : Colors.grey,
                                fontSize: 12,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}
