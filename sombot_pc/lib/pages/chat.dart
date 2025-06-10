import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || user == null) return;

    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(user.uid);

    final messageEntry = {
      'text': messageText,
      'createdAt': Timestamp.now(),
      'senderId': user.uid, // ✅ Track who sent it
    };

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(chatDoc);
      if (snapshot.exists) {
        transaction.update(chatDoc, {
          'messages': FieldValue.arrayUnion([messageEntry])
        });
      } else {
        transaction.set(chatDoc, {
          'userId': user.uid,
          'email': user.email,
          'messages': [messageEntry],
        });
      }
    });

    _messageController.clear();

    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: user == null
                ? const Center(child: Text('Not logged in'))
                : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No messages yet.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List messages = data['messages'] ?? [];

                messages.sort((a, b) =>
                    (a['createdAt'] as Timestamp).compareTo(b['createdAt'] as Timestamp));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == user.uid;
                    final text = msg['text'] ?? '';

                    return ListTile(
                      title: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.black : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      subtitle: isMe
                          ? null
                          : const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'From Admin',
                          style: TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                    const InputDecoration(hintText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
