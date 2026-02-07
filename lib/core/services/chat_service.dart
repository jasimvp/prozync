import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prozync/models/chat_model.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();
  List<ChatPreview> _chats = [];
  List<Message> _currentMessages = [];
  bool _isLoading = false;

  List<ChatPreview> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  Future<void> fetchChats() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Assuming GET /api/messages/ returns all messages or recent ones
      // We will group them to form the chat list
      final response = await _apiService.get('/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.id ?? 0;
        final allMessages = data
            .map((json) => Message.fromJson(json, currentUserId))
            .toList();

        // Group by other user
        final Map<int, List<Message>> grouped = {};
        for (var msg in allMessages) {
          final otherId = msg.isMe ? (msg.receiverId ?? 0) : msg.senderId;
          if (otherId == 0) continue; // Skip invalid
          if (!grouped.containsKey(otherId)) grouped[otherId] = [];
          grouped[otherId]!.add(msg);
        }

        _chats = grouped.entries.map((entry) {
          final msgs = entry.value;
          msgs.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          ); // Newest first
          final lastMsg = msgs.first;
          final otherUser = lastMsg.isMe
              ? lastMsg.receiverName
              : lastMsg.senderName;

          return ChatPreview(
            id: entry.key, // otherUserId as ID
            otherUserName: otherUser ?? 'User',
            otherUserImage:
                'https://ui-avatars.com/api/?name=${otherUser ?? 'User'}', // Placeholder
            lastMessage: lastMsg.text,
            lastMessageTime: lastMsg.createdAt,
            unreadCount: msgs.where((m) => !m.isMe && !m.isRead).length,
          );
        }).toList();

        _chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      }
    } catch (e) {
      debugPrint('Error fetching chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int otherUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // If API supports filtering: /messages/?user=ID or similar.
      // For now, we fetch all (cached/lightweight ideally) and filter.
      // Optimally: GET /messages/conversation/?user_id=X
      final response = await _apiService.get('/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.id ?? 0;
        final allMessages = data
            .map((json) => Message.fromJson(json, currentUserId))
            .toList();

        _currentMessages = allMessages.where((m) {
          return (m.senderId == otherUserId && m.isMe == false) ||
              (m.isMe == true && m.receiverId == otherUserId);
        }).toList();

        _currentMessages.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        ); // Oldest first for chat view
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int receiverId, String text) async {
    try {
      final response = await _apiService.post('/messages/', {
        'receiver': receiverId,
        'message': text,
        'is_read': false, // Default
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final currentUserId = ProfileService().myProfile?.id ?? 0;
        final newMessage = Message.fromJson(
          jsonDecode(response.body),
          currentUserId,
        );
        _currentMessages.add(newMessage); // Add locally
        notifyListeners();

        // Refresh chat list to update last message
        fetchChats();
        return true;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
    return false;
  }
}
