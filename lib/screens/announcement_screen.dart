import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  Future<void> _togglePin(String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(docId)
          .update({'isPinned': !currentStatus});
    } catch (e) {
      debugPrint("Error updating pin status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('ยังไม่มีประกาศ',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // เรียง isPinned ใน code แทน
                  final docs = snapshot.data!.docs
                      .map((doc) => MapEntry(doc.id, doc.data() as Map<String, dynamic>))
                      .toList()
                    ..sort((a, b) {
                      final aPin = a.value['isPinned'] as bool? ?? false;
                      final bPin = b.value['isPinned'] as bool? ?? false;
                      return (bPin ? 1 : 0) - (aPin ? 1 : 0);
                    });

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: docs.map((entry) => _buildCard(entry.key, entry.value)).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A3A2E), size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'ANNOUNCEMENT',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFF1A3A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String docId, Map<String, dynamic> item) {
    final isPinned = item['isPinned'] as bool? ?? false;
    final color = isPinned ? const Color(0xFF3A9E82) : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['date'] ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A3A2E),
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _togglePin(docId, isPinned),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPinned ? Icons.star : Icons.star_border,
                  color: color,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}