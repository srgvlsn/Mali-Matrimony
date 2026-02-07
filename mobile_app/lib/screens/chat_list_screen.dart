import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatService>(
      builder: (context, chatService, child) {
        final conversations = chatService.conversations;

        if (chatService.isLoading && conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return _buildConversationTile(context, conv);
          },
        );
      },
    );
  }

  Widget _buildConversationTile(BuildContext context, Conversation conv) {
    final chatService = context.watch<ChatService>();
    final isSelected = chatService.selectedConversationIds.contains(
      conv.otherUserId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        side: isSelected
            ? const BorderSide(color: AppStyles.primary, width: 2)
            : BorderSide.none,
      ),
      color: isSelected
          ? AppStyles.primary.withValues(alpha: 0.05)
          : Colors.white,
      elevation: isSelected ? 0 : 2,
      child: GestureDetector(
        onLongPress: () {
          chatService.toggleSelection(conv.otherUserId);
        },
        child: InkWell(
          onTap: () {
            if (chatService.isSelectionMode) {
              chatService.toggleSelection(conv.otherUserId);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(conversation: conv),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        ApiService.instance.resolveUrl(
                          conv.otherUserPhoto ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppStyles.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conv.otherUserName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppStyles.primary,
                            ),
                          ),
                          Text(
                            _formatTime(conv.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (conv.lastMessage.isNotEmpty) ...[
                            Transform.rotate(
                              angle: conv.isLastMessageMe
                                  ? -0.698132 // -40° (diagonal up-right for outgoing)
                                  : 2.26893, // 130° (diagonal down-left for incoming)
                              child: Icon(
                                Icons.send_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: conv.lastMessage.contains("You matched!")
                                    ? Theme.of(context).primaryColor
                                    : (conv.unreadCount > 0
                                          ? Colors.black87
                                          : Colors.grey[600]),
                                fontWeight:
                                    (conv.unreadCount > 0 ||
                                        conv.lastMessage.contains(
                                          "You matched!",
                                        ))
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontStyle:
                                    conv.lastMessage.contains("You matched!")
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppStyles.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;

    if (messageDate == today) {
      // Show time if today (respecting device format)
      if (use24HourFormat) {
        final hour = time.hour.toString().padLeft(2, '0');
        final minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else {
        final hour = time.hour > 12
            ? time.hour - 12
            : (time.hour == 0 ? 12 : time.hour);
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $period';
      }
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Indian date format: "14 Feb" or "14 Feb 2026" (if different year)
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthName = monthNames[time.month - 1];
      return time.year != now.year
          ? '${time.day} $monthName ${time.year}'
          : '${time.day} $monthName';
    }
  }
}
