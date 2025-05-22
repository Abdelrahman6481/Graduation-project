import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatAI extends StatefulWidget {
  final String? studentId;

  const ChatAI({super.key, this.studentId});

  @override
  State<ChatAI> createState() => _ChatAIState();
}

class _ChatAIState extends State<ChatAI> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (widget.studentId == null) return;

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('chatHistory')
              .where('studentId', isEqualTo: widget.studentId)
              .orderBy('timestamp', descending: true)
              .limit(50)
              .get();

      setState(() {
        _messages.clear();
        for (var doc in snapshot.docs) {
          _messages.add(doc.data() as Map<String, dynamic>);
        }
        _messages.sort(
          (a, b) => (a['timestamp'] as Timestamp).compareTo(
            b['timestamp'] as Timestamp,
          ),
        );
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading chat history: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });
      _isLoading = true;
    });

    try {
      // Simulate AI response
      await Future.delayed(const Duration(seconds: 1));
      final aiResponse = "This is a simulated AI response to: $message";

      setState(() {
        _messages.add({
          'text': aiResponse,
          'isUser': false,
          'timestamp': Timestamp.now(),
        });
        _isLoading = false;
      });

      // Save to Firestore
      if (widget.studentId != null) {
        await FirebaseFirestore.instance.collection('chatHistory').add({
          'studentId': widget.studentId,
          'text': message,
          'isUser': true,
          'timestamp': Timestamp.now(),
        });

        await FirebaseFirestore.instance.collection('chatHistory').add({
          'studentId': widget.studentId,
          'text': aiResponse,
          'isUser': false,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending message: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.red.shade200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a conversation with AI',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'AI is typing...',
                    style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.red.shade200),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.red.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.smart_toy_outlined, color: Colors.red.shade900),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.red.shade900 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : null,
                  bottomLeft: !isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Text(
                message['text'] as String,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.red.shade900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.person_outline, color: Colors.red.shade900),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
