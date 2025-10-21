import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatapp/chat/service/chat_service.dart';
import 'package:chatapp/chat/model/user_model.dart';
import 'package:chatapp/chat/model/message_request_model.dart';

// -------------------------AUTH STATE-------------------------
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// -------------------------CHAT SERVICE-------------------------
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// -------------------------USERS-------------------------
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<UserModel>>? _subscription;

  UsersNotifier(this._chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getAllUsers().listen(
      (users) => state = AsyncValue.data(users),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return UsersNotifier(service);
});

// -------------------------MESSAGE REQUESTS-------------------------
class RequestsNotifier
    extends StateNotifier<AsyncValue<List<MessageRequestModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<MessageRequestModel>>? _subscription;

  RequestsNotifier(this._chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getPendingRequests().listen(
      (requests) => state = AsyncValue.data(requests),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    await _chatService.acceptMessageRequest(requestId, senderId);
    _init();
  }

  Future<void> rejectRequest(String requestId) async {
    await _chatService.rejectMessageRequest(requestId);
    _init();
  }

  void refresh() => _init();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier,
    AsyncValue<List<MessageRequestModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return RequestsNotifier(service);
});

// -------------------------AUTO REFRESH ON AUTH CHANGE-------------------------
final autoRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
    next.whenData((user) {
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(usersProvider);
          ref.invalidate(requestsProvider);
        });
      }
    });
  });
});
