import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:shared/shared.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_detail_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  // ... (rest of class)

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  Timer? _typingTimer;
  bool _isTyping = false;

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${widget.conversation.otherUserName}? You will no longer receive messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(context);

              // Block user
              context.read<ChatService>().blockConversation(
                widget.conversation.otherUserId,
              );

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.conversation.otherUserName} blocked.',
                  ),
                ),
              );

              // Exit chat screen as conversation is now blocked
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = context.read<ChatService>();
      chatService.activeChatUserId = widget.conversation.otherUserId;
      chatService.fetchMessages(widget.conversation.otherUserId);
    });
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Clear active chat user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Need a way to access chatService outside of context if possible,
      // but here we can try to use the stored reference or just clear it.
      // Actually, since we are in dispose, we should be careful with context.
    });
    // Let's use a more reliable way to clear it
    _clearActiveChat();
    _messageController.removeListener(_onTextChanged);
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearActiveChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatService.instance.activeChatUserId = null;
    });
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      context.read<ChatService>().sendTypingStatus(
        widget.conversation.otherUserId,
        true,
      );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatService>().sendTypingStatus(
          widget.conversation.otherUserId,
          false,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        await context.read<ChatService>().sendImageMessage(
          widget.conversation.otherUserId,
          File(image.path),
        );
        _scrollToBottom();
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatService>().sendMessage(
        widget.conversation.otherUserId,
        text,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  ChatMessage? _replyMessage;

  Offset _tapPosition = Offset.zero;

  void _showContextMenu(BuildContext context, ChatMessage msg) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final isOlderThan24Hours =
        DateTime.now().difference(msg.timestamp).inHours > 24;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        _tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem(
          onTap: () {
            setState(() {
              _replyMessage = msg;
            });
          },
          child: const Row(
            children: [
              Icon(Icons.reply_rounded, color: AppStyles.primary),
              SizedBox(width: 12),
              Text('Reply'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            Clipboard.setData(ClipboardData(text: msg.text));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Message copied')));
          },
          child: const Row(
            children: [
              Icon(Icons.copy_rounded, color: AppStyles.primary),
              SizedBox(width: 12),
              Text('Copy'),
            ],
          ),
        ),
        if (msg.isMe && !isOlderThan24Hours)
          PopupMenuItem(
            onTap: () {
              // Hack to allow menu to close before showing dialog
              Future.delayed(
                const Duration(seconds: 0),
                () => _checkAndUnsend(msg),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 12),
                Text('Unsend', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _checkAndUnsend(ChatMessage msg) async {
    final prefs = await SharedPreferences.getInstance();
    final skipConfirm = prefs.getBool('skip_unsend_confirm') ?? false;

    if (skipConfirm && mounted) {
      _performUnsend(msg);
    } else if (mounted) {
      _showUnsendConfirmDialog(msg);
    }
  }

  Future<void> _performUnsend(ChatMessage msg) async {
    final messenger = ScaffoldMessenger.of(context);
    final chatService = context.read<ChatService>();
    await chatService.unsendMessage(msg.id, widget.conversation.otherUserId);
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Message unsent')));
  }

  void _showUnsendConfirmDialog(ChatMessage msg) {
    bool dontAskAgain = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Unsend Message'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to unsend this message? It will be removed for everyone.',
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("Don't ask me again"),
                  value: dontAskAgain,
                  onChanged: (val) {
                    setDialogState(() {
                      dontAskAgain = val ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (dontAskAgain) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('skip_unsend_confirm', true);
                  }
                  if (mounted) _performUnsend(msg);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Unsend'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyles.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                ApiService.instance.resolveUrl(
                  widget.conversation.otherUserPhoto ??
                      'https://via.placeholder.com/150',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Consumer<ChatService>(
              builder: (context, chatService, child) {
                final isTyping = chatService.isUserTyping(
                  widget.conversation.otherUserId,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.otherUserName,
                      style: const TextStyle(
                        color: AppStyles.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isTyping)
                      const Text(
                        "Typing...",
                        style: TextStyle(
                          color: AppStyles.primary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'view_profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileDetailScreen(
                      userId: widget.conversation.otherUserId,
                    ),
                  ),
                );
              } else if (value == 'block') {
                _showBlockConfirmation(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppStyles.primary),
                    SizedBox(width: 8),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: AppStyles.primary),
          ),
        ],
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          final messages = chatService.getMessages(
            widget.conversation.otherUserId,
          );

          if (messages.isEmpty && chatService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final showDateSeparator =
                        index == 0 ||
                        !_isSameDay(
                          messages[index - 1].timestamp,
                          msg.timestamp,
                        );
                    final isLastMessage = index == messages.length - 1;
                    return Column(
                      children: [
                        if (showDateSeparator)
                          _buildDateSeparator(msg.timestamp),
                        _buildMessageBubble(msg, isLastMessage),
                      ],
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);
    final isOlderThanYear = now.difference(date).inDays > 365;

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      // Indian date format: "14 February 2026" or "14 February" (if same year)
      final monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final monthName = monthNames[date.month - 1];
      dateText = isOlderThanYear
          ? '${date.day} $monthName ${date.year}'
          : '${date.day} $monthName';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isLastMessage) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPressStart: (details) => _tapPosition = details.globalPosition,
        onLongPress: () => _showContextMenu(context, msg),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: msg.isMe ? AppStyles.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppStyles.radiusL),
                  topRight: const Radius.circular(AppStyles.radiusL),
                  bottomLeft: Radius.circular(msg.isMe ? AppStyles.radiusL : 0),
                  bottomRight: Radius.circular(
                    msg.isMe ? 0 : AppStyles.radiusL,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(msg),
            ),
            // Timestamp and read receipt below bubble
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTime(msg.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  if (msg.isMe && isLastMessage && msg.isRead) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.drafts_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg) {
    if (msg.attachmentUrl != null && msg.attachmentType == 'image') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiService.instance.resolveUrl(msg.attachmentUrl!),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          if (msg.text.isNotEmpty && msg.text != "Image") ...[
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ],
      );
    }
    return Text(
      msg.text,
      style: TextStyle(
        color: msg.isMe ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    // Use device's time format (24hr or 12hr)
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;

    if (use24HourFormat) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = timestamp.hour > 12
          ? timestamp.hour - 12
          : (timestamp.hour == 0 ? 12 : timestamp.hour);
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_replyMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(color: AppStyles.primary, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _replyMessage!.isMe
                                ? 'You'
                                : widget.conversation.otherUserName,
                            style: TextStyle(
                              color: AppStyles.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _replyMessage!.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _replyMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppStyles.radiusL),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        isDense: true,
                        prefixIcon: IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: AppStyles.primary,
                          ),
                          onPressed: _pickAndSendImage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppStyles.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
