import 'package:chatapp/chat/provider/provider.dart';
import 'package:chatapp/chat/service/chat_service.dart';
import 'package:chatapp/chat/widgets/message_and_images_display.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/chat/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel otherUser;
  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _isTextFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isUploadingImage = false;
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;
  bool _isTextFieldFocused = false;
  Timer? _typingDebounceTimer;
  Timer? _readStatusTimer;
  List<String> _unreadMessageIds = [];

  @override
  void initState() {
    super.initState();
    
    // Set user online when entering chat
    ref.read(chatServiceProvider).updateUserOnlineStatus(true);

    // Add focus listener
    _isTextFieldFocusNode.addListener(() {
      if (_isTextFieldFocusNode.hasFocus) {
        _handleTextFieldFocus();
      } else {
        _handleTextFieldUnfocus();
      }
    });

    // Message read handler
    _readStatusTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final chatService = ref.read(chatServiceProvider);
      await chatService.markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _readStatusTimer?.cancel();
    _typingTimer?.cancel();
    _typingDebounceTimer?.cancel();
    _isTextFieldFocusNode.dispose();
    
    if (_isCurrentlyTyping) {
      ref.read(chatServiceProvider).setTyping(widget.chatId, false);
    }
    
    super.dispose();
  }

  // ---------- Typing Indicator Handlers ----------
  void _handleTextChange(String text) {
    // cancel previous timer
    _typingDebounceTimer?.cancel();

    if (text.trim().isNotEmpty && _isTextFieldFocused) {
      if (!_isCurrentlyTyping) {
        _handleTypingStart();
      }

      // set timer to stop typing after 2 seconds of inactivity
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        _handleTypingStop();
      });
    } else {
      _handleTypingStop();
    }
  }

  void _handleTypingStart() {
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      ref.read(chatServiceProvider).setTyping(widget.chatId, true);
    }
  }

  void _handleTypingStop() {
    if (_isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      ref.read(chatServiceProvider).setTyping(widget.chatId, false);
    }
    _typingTimer?.cancel();
  }

  void _handleTextFieldFocus() {
    _isTextFieldFocused = true;

    // start typing indicator if there's already text
    if (_messageController.text.trim().isNotEmpty) {
      _handleTypingStart();
    }
  }

  void _handleTextFieldUnfocus() {
    _isTextFieldFocused = false;
    _handleTypingStop();
  }

  // ---------- End Typing Indicator ----------

  // Send text message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    _handleTypingStop(); // stop the indicator after message send

    final chatService = ref.read(chatServiceProvider);
    final result = await chatService.sendTextMessage(
      chatId: widget.chatId,
      message: message,
      receiverId: widget.otherUser.uid,
    );

    if (result != "success" && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $result'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Show image options
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Pick image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxHeight: 1920,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploadingImage = true;
        });

        final chatService = ref.read(chatServiceProvider);
        final result = await chatService.sendImageMessage(
          chatId: widget.chatId,
          imagePath: image.path,
          receiverId: widget.otherUser.uid,
          caption: _messageController.text.trim().isEmpty 
              ? null 
              : _messageController.text.trim(),
        );

        _messageController.clear();
        _handleTypingStop();

        setState(() {
          _isUploadingImage = false;
        });

        if (result != "success" && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $result')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = ref.read(chatServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.otherUser.photoURL != null
                      ? NetworkImage(widget.otherUser.photoURL!)
                      : null,
                  child: widget.otherUser.photoURL == null
                      ? Text(
                          widget.otherUser.name.isNotEmpty
                              ? widget.otherUser.name[0].toUpperCase()
                              : "U",
                          style: const TextStyle(fontSize: 16),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.otherUser.isOnline 
                          ? Colors.green 
                          : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<bool>(
                stream: chatService.getTypingStatus(widget.chatId, widget.otherUser.uid),
                builder: (context, typingSnapshot) {
                  final isOtherUserTyping = typingSnapshot.data ?? false;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.otherUser.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isOtherUserTyping
                            ? const Row(
                                key: ValueKey('typing'),
                                children: [
                                  Text(
                                    'typing',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  TypingIndicatorDots(),
                                ],
                              )
                            : Text(
                                key: const ValueKey('status'),
                                widget.otherUser.isOnline ? "Online" : "Offline",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                final hasUnreadMessages = messages.any(
                  (msg) => msg.senderId != currentUserId && 
                           !(msg.readBy?.contains(currentUserId) ?? false),
                );

                if (hasUnreadMessages) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    chatService.markMessagesAsRead(widget.chatId);
                  });
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return MessageAndImageDisplay(
                      isMe: isMe,
                      widget: widget,
                      message: message,
                    );
                  },
                );
              },
            ),
          ),

          if (_isUploadingImage)
            Container(
              padding: const EdgeInsets.all(8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Uploading image...', 
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isUploadingImage ? null : _showImageOptions,
                  icon: Icon(
                    Icons.image,
                    size: 30,
                    color: _isUploadingImage ? Colors.grey : Colors.blueAccent,
                  ),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        _handleTextFieldFocus();
                      } else {
                        _handleTextFieldUnfocus();
                      }
                    },
                    child: TextField(
                      controller: _messageController,
                      focusNode: _isTextFieldFocusNode,
                      decoration: InputDecoration(
                        hintText: "Text a message...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onChanged: _handleTextChange,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isUploadingImage ? null : _sendMessage,
                  mini: true,
                  elevation: 0,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.send,
                    color: _isUploadingImage ? Colors.grey : Colors.blueAccent,
                    size: 27,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated typing indicator dots widget
class TypingIndicatorDots extends StatefulWidget {
  const TypingIndicatorDots({super.key});

  @override
  State<TypingIndicatorDots> createState() => _TypingIndicatorDotsState();
}

class _TypingIndicatorDotsState extends State<TypingIndicatorDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final opacity = (((_controller.value + delay) % 1.0) * 2 - 1).abs();
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: 0.3 + (opacity * 0.7),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
