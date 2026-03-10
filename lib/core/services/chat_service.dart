import 'package:flutter/material.dart';
import 'package:prozync/models/chat_model.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  List<ChatPreview> _chats = [];
  List<Message> _currentMessages = [];
  bool _isLoading = false;

  List<ChatPreview> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  Future<void> fetchChats() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _chats = [
      ChatPreview(
        id: 2,
        otherUserName: 'Alice Smith',
        otherUserImage: 'https://ui-avatars.com/api/?name=Alice+Smith&background=003366&color=fff',
        lastMessage: 'Hey! How is the project going?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        unreadCount: 2,
      ),
      ChatPreview(
        id: 3,
        otherUserName: 'Bob Builder',
        otherUserImage: 'https://ui-avatars.com/api/?name=Bob+Builder&background=003366&color=fff',
        lastMessage: 'Can you check the latest code?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 0,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessages(int otherUserId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _currentMessages = [
      Message(
        id: 1,
        senderId: otherUserId,
        senderName: 'Other User',
        receiverId: 1,
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
    markConversationAsRead(otherUserId);
  }

  Future<bool> sendMessage(int receiverId, String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 1,
      senderName: 'jasim_dev',
      receiverId: receiverId,
      receiverName: 'Other User',
      text: text,
      isRead: false,
      createdAt: DateTime.now(),
      isMe: true,
    );
    _currentMessages.add(newMessage);
    
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
      _chats.insert(0, ChatPreview(
        id: receiverId,
        otherUserName: 'New User',
        otherUserImage: 'https://ui-avatars.com/api/?name=New+User&background=003366&color=fff',
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      ));
    }

    notifyListeners();
    return true;
  }

  Future<void> markConversationAsRead(int otherUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _chats.indexWhere((c) => c.id == otherUserId);
    if (idx != -1) {
      _chats[idx] = ChatPreview(
        id: otherUserId,
        otherUserName: _chats[idx].otherUserName,
        otherUserImage: _chats[idx].otherUserImage,
        lastMessage: _chats[idx].lastMessage,
        lastMessageTime: _chats[idx].lastMessageTime,
        unreadCount: 0,
      );
    }
    for (int i = 0; i < _currentMessages.length; i++) {
      if (!_currentMessages[i].isMe && !_currentMessages[i].isRead) {
        final m = _currentMessages[i];
        _currentMessages[i] = Message(
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
    }
    notifyListeners();
  }

  Future<List<Message>> fetchConversation(int otherUserId) async {
    await fetchMessages(otherUserId);
    return _currentMessages;
  }

  void clear() {
    _chats = [];
    _currentMessages = [];
    _isLoading = false;
    notifyListeners();
  }
}
