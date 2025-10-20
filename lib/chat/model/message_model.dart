class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String? senderPhotoURL;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final String type; // 'text', 'image', 'system'
  final String status; // 'sent', 'delivered', 'read'
  final Map<String, dynamic> readBy;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.senderPhotoURL,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.type,
    required this.status,
    this.readBy = const {},
  });

  // Helper getter to check if message is read
  bool get isRead => status == 'read' || readBy.isNotEmpty;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Derive receiverId from chatId if not present
    String receiverId = json['receiverId'] ?? '';
    
    return MessageModel(
      messageId: json['messageId'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: receiverId,
      senderName: json['senderName'] ?? 'Unknown',
      senderPhotoURL: json['senderPhotoURL'],
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
              : (json['timestamp'] as dynamic).toDate())
          : DateTime.now(),
      type: json['type'] ?? 'text',
      status: json['status'] ?? 'sent',
      readBy: json['readBy'] is Map
          ? Map<String, dynamic>.from(json['readBy'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
      'status': status,
      'readBy': readBy,
    };
  }
}