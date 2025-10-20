import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/chat/model/message_model.dart';

class BuildMessageStatusIcon extends StatelessWidget {
  final MessageModel message;
  final String uid;

  const BuildMessageStatusIcon({
    Key? key,
    required this.message,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // Only show status for messages sent by current user
    if (message.senderId != currentUserId) {
      return const SizedBox.shrink();
    }

    // Listen to the receiver's user document
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(message.receiverId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        bool isReceiverOnline = false;
        
        // Check if user document exists and fetch 'isOnline' field
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          isReceiverOnline = userData['isOnline'] ?? false;
        }
        
        // Check if the receiver has read this message
        final isMessageRead = message.isRead;

        if (isMessageRead) {
          // Message was read - show two blue ticks
          return const Icon(
            Icons.done_all,
            size: 16,
            color: Colors.blue,
          );
        } else if (isReceiverOnline) {
          // Receiver is online but hasn't read - show two grey ticks
          return const Icon(
            Icons.done_all,
            size: 16,
            color: Colors.grey,
          );
        } else {
          // Message delivered but receiver offline - show single tick
          return const Icon(
            Icons.check,
            size: 16,
            color: Colors.grey,
          );
        }
      },
    );
  }
}