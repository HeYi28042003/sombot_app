import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
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

    final chatDoc =
        FirebaseFirestore.instance.collection('chats').doc(user.uid);
    final messageEntry = {
      'text': messageText,
      'createdAt': Timestamp.now(),
      'senderId': user.uid,
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
    _scrollToBottom();
  }

  Future<void> _sendImageMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final chatDoc =
        FirebaseFirestore.instance.collection('chats').doc(user.uid);
    final messageEntry = {
      'image': base64Image,
      'createdAt': Timestamp.now(),
      'senderId': user.uid,
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

    _scrollToBottom();
  }

  void _scrollToBottom() {
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

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;

    return Scaffold(
      // appBar: AppBar(title: const Text('Chat')),
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                          child: Text('No messages yet.'),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final List messages = data['messages'] ?? [];

                      messages.sort((a, b) => (a['createdAt'] as Timestamp)
                          .compareTo(b['createdAt'] as Timestamp));

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['senderId'] == user.uid;
                          final text = msg['text'];
                          final image = msg['image'];

                          return ListTile(
                            title: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  // color: isMe
                                  //     ? Colors.blue[100]
                                  //     : Colors.orange[100],
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: image != null
                                    ? Image.memory(base64Decode(image),
                                        width: 200)
                                    : Text(
                                        text ?? '',
                                        style: TextStyle(
                                          color: theme.unselectedWidgetColor,
                                        ),
                                      ),
                              ),
                            ),
                            subtitle: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                isMe ? "You" : "From Admin",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  onPressed: _sendImageMessage,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.second2,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: AppColors.primary,
                      style: TextStyle(
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.second2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.second2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: AppColors.primary,
                    size: 27,
                  ),
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
