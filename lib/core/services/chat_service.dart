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
  final Set<int> _readMessageIds = {}; // Track IDs we've marked read locally

  List<ChatPreview> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  Future<void> fetchChats() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      if (ProfileService().myProfile == null) {
        await ProfileService().fetchMyProfile();
      }
      
      // Assuming GET /api/messages/ returns all messages or recent ones
      // We will group them to form the chat list
      final response = await _apiService.get('/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        final allMessages = data
            .map((json) => Message.fromJson(json, currentUserId))
            .toList();

        // Group by other user
        final Map<int, List<Message>> grouped = {};
        for (var msg in allMessages) {
          final otherId = msg.isMe ? (msg.receiverId ?? 0) : msg.senderId;
          if (otherId == 0) continue; // Skip invalid
          if (!grouped.containsKey(otherId)) grouped[otherId] = [];
          
          // Apply local read status
          final isActuallyRead = msg.isRead || _readMessageIds.contains(msg.id);
          final processedMsg = Message(
            id: msg.id,
            senderId: msg.senderId,
            senderName: msg.senderName,
            receiverId: msg.receiverId,
            receiverName: msg.receiverName,
            text: msg.text,
            isRead: isActuallyRead,
            createdAt: msg.createdAt,
            isMe: msg.isMe,
          );
          
          grouped[otherId]!.add(processedMsg);
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
      if (ProfileService().myProfile == null) {
        await ProfileService().fetchMyProfile();
      }

      // If API supports filtering: /messages/?user=ID or similar.
      // For now, we fetch all (cached/lightweight ideally) and filter.
      // Optimally: GET /messages/conversation/?user_id=X
      final response = await _apiService.get('/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        final allMessages = data
            .map((json) => Message.fromJson(json, currentUserId))
            .toList();

        _currentMessages = allMessages.where((m) {
          return (m.senderId == otherUserId && m.isMe == false) ||
              (m.isMe == true && m.receiverId == otherUserId);
        }).map((m) {
          // Apply local read status
          if (_readMessageIds.contains(m.id)) {
            return Message(
              id: m.id,
              senderId: m.senderId,
              senderName: m.senderName,
              receiverId: m.receiverId,
              receiverName: m.receiverName,
              text: m.text,
              isRead: true,
              createdAt: m.createdAt,
              isMe: m.isMe,
            );
          }
          return m;
        }).toList();

        _currentMessages.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        ); // Oldest first for chat view

        // Mark as read locally and on server
        markConversationAsRead(otherUserId);
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
        // Ensure we have the current user ID to correctly identify 'isMe'
        if (ProfileService().myProfile == null) {
          await ProfileService().fetchMyProfile();
        }
        final currentUserId = ProfileService().myProfile?.user ?? 0;

        final newMessage = Message.fromJson(
          jsonDecode(response.body),
          currentUserId,
        );
        _currentMessages.add(newMessage); // Add locally
        notifyListeners();

        // Refresh chat list to update last message
        fetchChats();
        return true;
      } else {
        debugPrint(
          'Send message failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
    return false;
  }

  Future<void> markConversationAsRead(int otherUserId) async {
    bool changed = false;
    final List<int> toMarkOnServer = [];

    // 1. Update local messages state
    for (int i = 0; i < _currentMessages.length; i++) {
      final msg = _currentMessages[i];
      if (!msg.isMe && !msg.isRead && msg.senderId == otherUserId) {
        _readMessageIds.add(msg.id);
        _currentMessages[i] = Message(
          id: msg.id,
          senderId: msg.senderId,
          senderName: msg.senderName,
          receiverId: msg.receiverId,
          receiverName: msg.receiverName,
          text: msg.text,
          isRead: true,
          createdAt: msg.createdAt,
          isMe: msg.isMe,
        );
        toMarkOnServer.add(msg.id);
        changed = true;
      }
    }

    // 2. Update the chat preview in the list
    final chatIndex = _chats.indexWhere((c) => c.id == otherUserId);
    if (chatIndex != -1) {
      if (_chats[chatIndex].unreadCount > 0) {
        final chat = _chats[chatIndex];
        _chats[chatIndex] = ChatPreview(
          id: chat.id,
          otherUserName: chat.otherUserName,
          otherUserImage: chat.otherUserImage,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          unreadCount: 0,
        );
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }

    // 3. Mark on server
    for (var id in toMarkOnServer) {
      try {
        await _apiService.patch('/messages/$id/', {'is_read': true});
      } catch (e) {
        debugPrint('Error marking message $id as read: $e');
      }
    }
  }

  Future<Message?> fetchMessageById(int id) async {
    try {
      final response = await _apiService.get('/messages/$id/');
      if (response.statusCode == 200) {
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        return Message.fromJson(jsonDecode(response.body), currentUserId);
      }
    } catch (e) {
      debugPrint('Error fetching message $id: $e');
    }
    return null;
  }

  Future<Message?> updateMessageById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/messages/$id/', data);
      if (response.statusCode == 200) {
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        return Message.fromJson(jsonDecode(response.body), currentUserId);
      }
    } catch (e) {
      debugPrint('Error updating message $id: $e');
    }
    return null;
  }

  Future<bool> deleteMessageById(int id) async {
    try {
      final response = await _apiService.delete('/messages/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting message $id: $e');
      return false;
    }
  }

  Future<List<Message>> fetchConversation(int otherUserId) async {
    try {
      final response = await _apiService.get('/messages/conversation/?user_id=$otherUserId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        return data.map((json) => Message.fromJson(json, currentUserId)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching conversation with $otherUserId: $e');
    }
    return [];
  }
}
