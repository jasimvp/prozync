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

        _currentMessages = allMessages
            .where((m) {
              return (m.senderId == otherUserId && m.isMe == false) ||
                  (m.isMe == true && m.receiverId == otherUserId);
            })
            .map((m) {
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
            })
            .toList();

        _currentMessages.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        ); // Oldest first for chat view

        // Mark as read locally and on server
        markConversationAsRead(otherUserId);
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _messages = [
      Message(
        id: 1,
        senderId: otherUserId,
        senderName: 'Other User',
        receiverId: 1, // Assuming current user ID is 1 for mock
        receiverName: 'jasim_dev',
        text: 'Hello!',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
      Message(
        id: 2,
        senderId: 1,
        senderName: 'jasim_dev',
        receiverId: otherUserId,
        receiverName: 'Other User',
        text: 'Hi there! How can I help?',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isMe: true,
      ),
      Message(
        id: 3,
        senderId: otherUserId,
        senderName: 'Other User',
        receiverId: 1,
        receiverName: 'jasim_dev',
        text: 'I was wondering about the Firebase migration...',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(int receiverId, String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 1, // Mock current user ID
      senderName: 'jasim_dev', // Mock current user name
      receiverId: receiverId,
      receiverName: _chats.firstWhere((c) => c.id == receiverId, orElse: () => ChatPreview(id: receiverId, otherUserName: 'Unknown', otherUserImage: '', lastMessage: '', lastMessageTime: DateTime.now(), unreadCount: 0)).otherUserName,
      text: text,
      isRead: false,
      createdAt: DateTime.now(),
      isMe: true,
    );
    _messages.add(newMessage);
    
    // Also update chat preview
    final idx = _chats.indexWhere((c) => c.id == receiverId);
    if (idx != -1) {
      _chats[idx] = ChatPreview(
        id: receiverId,
        otherUserName: _chats[idx].otherUserName,
        otherUserImage: _chats[idx].otherUserImage,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );
    } else {
      // If sending to a new user not in chat list, add a new preview
      _chats.insert(0, ChatPreview(
        id: receiverId,
        otherUserName: 'New User $receiverId', // Placeholder
        otherUserImage: 'https://ui-avatars.com/api/?name=New+User&background=003366&color=fff',
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      ));
    }

    notifyListeners();
    return true;
  }

  Future<void> markConversationAsRead(int otherUserId) async { // Renamed from markConversationsAsRead to match original signature
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _chats.indexWhere((c) => c.id == otherUserId); // Parameter name adjusted
    if (idx != -1) {
      _chats[idx] = ChatPreview(
        id: otherUserId, // Parameter name adjusted
        otherUserName: _chats[idx].otherUserName,
        otherUserImage: _chats[idx].otherUserImage,
        lastMessage: _chats[idx].lastMessage,
        lastMessageTime: _chats[idx].lastMessageTime,
        unreadCount: 0,
      );
      notifyListeners();
    }
    // Also mark messages in the current conversation as read
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isMe && !_messages[i].isRead) {
        _messages[i] = Message(
          id: _messages[i].id,
          senderId: _messages[i].senderId,
          senderName: _messages[i].senderName,
          receiverId: _messages[i].receiverId,
          receiverName: _messages[i].receiverName,
          text: _messages[i].text,
          isRead: true,
          createdAt: _messages[i].createdAt,
          isMe: _messages[i].isMe,
        );
      }
    }
    notifyListeners();
  }

  Future<Message?> fetchMessageById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _messages.firstWhere((msg) => msg.id == id, orElse: () => null);
  }

  Future<Message?> updateMessageById(int id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _messages.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      final original = _messages[index];
      _messages[index] = Message(
        id: original.id,
        senderId: original.senderId,
        senderName: original.senderName,
        receiverId: original.receiverId,
        receiverName: original.receiverName,
        text: data['text'] as String? ?? original.text,
        isRead: data['is_read'] as bool? ?? original.isRead,
        createdAt: original.createdAt,
        isMe: original.isMe,
      );
      notifyListeners();
      return _messages[index];
    }
    return null;
  }

  Future<Message?> partialUpdateMessageById(int id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _messages.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      final original = _messages[index];
      _messages[index] = Message(
        id: original.id,
        senderId: original.senderId,
        senderName: original.senderName,
        receiverId: original.receiverId,
        receiverName: original.receiverName,
        text: data['text'] as String? ?? original.text,
        isRead: data['is_read'] as bool? ?? original.isRead,
        createdAt: original.createdAt,
        isMe: original.isMe,
      );
      notifyListeners();
      return _messages[index];
    }
    return null;
  }

  Future<bool> deleteMessageById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final initialLength = _messages.length;
    _messages.removeWhere((msg) => msg.id == id);
    if (_messages.length < initialLength) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<Message>> fetchConversation(int otherUserId) async {
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentUserId = ProfileService().myProfile?.user ?? 0;
        return data
            .map((json) => Message.fromJson(json, currentUserId))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching conversation with $otherUserId: $e');
    }
    return [];
  }

  void clear() {
    _chats = [];
    _currentMessages = [];
    _isLoading = false;
    _readMessageIds.clear();
    notifyListeners();
  }
}
