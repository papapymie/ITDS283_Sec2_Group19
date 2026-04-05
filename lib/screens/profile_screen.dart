import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> profileData = {};
  bool _loading = true;
  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    // ปิดการเชื่อมต่อเมื่อออกจากหน้าเพื่อประหยัดทรัพยากร
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // ใช้ snapshots() เพื่อดึงข้อมูล Real-time (ดึงจาก Cache ก่อนแล้วตามด้วย Server)
    _profileSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          profileData = Map<String, String>.from(
            snapshot.data()!.map((k, v) => MapEntry(k, v.toString())),
          );
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    }, onError: (error) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7EC8A4), Color(0xFF5BB89A), Color(0xFF3A9E82)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // AppBar (Back Button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PROFILE',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(Icons.person, size: 50, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildLabel('ชื่อ - นามสกุล'),
                            _buildReadField(profileData['name'] ?? ''),

                            _buildLabel('เบอร์โทรศัพท์'),
                            _buildReadField(profileData['phone'] ?? ''),

                            Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('บ้านเลขที่'),
                                _buildReadField(profileData['houseNo'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('หมู่'),
                                _buildReadField(profileData['moo'] ?? ''),
                              ])),
                            ]),

                            Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('หมู่บ้าน'),
                                _buildReadField(profileData['village'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              SizedBox(width: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('ห้อง'),
                                _buildReadField(profileData['room'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              SizedBox(width: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('ชั้น'),
                                _buildReadField(profileData['floor'] ?? ''),
                              ])),
                            ]),

                            Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('ซอย'),
                                _buildReadField(profileData['soi'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('ถนน'),
                                _buildReadField(profileData['road'] ?? ''),
                              ])),
                            ]),

                            Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('จังหวัด'),
                                _buildReadField(profileData['province'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('อำเภอ'),
                                _buildReadField(profileData['district'] ?? ''),
                              ])),
                            ]),

                            Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('ตำบล'),
                                _buildReadField(profileData['subdistrict'] ?? ''),
                              ])),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _buildLabel('รหัสไปรษณีย์'),
                                _buildReadField(profileData['postcode'] ?? ''),
                              ])),
                            ]),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // ปุ่มแก้ไขโปรไฟล์
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(profileData: profileData),
                            ),
                          );
                          // ไม่ต้องดักรอค่า return เพราะ snapshots() จะอัปเดต UI ให้อัตโนมัติครับ
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF87),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF87).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.manage_accounts, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildReadField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value.isEmpty ? '-' : value,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A2E)),
      ),
    );
  }
}