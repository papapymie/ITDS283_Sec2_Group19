import 'dart:convert';
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

  String _currentUserName = 'Anonymous';
  String? _currentUserPhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _currentUserName = userDoc.data()?['name'] ?? 'Anonymous';
          // ตรวจสอบชื่อฟิลด์ให้ตรงกับที่เก็บในหน้า Profile (เช่น 'profile_image' หรือ 'photo_data')
          _currentUserPhotoBase64 = userDoc.data()?['profile_image'] ?? userDoc.data()?['photo_data'];
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty || _selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่รีวิวและเลือกดาวด้วยนะ')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'user_id': user.uid,
        'name': _currentUserName,
        'photo_data': _currentUserPhotoBase64, // บันทึกรูป Base64 ลงในรีวิว
        'stars': _selectedStars,
        'text': _reviewController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      _reviewController.clear();
      setState(() {
        _selectedStars = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งรีวิวเรียบร้อยแล้ว ขอบคุณครับ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
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
              // ส่วน WRITE A REVIEW
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        image: (_currentUserPhotoBase64 != null && _currentUserPhotoBase64!.isNotEmpty)
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(_currentUserPhotoBase64!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (_currentUserPhotoBase64 == null || _currentUserPhotoBase64!.isEmpty)
                          ? const Icon(Icons.person, size: 36, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    const Text('WRITE A REVIEW', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    // ... TextField และปุ่ม Submit เหมือนเดิม ...
                    TextField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'เขียนรีวิวของคุณที่นี่...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => GestureDetector(
                        onTap: () => setState(() => _selectedStars = i + 1),
                        child: Icon(
                          i < _selectedStars ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107), size: 32,
                        ),
                      )),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A9E82)),
                      child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SUBMIT', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('USER REVIEWS', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              // ดึงรายการรีวิวแบบ Realtime
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
      ),
    );
  }

  // --- จุดสำคัญ: ฟังก์ชันสร้างการ์ดรีวิวที่ดึงรูปมาแสดง ---
  Widget _buildReviewCard(Map<String, dynamic> review) {
    final String? photoData = review['photo_data']; // ดึง Base64 จาก Database ของรีวิวนั้นๆ

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(16),
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
              // ✅ ตรวจสอบและแสดงผลรูปภาพจาก Database
              image: (photoData != null && photoData.isNotEmpty)
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(photoData)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // ✅ ถ้าไม่มีข้อมูลรูปภาพ ให้แสดงไอคอนสีเทาแทน
            child: (photoData == null || photoData.isEmpty)
                ? const Icon(Icons.person, color: Colors.grey, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.w800)),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < (review['stars'] ?? 0) ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107), size: 16,
                  )),
                ),
                const SizedBox(height: 4),
                Text(review['text'] ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}