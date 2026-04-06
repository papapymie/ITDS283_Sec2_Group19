import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _reviewController = TextEditingController();
  int _selectedStars = 0;
  bool _submitting = false;

  Future<void> _submitReview() async {
  // 1. ตรวจสอบข้อมูลเบื้องต้น
  if (_reviewController.text.trim().isEmpty || _selectedStars == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('กรุณาใส่รีวิวและเลือกดาวด้วยนะ')),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนรีวิว')),
    );
    return;
  }

  FocusScope.of(context).unfocus();
  setState(() => _submitting = true);

  String finalName = 'Anonymous';
  try {
    // ดึงชื่อจาก Firestore users
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data()?['name'] != null) {
      finalName = userDoc.data()!['name'];
    } else {
      // ถ้าไม่มีใน Firestore ให้ใช้จาก Auth Profile
      finalName = user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';
    }

    // บันทึกลงคอลเลกชัน reviews
    await FirebaseFirestore.instance.collection('reviews').add({
      'user_id': user.uid,
      'name': finalName,
      'stars': _selectedStars,
      'text': _reviewController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });

    // สำเร็จแล้วล้างค่า
    _reviewController.clear();
    setState(() {
      _selectedStars = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ส่งรีวิวเรียบร้อยแล้ว ขอบคุณครับ!')),
    );

  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
    );
  } finally {
    // ไม่ว่าจะสำเร็จหรือพลาด ให้ปิดสถานะ Loading
    if (mounted) setState(() => _submitting = false);
  }
}

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- จุดที่ 3: ครอบ GestureDetector เพื่อให้แตะที่ว่างแล้วคีย์บอร์ดหุบ ---
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FAF4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A9E82),
          foregroundColor: Colors.white,
          title: const Text(
            'User Reviews',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Write a Review card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 36, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WRITE A REVIEW',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xFF1A3A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'เขียนรีวิวของคุณที่นี่...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStars = i + 1),
                        child: Icon(
                          i < _selectedStars ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A9E82),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'USER REVIEWS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFF1A3A2E),
              ),
            ),
            const SizedBox(height: 14),

            // ดึง reviews จาก Firestore realtime
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('ยังไม่มีรีวิว', style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildReviewCard(data);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      )
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review['name'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF1A3A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < (review['stars'] ?? 0) ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review['text'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}