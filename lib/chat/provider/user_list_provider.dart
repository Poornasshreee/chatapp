import 'package:chatapp/chat/model/user_list_model.dart';
import 'package:chatapp/chat/provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListNotifier extends StateNotifier<UserListTileState> {
  final Ref ref;
  final String userId;

  UserListNotifier(this.ref, this.userId) : super(UserListTileState()) {
    _checkRelationship();
  }

  Future<void> _checkRelationship() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) return;

      final friends = await chatService.areUsersFriends(currentUserId, userId);

      if (friends) {
        state = state.copyWith(
          areFriends: true,
          requestStatus: null,
          isRequestSender: false,
          pendingRequestId: null,
        );
        return;
      }

      final sentRequestId = '${currentUserId}_$userId';
      final receiverRequestId = '${userId}_$currentUserId';

      final sendRequestDoc = await FirebaseFirestore.instance
          .collection("messageRequests")
          .doc(sentRequestId)
          .get();

      final receiverRequestDoc = await FirebaseFirestore.instance
          .collection("messageRequests")
          .doc(receiverRequestId)
          .get();

      String? finalStatus;
      bool isSender = false;
      String? requestId;

      if (sendRequestDoc.exists) {
        final sentStatus = sendRequestDoc['status'] ?? '';
        if (sentStatus == 'pending') {
          finalStatus = 'pending';
          isSender = true;
          requestId = sentRequestId;
        }
      }

      if (receiverRequestDoc.exists && finalStatus == null) {
        final receivedStatus = receiverRequestDoc['status'] ?? '';
        if (receivedStatus == 'pending') {
          finalStatus = 'pending';
          isSender = false;
          requestId = receiverRequestId;
        }
      }

      state = state.copyWith(
        areFriends: false,
        requestStatus: finalStatus,
        isRequestSender: isSender,
        pendingRequestId: requestId,
      );
    } catch (e) {
      print('Error checking relationship: $e');
    }
  }

  Future<String?> sendRequest(String userName, String userEmail) async {
    state = state.copyWith(isLoading: true);

    try {
      final chatService = ref.read(chatServiceProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId == null) {
        state = state.copyWith(isLoading: false);
        return 'User not authenticated';
      }

      final result = await chatService.sendMessageRequest(userId);

      if (result != null && result != 'Request already sent') {
        state = state.copyWith(
          isLoading: false,
          requestStatus: 'pending',
          isRequestSender: true,
          pendingRequestId: '${currentUserId}_$userId',
        );
        return 'success';
      } else {
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Error: $e';
    }
  }

  Future<String?> acceptRequest() async {
    if (state.pendingRequestId == null) return 'no-request';

    state = state.copyWith(isLoading: true);

    try {
      final chatService = ref.read(chatServiceProvider);

      final result = await chatService.acceptMessageRequest(
        state.pendingRequestId!,
        userId,
      );

      if (result == 'success') {
        state = state.copyWith(
          isLoading: false,
          areFriends: true,
          requestStatus: null,
          isRequestSender: false,
          pendingRequestId: null,
        );
        ref.invalidate(requestsProvider);
      } else {
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'Error: $e';
    }
  }
}

final userListProvider = StateNotifierProvider.family<
    UserListNotifier,
    UserListTileState,
    String>((ref, userId) {
  return UserListNotifier(ref, userId);
});