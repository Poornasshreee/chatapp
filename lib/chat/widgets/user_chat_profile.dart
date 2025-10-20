import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Placeholder classes to make the code runnable and show the structure
class ChatScreen {
  final otherUser = User(name: "John Doe", uid: "123", photoURL: null);
  final chatId = "chat_123";
}
class User {
  final String name;
  final String uid;
  final String? photoURL;
  User({required this.name, required this.uid, this.photoURL});
}
// Placeholder providers for Riverpod
final userStatusProvider =
    Provider.family<AsyncValue<bool>, String>((ref, uid) => const AsyncValue.data(true)); // true means online
final typingProvider =
    Provider.family<Map<String, bool>, String>((ref, chatId) => const {"123": true}); // true means typing

// The Main Widget 
class UserChatProfile extends StatelessWidget {
  const UserChatProfile({super.key, required this.widget});
  final ChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final statusAsync = ref.watch(userStatusProvider(widget.otherUser.uid));
        final typingStatus = ref.watch(typingProvider(widget.chatId));
        final isOtherUserTyping = typingStatus[widget.otherUser.uid] ?? false;

        return statusAsync.when(
          data: (isOnLine) => Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.otherUser.photoURL != null
                    ? NetworkImage(widget.otherUser.photoURL!)
                    : null,
                child: widget.otherUser.photoURL == null
                    ? Text(
                        widget.otherUser.name.isNotEmpty
                            ? widget.otherUser.name[0].toUpperCase()
                            : "U",
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUser.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    
                    // The main logic for status display
                    if (isOtherUserTyping)
                      // If typing, show "Typing" text and the ThreeDots animation
                      Row(
                        children: [
                          const Text(
                            "Typing",
                            style: TextStyle(
                              color: Color.fromARGB(255, 30, 136, 229), // A nice blue color
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Placeholder for the ThreeDots widget
                          // Replace ThreeDots() with the actual widget if imported
                          // ThreeDots(), 
                          Container(width: 15, height: 5, color: Colors.transparent), // Placeholder 
                        ],
                      )
                    else if (isOnLine)
                      // If not typing but online, show "Online" status
                      Text(
                        "Online",
                        style: TextStyle(fontSize: 12, color: Colors.green[600]),
                      )
                    else
                      // If not online, show nothing or a 'Last seen' status
                      Container(), // Or another Text widget for "Offline" / "Last seen"
                  ],
                ),
              ),
            ],
          ),
          loading: () => Text(widget.otherUser.name),
          error: (_, __) => Text(widget.otherUser.name),
        );
      },
    );
  }
}
// For the final implementation, you must include the actual ThreeDots widget 

