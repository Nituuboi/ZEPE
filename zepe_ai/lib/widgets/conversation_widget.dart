import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zepe_brain_provider.dart';

class ConversationWidget extends StatelessWidget {
  const ConversationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ZepeBrainProvider>(
      builder: (context, brainProvider, child) {
        if (brainProvider.conversationHistory.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Conversation',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (brainProvider.isProcessing)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Conversation List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: brainProvider.conversationHistory.length,
                  itemBuilder: (context, index) {
                    String message = brainProvider.conversationHistory[index];
                    bool isUser = message.startsWith('User:');
                    String content = message.substring(message.indexOf(':') + 1).trim();
                    
                    return _buildMessageBubble(
                      context: context,
                      content: content,
                      isUser: isUser,
                      timestamp: _getTimestamp(index, brainProvider.conversationHistory.length),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversation yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start talking to ZEPE to see your conversation here',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required String content,
    required bool isUser,
    required String timestamp,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // ZEPE Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF8B7CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Z',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF6C63FF).withOpacity(0.8)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser 
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTimestamp(int index, int totalMessages) {
    // Simple timestamp logic - in a real app, you'd store actual timestamps
    DateTime now = DateTime.now();
    DateTime messageTime = now.subtract(Duration(minutes: totalMessages - index - 1));
    
    int hour = messageTime.hour;
    int minute = messageTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }
}