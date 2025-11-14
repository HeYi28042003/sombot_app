import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('notification');

  Stream<QuerySnapshot> get _notificationsStream =>
      _col.orderBy('createdAt', descending: true).snapshots();

  Future<void> _refresh() async {
    // For a stream-backed UI refresh can be a noop or re-query the collection
    await _col.get();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _markAllRead() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await _col.where('read', isEqualTo: false).get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    if (snapshot.docs.isNotEmpty) await batch.commit();
  }

  Future<void> _toggleReadDoc(String id, bool current) async {
    await _col.doc(id).update({'read': !current});
  }

  Future<void> _removeNotification(String id) async {
    await _col.doc(id).delete();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Pull down to refresh.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final n = AppNotification.fromDoc(doc);
                return Dismissible(
                  key: ValueKey(n.id),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeNotification(n.id),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              n.read ? Colors.blueGrey : Colors.blue,
                          child: Icon(
                            n.read
                                ? Icons.notifications
                                : Icons.notifications_active,
                            color: Colors.white,
                          ),
                        ),
                        if (!n.read)
                          const Positioned(
                            right: -2,
                            top: -2,
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight:
                            n.read ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(n.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    onTap: () async {
                      // mark read and show details
                      if (!n.read) await _toggleReadDoc(n.id, n.read);
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(n.title),
                          content: Text(n.body),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(n.read
                                    ? Icons.mark_email_read
                                    : Icons.mark_email_unread),
                                title:
                                    Text(n.read ? 'Mark unread' : 'Mark read'),
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _toggleReadDoc(n.id, n.read);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _removeNotification(n.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final created = data['createdAt'];
    DateTime dt;
    if (created is Timestamp) {
      dt = created.toDate();
    } else if (created is DateTime) {
      dt = created;
    } else {
      dt = DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      body: (data['des'] as String?) ?? '',
      createdAt: dt,
      read: (data['read'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'read': read,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
