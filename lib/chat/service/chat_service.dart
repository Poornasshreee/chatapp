import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatapp/chat/model/user_model.dart';
import 'package:chatapp/chat/model/message_request_model.dart';
import 'package:chatapp/chat/model/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get currentUserId => _auth.currentUser?.uid ?? "";

  // -------------------------USERS-------------------------
  Stream<List<UserModel>> getAllUsers() {
    if (currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection("users")
        .where("uid", isNotEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((user) => user.uid != currentUserId)
              .toList(),
        );
  }

  // Online Status
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (currentUserId.isEmpty) return;
    try {
      await _firestore.collection("users").doc(currentUserId).update({
        "isOnline": isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating online status: $e");
    }
  }

  Future<bool> areUsersFriends(String userID1, String userID2) async {
    final chatID = _generateChatID(userID1, userID2);
    final friendship = await _firestore
        .collection("friendships")
        .doc(chatID)
        .get();

    final exists = friendship.exists;
    return exists;
  }

  Future<String?> sendMessageRequest(String receiverId) async {
    try {
      final currentUser = _auth.currentUser!;
      final requestId = '${currentUserId}_$receiverId';

      final existingRequest = await _firestore
          .collection("messageRequests")
          .doc(requestId)
          .get();
      
      if (existingRequest.exists &&
          existingRequest.data()?['status'] == 'pending') {
        return 'Request already sent';
      }

      final request = MessageRequestModel(
        id: requestId,
        senderId: currentUserId,
        receiverId: receiverId,
        senderName: currentUser.displayName ?? "user",
        senderEmail: currentUser.email ?? '',
        status: 'pending',
        createdAt: DateTime.now(),
        photoURL: currentUser.photoURL,
      );

      await _firestore
          .collection("messageRequests")
          .doc(requestId)
          .set(request.toMap());

      return requestId;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<MessageRequestModel>> getPendingRequests() {
    if (currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection("messageRequests")
        .where("receiverId", isEqualTo: currentUserId)
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Accept message request
  Future<String> acceptMessageRequest(String requestId, String senderId) async {
    try {
      final batch = _firestore.batch();
      
      // Update request status
      batch.update(_firestore.collection("messageRequests").doc(requestId), {
        'status': 'accepted',
      });

      // Create friendship
      final friendshipId = _generateChatID(currentUserId, senderId);
      batch.set(_firestore.collection("friendships").doc(friendshipId), {
        'chatId': friendshipId,
        'participants': [currentUserId, senderId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {currentUserId: 0, senderId: 0},
      });

      // System message - auto generate message when request is accepted
      final messageId = _firestore.collection("messages").doc().id;
      batch.set(_firestore.collection("messages").doc(messageId), {
        'messageId': messageId,
        'chatId': friendshipId,
        'senderId': 'system',
        'senderName': 'System',
        'message': 'Request has been accepted. You can now start chatting!',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
        'status': 'read',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // Reject message request
  Future<String> rejectMessageRequest(
    String requestId, {
    bool deleteRequest = true,
  }) async {
    try {
      if (deleteRequest) {
        await _firestore.collection("messageRequests").doc(requestId).delete();
      } else {
        await _firestore.collection("messageRequests").doc(requestId).update({
          'status': 'rejected',
        });
      }
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------MESSAGES-------------------------
  
  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String chatId) async {
    final fileName = 
        '${DateTime.now().millisecondsSinceEpoch}_${currentUserId}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(chatId)
        .child(fileName);

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Send image message
  Future<String> sendImageMessage({
    required String chatId,
    required String imagePath,
    required String receiverId,
    String? caption,
  }) async {
    try {
      // Upload image first
      final imageUrl = await uploadImage(File(imagePath), chatId);
      
      if (imageUrl.isEmpty) {
        return "Failed to upload image";
      }

      // Send image message
      return await sendImageMessageWithUrl(
        chatId: chatId,
        imageUrl: imageUrl,
        receiverId: receiverId,
        caption: caption,
      );
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  // Send image message with URL
  Future<String> sendImageMessageWithUrl({
    required String chatId,
    required String imageUrl,
    required String receiverId,
    String? caption,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("messages").doc().id;
      final batch = _firestore.batch();

      // Create image message
      batch.set(_firestore.collection("messages").doc(messageId), {
        'messageId': messageId,
        'chatId': chatId,
        'senderId': currentUserId,
        'senderName': currentUser.displayName ?? "User",
        'senderPhotoURL': currentUser.photoURL,
        'message': caption ?? '',
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
        'status': 'sent',
        'readBy': {},
      });

      // Update chat with last message
      final chatDoc = await _firestore.collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }

      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere((id) => id != currentUserId);

      batch.update(_firestore.collection("chats").doc(chatId), {
        'lastMessage': caption?.isNotEmpty == true ? caption : "📷 Photo",
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
        'unreadCount.$currentUserId': 0,
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      print("Error sending image message: $e");
      return e.toString();
    }
  }

  // Send text message
  Future<String> sendTextMessage({
    required String chatId,
    required String message,
    required String receiverId,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("messages").doc().id;
      final batch = _firestore.batch();

      // Use server timestamp for consistency across devices
      batch.set(_firestore.collection("messages").doc(messageId), {
        'messageId': messageId,
        'chatId': chatId,
        'senderId': currentUserId,
        'senderName': currentUser.displayName ?? "User",
        'senderPhotoURL': currentUser.photoURL,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'status': 'sent',
        'readBy': {},
      });

      // Update chat with last message
      final chatDoc = await _firestore.collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }

      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere((id) => id != currentUserId);

      batch.update(_firestore.collection("chats").doc(chatId), {
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
        'unreadCount.$currentUserId': 0,
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      print("Error sending message: $e");
      return e.toString();
    }
  }

  // Get chat messages
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection("messages")
        .where("chatId", isEqualTo: chatId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();
      
      // Reset unread count first
      final chatRef = _firestore.collection("chats").doc(chatId);
      batch.update(chatRef, {
        'unreadCount.${currentUser.uid}': 0,
        // Add timestamp to force listeners to update
        'lastReadTime.${currentUser.uid}': FieldValue.serverTimestamp(),
      });
  
      // Get unread messages
      QuerySnapshot messagesQuery = await _firestore
          .collection("messages")
          .where("chatId", isEqualTo: chatId)
          .where("senderId", isNotEqualTo: currentUser.uid)
          .get();

      // Update each message's readBy field
      for (var doc in messagesQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
        
        // Only update if current user hasn't read it yet
        if (!readBy.containsKey(currentUser.uid)) {
          batch.update(doc.reference, {
            'readBy.${currentUser.uid}': FieldValue.serverTimestamp(),
            'status': 'read',
          });
        }
      }
      
      await batch.commit();
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  String _generateChatID(String userID1, String userID2) {
    final ids = [userID1, userID2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // -------------------------TYPING INDICATOR-------------------------
  
  // Get typing status from Firestore
  Stream<bool> getTypingStatus(String chatId, String otherUserId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['typing'] is! Map) return false;
      
      final typing = data['typing'] as Map<String, dynamic>;
      final typingTimestamp = data['typingTimestamp'] as Map<String, dynamic>? ?? {};
      
      // Check if the OTHER user is typing (not current user)
      final isTyping = typing[otherUserId] as bool? ?? false;
      
      if (!isTyping) return false;
      
      // Check if typing status is recent (within 5 seconds)
      final timestamp = typingTimestamp[otherUserId];
      if (timestamp != null) {
        final typingTime = (timestamp as Timestamp).toDate();
        final now = DateTime.now();
        final isRecent = now.difference(typingTime).inSeconds < 5;
        return isRecent;
      }
      
      return false;
    });
  }

  // Set typing status in Firestore
  Future<void> setTyping(String chatId, bool isTyping) async {
    if (currentUserId.isEmpty) return;
    
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'typing.$currentUserId': isTyping,
        'typingTimestamp.$currentUserId': FieldValue.serverTimestamp(),
      });

      // Only set cleanup timer when stopping typing
      if (!isTyping) {
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            await _firestore.collection('chats').doc(chatId).update({
              'typing.$currentUserId': false,
            });
          } catch (e) {
            // Ignore error for cleanup
          }
        });
      }
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }
}