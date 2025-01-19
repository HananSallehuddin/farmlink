import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ChatController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/models/ChatMessage.dart';
import 'package:farmlink/styles.dart';
import 'package:intl/intl.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/bottomNaviBarSeller.dart';

class ChatUI extends StatefulWidget {
  @override
  _ChatUIState createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> with AutomaticKeepAliveClientMixin {
  final ChatController chatController = Get.find<ChatController>();
  final LoginController loginController = Get.find<LoginController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString currentRole = ''.obs;
  String? chatRoomId;
  ChatRoom? chatRoom;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    chatRoomId = Get.arguments as String;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Load user role
      String? role = await loginController.getUserRole();
      currentRole.value = role ?? '';

      // Load chat room and messages
      await _loadChatRoom();
      await chatController.loadMessages(chatRoomId!);

      // Setup auto-scroll when new messages arrive
      chatController.currentMessages.listen((_) {
        _scrollToBottom();
      });

      // Mark messages as read
      await chatController.markMessagesAsRead(chatRoomId!);
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadChatRoom() async {
    try {
      final chatRoomDoc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        chatRoom = ChatRoom.fromJson(chatRoomDoc.data()!);
      }
    } catch (e) {
      print('Error loading chat room: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || isSending.value) return;

    try {
      isSending.value = true;
      await chatController.sendMessage(
        chatRoomId!,
        _messageController.text.trim(),
      );
      _messageController.clear();
      _scrollToBottom();
    } finally {
      isSending.value = false;
    }
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(time);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday ${DateFormat.Hm().format(time)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }

  String _formatDateHeader(DateTime messageTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(messageTime);
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index >= chatController.currentMessages.length) return false;
    
    if (index == chatController.currentMessages.length - 1) return true;
    
    final currentMessage = chatController.currentMessages[index];
    final nextMessage = chatController.currentMessages[index + 1];
    
    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    
    final nextDate = DateTime(
      nextMessage.timestamp.year,
      nextMessage.timestamp.month,
      nextMessage.timestamp.day,
    );
    
    return currentDate != nextDate;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
      bottomNavigationBar: Obx(() => currentRole.value == 'Seller'
          ? bottomNavigationBarSeller(currentRoute: '/chat')
          : bottomNavigationBarCustomer(currentRoute: '/chat')),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (isLoading.value || chatRoom == null) {
      return AppBar(title: Text('Chat'));
    }

    String displayName = '';
    if (currentUser?.uid == chatRoom!.customerId) {
      displayName = chatRoom!.sellerName.isNotEmpty ? chatRoom!.sellerName : 'Seller';
    } else {
      displayName = chatRoom!.customerName.isNotEmpty ? chatRoom!.customerName : 'Customer';
    }

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Styles.primaryColor,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(fontSize: 16),
                ),
                if (chatRoom!.productName != null)
                  Text(
                    'Re: ${chatRoom!.productName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (chatController.currentMessages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No messages yet\nStart the conversation!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.all(16),
          itemCount: chatController.currentMessages.length,
          itemBuilder: (context, index) {
            final message = chatController.currentMessages[index];
            final isMyMessage = message.senderId == currentUser?.uid;

            if (_shouldShowDateHeader(index)) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDateHeader(message.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  _buildMessageBubble(message, isMyMessage),
                ],
              );
            }

            return _buildMessageBubble(message, isMyMessage);
          },
        ),
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMyMessage) {
    if (message.type == MessageType.system) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMyMessage ? 64 : 0,
          right: isMyMessage ? 0 : 64,
        ),
        child: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMyMessage ? Styles.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMyMessage ? Radius.zero : null,
                  bottomLeft: !isMyMessage ? Radius.zero : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMyMessage ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMyMessage ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8),
            Obx(() => IconButton(
              icon: isSending.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryColor),
                      ),
                    )
                  : Icon(Icons.send),
              color: Styles.primaryColor,
              onPressed: isSending.value ? null : _sendMessage,
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}