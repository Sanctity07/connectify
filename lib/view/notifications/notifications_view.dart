// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final String? _uid;
  late Future<List<QueryDocumentSnapshot>> _notifFuture;

  @override
  void initState() {
    super.initState();
    _uid = AuthServices().currentUser?.uid;
    _load();
  }

  void _load() {
    if (_uid == null) {
      _notifFuture = Future.value([]);
      return;
    }
    _notifFuture = _fetchNotifications();
  }

  Future<List<QueryDocumentSnapshot>> _fetchNotifications() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _uid)
          .get(const GetOptions(source: Source.serverAndCache));

      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final aTs =
            (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTs =
            (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTs.compareTo(aTs);
      });
      return docs.take(50).toList();
    } catch (e) {
      debugPrint('[NotificationsView] fetch error: $e');
      // Return empty list so the UI shows "No notifications yet"
      return [];
    }
  }

  Future<void> _refresh() async {
    setState(() => _load());
  }

  Future<void> _markAllRead() async {
    if (_uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _uid)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      _refresh();
    } catch (e) {
      debugPrint('[NotificationsView] markAllRead error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Urbanist',
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.deepPurple, fontSize: 12),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.deepPurple,
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _notifFuture,
          builder: (context, snap) {
            // Loading
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error
            if (snap.hasError) {
              final errMsg = snap.error.toString();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load notifications',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errMsg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final docs = snap.data ?? [];

            // Empty state
            if (docs.isEmpty) {
              return ListView(
                // Wrap in ListView so RefreshIndicator works on empty state
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "You're all caught up!",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'No notifications yet.\nPull down to refresh.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                final isRead = data['read'] as bool? ?? false;
                final title = data['title'] as String? ?? '';
                final body = data['body'] as String? ?? '';
                final type = data['type'] as String? ?? 'general';
                final createdAt =
                    (data['createdAt'] as Timestamp?)?.toDate();
                final timeStr =
                    createdAt != null ? _formatTime(createdAt) : '';

                return GestureDetector(
                  onTap: () async {
                    if (!isRead) {
                      await docs[i].reference.update({'read': true});
                      _refresh();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          : Colors.deepPurple.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: isRead
                          ? null
                          : Border.all(
                              color: Colors.deepPurple.withOpacity(0.2),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon circle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _notifColor(type).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _notifIcon(type),
                            color: _notifColor(type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              if (body.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  body,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              if (timeStr.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _notifIcon(String type) => switch (type) {
        'booking_new' => Icons.book_online_rounded,
        'booking_accepted' => Icons.check_circle_outline,
        'booking_declined' => Icons.cancel_outlined,
        'booking_started' => Icons.play_circle_outline,
        'booking_completed' => Icons.done_all,
        'booking_cancelled' => Icons.cancel_outlined,
        'message' => Icons.chat_bubble_outline,
        'rating' => Icons.star_outline,
        _ => Icons.notifications_outlined,
      };

  Color _notifColor(String type) => switch (type) {
        'booking_new' => Colors.deepPurple,
        'booking_accepted' => Colors.green,
        'booking_declined' => Colors.red,
        'booking_started' => Colors.orange,
        'booking_completed' => Colors.blue,
        'booking_cancelled' => Colors.red,
        'message' => Colors.teal,
        'rating' => Colors.amber,
        _ => Colors.grey,
      };

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
