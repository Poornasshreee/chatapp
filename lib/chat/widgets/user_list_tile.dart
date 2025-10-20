import 'package:chatapp/chat/model/user_model.dart';
import 'package:chatapp/chat/provider/user_list_provider.dart';
import 'package:chatapp/chat/screens/chatscreen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatapp/chat/model/user_list_model.dart';

enum SnackbarType { success, error, info }

void showAppSnackbar({
  required BuildContext context,
  required SnackbarType type,
  required String description,
}) {
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackbarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackbarType.info:
      backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(description)),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

class UserListTile extends ConsumerWidget {
  final UserModel user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userListProvider(user.uid));
    final notifier = ref.read(userListProvider(user.uid).notifier);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
            ? NetworkImage(user.photoURL!)
            : null,
        child: user.photoURL == null || user.photoURL!.isEmpty
            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        user.isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: user.isOnline ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: _buildTrailingWidget(context, notifier, state),
    );
  }

  Widget _buildTrailingWidget(
    BuildContext context,
    UserListNotifier notifier,
    UserListTileState state,
  ) {
    if (state.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state.areFriends) {
      return MaterialButton(
        color: Colors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () => _navigateToChat(context),
        child: _buttonName(Icons.chat, "Chat"),
      );
    }

    if (state.requestStatus == "pending") {
      if (state.isRequestSender) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: null,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_actions, color: Colors.black54, size: 20),
              SizedBox(width: 4),
              Text("Pending", style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        );
      }

      return MaterialButton(
        color: Colors.orange,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () async {
          final result = await notifier.acceptRequest();
          if (result == "success" && context.mounted) {
            showAppSnackbar(
              context: context,
              type: SnackbarType.success,
              description: "Request Accepted!",
            );
          } else {
            if (context.mounted) {
              showAppSnackbar(
                context: context,
                type: SnackbarType.error,
                description: "Failed: $result",
              );
            }
          }
        },
        child: _buttonName(Icons.done, "Accept"),
      );
    }

    return MaterialButton(
      color: Colors.blueAccent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        final result = await notifier.sendRequest(user.name, user.email);
        if (result == "success" && context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.success,
            description: "Friend request sent!",
          );
        } else {
          if (context.mounted) {
            showAppSnackbar(
              context: context,
              type: SnackbarType.error,
              description: result ?? "Failed to send request",
            );
          }
        }
      },
      child: _buttonName(Icons.person_add, "Add Friend"),
    );
  }

  Widget _buttonName(IconData icon, String name) {
    return SizedBox(
      width: 100,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToChat(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = _generateChatID(currentUserId, user.uid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, otherUser: user),
      ),
    );
  }

  String _generateChatID(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
