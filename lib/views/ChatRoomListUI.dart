import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ChatController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/services/NotificationService.dart';
import 'package:farmlink/models/ChatMessage.dart';
import 'package:farmlink/styles.dart';
import 'package:intl/intl.dart';
import 'package:farmlink/views/SupportChatUI.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/bottomNaviBarSeller.dart';

class ChatRoomListUI extends StatefulWidget {
  @override
  _ChatRoomListUIState createState() => _ChatRoomListUIState();
}

class _ChatRoomListUIState extends State<ChatRoomListUI>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final chatController = Get.find<ChatController>();
  final loginController = Get.find<LoginController>();
  final userController = Get.find<UserController>();
  final notificationService = Get.find<NotificationService>();
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      await chatController.refreshChatRooms();
      // Notification service automatically listens through setupNotificationListeners()
      await notificationService.updateUnreadChatCount();
    } catch (e) {
      print('Error initializing chat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshChatRooms() async {
    try {
      isRefreshing.value = true;
      await chatController.refreshChatRooms();
    } finally {
      isRefreshing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.chat),
                  Obx(() {
                    final unreadCount = notificationService.unreadChats.value;
                    if (unreadCount > 0) {
                      return Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
              text: 'Chats',
            ),
            Tab(
              icon: Icon(Icons.support_agent),
              text: 'Support',
            ),
          ],
          labelColor: Styles.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Styles.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _refreshChatRooms,
            child: Obx(() {
              if (isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return _buildChatRoomsList();
            }),
          ),
          _buildSupportChat(),
        ],
      ),
      bottomNavigationBar: GetBuilder<UserController>(
        builder: (controller) {
          final role = controller.currentUser.value?.role ?? '';
          return role == 'Seller'
              ? bottomNavigationBarSeller(currentRoute: '/chatRoomList')
              : bottomNavigationBarCustomer(currentRoute: '/chatRoomList');
        },
      ),
    );
  }

  Widget _buildChatRoomsList() {
    return Obx(() {
      if (chatController.chatRooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No chats yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Start chatting with sellers or customers!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: chatController.chatRooms.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final chatRoom = chatController.chatRooms[index];
          return _buildChatRoomTile(chatRoom);
        },
      );
    });
  }

  Widget _buildChatRoomTile(ChatRoom chatRoom) {
    final currentUser = loginController.currentUser.value;
    if (currentUser == null) return SizedBox.shrink();

    String displayName = '';
    String avatarLetter = '?';
    bool isUnread = false;

    if (currentUser.uid == chatRoom.customerId) {
      displayName = chatRoom.sellerName;
      avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';
      isUnread = chatRoom.hasUnreadMessages && chatRoom.receiverId == currentUser.uid;
    } else {
      displayName = chatRoom.customerName;
      avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';
      isUnread = chatRoom.hasUnreadMessages && chatRoom.receiverId == currentUser.uid;
    }

    return Hero(
      tag: 'chatRoom_${chatRoom.roomId}',
      child: Material(
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Styles.primaryColor,
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isUnread)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                _formatLastMessageTime(chatRoom.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: isUnread ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (chatRoom.productName != null) ...[
                Text(
                  'Re: ${chatRoom.productName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Styles.primaryColor,
                  ),
                ),
                SizedBox(height: 4),
              ],
              Text(
                chatRoom.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnread ? Colors.black : Colors.grey,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          onTap: () async {
            final role = userController.currentUser.value?.role ?? '';
            Get.put(role, tag: 'currentRole', permanent: true);
            Get.toNamed('/chat', arguments: chatRoom.roomId);
          },
        ),
      ),
    );
  }

  String _formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  Widget _buildSupportChat() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 80,
            color: Styles.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'FarmLink Support',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Get help with orders, payments, shipping, and more. Our support bot is available 24/7 to assist you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.to(
              () => SupportChatUI(),
              transition: Transition.fadeIn,
              duration: Duration(milliseconds: 200),
            ),
            icon: Icon(Icons.chat_bubble_outline),
            label: Text('Start Support Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Styles.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Available topics include:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildTopicChip('Orders'),
              _buildTopicChip('Payments'),
              _buildTopicChip('Shipping'),
              _buildTopicChip('Account'),
              _buildTopicChip('Products'),
            ],
          ),
          SizedBox(height: 32),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 32),
          //   child: Text(
          //     'Our support bot user pre-defined intent to help you solved queries.',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       fontSize: 12,
          //       color: Colors.grey[600],
          //       height: 1.5,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Styles.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Styles.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }
}