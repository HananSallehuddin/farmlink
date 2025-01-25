import 'package:cloud_firestore/cloud_firestore.dart';

enum SupportMessageType {
  text,
  image,
  link,
  action,
  system
}

class SupportMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final SupportMessageType type;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final String? attachmentUrl;
  final Map<String, String>? actions;

  SupportMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.metadata,
    this.attachmentUrl,
    this.actions,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      type: SupportMessageType.values.firstWhere(
        (e) => e.toString() == 'SupportMessageType.${json['type']}',
        orElse: () => SupportMessageType.text,
      ),
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachmentUrl: json['attachmentUrl'] as String?,
      actions: (json['actions'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
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
      'metadata': metadata,
      'attachmentUrl': attachmentUrl,
      'actions': actions,
    };
  }

  SupportMessage copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    SupportMessageType? type,
    bool? isRead,
    Map<String, dynamic>? metadata,
    String? attachmentUrl,
    Map<String, String>? actions,
  }) {
    return SupportMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      actions: actions ?? this.actions,
    );
  }
}