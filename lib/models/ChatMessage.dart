import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  user,
  system,
}

class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final String? productId;
  final String? productName;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.type = MessageType.user,
    this.isRead = false,
    this.productId,
    this.productName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.user,
      ),
      isRead: json['isRead'] as bool? ?? false,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'productId': productId,
      'productName': productName,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    String? productId,
    String? productName,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
    );
  }
}

class ChatRoom {
  final String roomId;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String sellerName;
  final DateTime lastMessageTime;
  final String lastMessage;
  final bool hasUnreadMessages;
  final String? productId;
  final String? productName;
  final String receiverId;

  ChatRoom({
    required this.roomId,
    required this.customerId,
    required this.customerName,
    required this.sellerId,
    required this.sellerName,
    required this.lastMessageTime,
    required this.lastMessage,
    this.hasUnreadMessages = false,
    this.productId,
    this.productName,
    required this.receiverId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
      lastMessage: json['lastMessage'] as String,
      hasUnreadMessages: json['hasUnreadMessages'] as bool? ?? false,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'customerId': customerId,
      'customerName': customerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
      'hasUnreadMessages': hasUnreadMessages,
      'productId': productId,
      'productName': productName,
      'receiverId': receiverId,
    };
  }

  ChatRoom copyWith({
    String? roomId,
    String? customerId,
    String? customerName,
    String? sellerId,
    String? sellerName,
    DateTime? lastMessageTime,
    String? lastMessage,
    bool? hasUnreadMessages,
    String? productId,
    String? productName,
    String? receiverId,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      receiverId: receiverId ?? this.receiverId,
    );
  }
}