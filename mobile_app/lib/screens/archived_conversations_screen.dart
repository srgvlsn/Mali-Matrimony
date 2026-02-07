import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'package:shared/shared.dart';
import 'chat_detail_screen.dart';

class ArchivedConversationsScreen extends StatelessWidget {
  const ArchivedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Conversations'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          final archivedConversations = chatService.archivedConversations;

          if (archivedConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No archived conversations',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedConversations.length,
            itemBuilder: (context, index) {
              final conv = archivedConversations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      ApiService.instance.resolveUrl(
                        conv.otherUserPhoto ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                  ),
                  title: Text(
                    conv.otherUserName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (conv.isBlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: const Text(
                            'Blocked',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!conv.isBlocked) ...[
                        Expanded(
                          child: Text(
                            conv.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      if (conv.isBlocked) {
                        chatService.unblockConversation(conv.otherUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unblocked ${conv.otherUserName}'),
                          ),
                        );
                      } else {
                        chatService.unarchiveConversation(conv.otherUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unarchived ${conv.otherUserName}'),
                          ),
                        );
                      }
                    },
                    child: Text(conv.isBlocked ? 'Unblock' : 'Unarchive'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(conversation: conv),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
