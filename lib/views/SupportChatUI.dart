import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmlink/models/SupportChatBot.dart';
import 'package:farmlink/models/ChatMessage.dart';
import 'package:farmlink/styles.dart';
import 'package:intl/intl.dart';

class SupportChatUI extends StatefulWidget {
  @override
  _SupportChatUIState createState() => _SupportChatUIState();
}

class _SupportChatUIState extends State<SupportChatUI> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool showScrollButton = false.obs;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  late String supportChatId;

  Map<String, String>? currentQuickReplies;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 1000) {
        showScrollButton.value = true;
      } else {
        showScrollButton.value = false;
      }
    });
  }

  Future<void> _initializeChat() async {
    if (currentUser == null) return;

    try {
      // Create or get support chat document
      supportChatId = 'support_${currentUser!.uid}';
      final supportChatDoc = await _firestore
          .collection('supportChats')
          .doc(supportChatId)
          .get();

      if (!supportChatDoc.exists) {
        // Initialize new support chat
        await _firestore.collection('supportChats').doc(supportChatId).set({
          'userId': currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': 'Chat started',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });

        // Send welcome message
        _sendBotMessage(
          'Welcome to FarmLink Support! How can I help you today?',
          {
            'Check Orders': 'I want to check my orders',
            'Payment Help': 'I need help with payment',
            'Shipping Info': 'Tell me about shipping',
            'Account Help': 'I need account help',
          },
        );
      }

      // Set up message listener
      _firestore
          .collection('supportChats')
          .doc(supportChatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        messages.value = snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error initializing support chat: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize support chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final messageRef = _firestore
          .collection('supportChats')
          .doc(supportChatId)
          .collection('messages')
          .doc();

      // Create user message
      final userMessage = ChatMessage(
        messageId: messageRef.id,
        senderId: currentUser!.uid,
        senderName: currentUser!.displayName ?? 'User',
        receiverId: 'support_bot',
        message: text,
        timestamp: DateTime.now(),
        type: MessageType.user,
      );

      // Send user message
      await messageRef.set(userMessage.toJson());

      // Update chat metadata
      await _firestore.collection('supportChats').doc(supportChatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Clear input and scroll to bottom
      _messageController.clear();
      _scrollToBottom();

      // Show typing indicator
      isTyping.value = true;

      // Simulate bot thinking time
      await Future.delayed(Duration(seconds: 1));

      // Generate and send bot response
      final botResponse = SupportChatBot.generateResponse(text);
      final quickReplies = SupportChatBot.getQuickReplies(text);
      
      await _sendBotMessage(botResponse, quickReplies);

      isTyping.value = false;
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendBotMessage(String text, Map<String, String>? quickReplies) async {
    try {
      final messageRef = _firestore
          .collection('supportChats')
          .doc(supportChatId)
          .collection('messages')
          .doc();

      final botMessage = ChatMessage(
        messageId: messageRef.id,
        senderId: 'support_bot',
        senderName: 'Support Bot',
        receiverId: currentUser!.uid,
        message: text,
        timestamp: DateTime.now(),
        type: MessageType.system,
      );

      await messageRef.set(botMessage.toJson());

      // Update quick replies if provided
      if (quickReplies != null) {
        setState(() {
          currentQuickReplies = quickReplies;
        });
      }

      // Update chat metadata
      await _firestore.collection('supportChats').doc(supportChatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending bot message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support Chat'),
            Text(
              'FarmLink Support Bot',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildQuickReplies(),
          _buildMessageInput(),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!showScrollButton.value) return SizedBox.shrink();
        return FloatingActionButton(
          mini: true,
          backgroundColor: Styles.primaryColor,
          child: Icon(Icons.keyboard_arrow_down),
          onPressed: _scrollToBottom,
        );
      }),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.support_agent,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No messages yet\nStart a conversation!',
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

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.all(16),
        itemCount: messages.length + (isTyping.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (isTyping.value && index == 0) {
            return _buildTypingIndicator();
          }

          final message = messages[isTyping.value ? index - 1 : index];
          final isUserMessage = message.senderId == currentUser?.uid;

          return _buildMessageBubble(message, isUserMessage);
        },
      );
    });
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return _buildBouncingDot(index);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouncingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300),
      curve: Interval(index * 0.2, 0.7, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -3 * value),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUserMessage ? Styles.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUserMessage ? Radius.zero : null,
            bottomLeft: !isUserMessage ? Radius.zero : null,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isUserMessage ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    if (currentQuickReplies == null || currentQuickReplies!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: currentQuickReplies!.length,
        itemBuilder: (context, index) {
          final entry = currentQuickReplies!.entries.elementAt(index);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => _sendMessage(entry.value),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Styles.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                entry.key,
                style: TextStyle(color: Styles.primaryColor),
              ),
            ),
          );
        },
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
                onSubmitted: (_) => _sendMessage(_messageController.text),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send),
              color: Styles.primaryColor,
              onPressed: () => _sendMessage(_messageController.text),
            ),
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