import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatUserReplyScreen extends StatefulWidget {
  const ChatUserReplyScreen({super.key});

  @override
  State<ChatUserReplyScreen> createState() => _ChatUserReplyScreenState();
}

class _ChatUserReplyScreenState extends State<ChatUserReplyScreen> {
  String? _selectedUserId;
  String? _selectedUserEmail;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendReply() async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty || _selectedUserId == null) return;

    final docRef =
    FirebaseFirestore.instance.collection('chats').doc(_selectedUserId);

    final messageEntry = {
      'text': replyText,
      'createdAt': Timestamp.now(),
    };

    await docRef.update({
      'messages': FieldValue.arrayUnion([messageEntry])
    });

    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT: Chat user list
          Container(
            width: 300,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'チャット一覧',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final users = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final doc = users[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final userId = data['userId'];
                          final email = data['email'] ?? '';
                          final messages = data['messages'] as List<dynamic>?;

                          final lastMessage = (messages != null && messages.isNotEmpty)
                              ? messages.last['text']
                              : '(no message)';

                          return ListTile(
                            selected: _selectedUserId == userId,
                            title: Text(email),
                            subtitle: Text(lastMessage,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              setState(() {
                                _selectedUserId = userId;
                                _selectedUserEmail = email;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // RIGHT: Message view and reply
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(_selectedUserEmail ?? 'ユーザーを選択してください',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: _selectedUserId == null
                      ? const Center(child: Text('チャットを表示するにはユーザーを選択してください'))
                      : StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(_selectedUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('メッセージがありません'));
                      }

                      final data =
                      snapshot.data!.data() as Map<String, dynamic>;
                      final List messages = data['messages'] ?? [];

                      messages.sort((a, b) =>
                          (a['createdAt'] as Timestamp).compareTo(
                              b['createdAt'] as Timestamp));

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final text = msg['text'] ?? '';
                          final time = msg['createdAt'] as Timestamp?;
                          final timeStr = time != null
                              ? '${time.toDate().hour}:${time.toDate().minute.toString().padLeft(2, '0')}'
                              : '';

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(text),
                                  Text(timeStr,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Input
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: const InputDecoration(
                              hintText: '返信を入力...', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                        _selectedUserId == null ? null : _sendReply,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: const Text('送信'),
                      ),
                    ],
                  ),
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
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
