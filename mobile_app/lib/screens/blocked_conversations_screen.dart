import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'package:shared/shared.dart';

class BlockedConversationsScreen extends StatelessWidget {
  const BlockedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Conversations'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          final blockedConversations = chatService.blockedConversations;

          if (blockedConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No blocked conversations',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blockedConversations.length,
            itemBuilder: (context, index) {
              final conv = blockedConversations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 40,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Blocked'),
                  trailing: TextButton(
                    onPressed: () {
                      chatService.unblockConversation(conv.otherUserId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unblocked ${conv.otherUserName}'),
                        ),
                      );
                    },
                    child: const Text('Unblock'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
