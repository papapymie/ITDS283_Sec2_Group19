import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'timer_screen.dart';

class SidebarScreen extends StatefulWidget {
  const SidebarScreen({super.key});

  @override
  State<SidebarScreen> createState() => _SidebarScreenState();
}

class _SidebarScreenState extends State<SidebarScreen> {
  String _userName = 'ข้อมูลส่วนตัว';
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? 'ข้อมูลส่วนตัว';
          _profileImageBase64 = doc.data()?['profile_image']; // ดึงรหัสรูปมาเก็บ
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 280,
        decoration: const BoxDecoration(
          color: Color(0xFFD6F5E8),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildMenuSection(context),
              const Divider(
                  color: Color(0xFFB0DDC8),
                  thickness: 1,
                  indent: 24,
                  endIndent: 24),
              _buildSecondSection(context),
              const Spacer(),
              _buildLogout(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF87),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF87).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                // --- เช็คและโชว์รูป Base64 ---
                image: (_profileImageBase64 != null && _profileImageBase64!.length > 100)
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(_profileImageBase64!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // ถ้าไม่มีรูปใน Base64 ให้โชว์ไอคอนคนเดิม
              child: (_profileImageBase64 == null || _profileImageBase64!.length <= 100)
                  ? const Icon(Icons.person, color: Colors.white, size: 26)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _userName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A2E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
    
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Color(0xFF1A3A2E), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      {'icon': Icons.calculate_outlined, 'label': 'CALCULATE', 'route': '/calculate'},
      {'icon': Icons.location_on_outlined, 'label': 'PAYMENT LOCATION', 'route': '/payment_location'},
      {'icon': Icons.receipt_long_outlined, 'label': 'PAYMENT TRACKING', 'route': '/tracking'},
    ];
    return Column(
      children: items.map((item) => _buildSidebarItem(
        context,
        item['icon'] as IconData,
        item['label'] as String,
        item['route'] as String,
      )).toList(),
    );
  }

  Widget _buildSecondSection(BuildContext context) {
    final items = [
      {'icon': Icons.rate_review_outlined, 'label': 'WRITE THE REVIEW', 'route': '/review'},
      {'icon': Icons.add_home_outlined, 'label': 'ADD ELECTRICAL', 'route': '/add_electrical_water'},
      {'icon': Icons.campaign_outlined, 'label': 'ANNOUNCEMENT', 'route': '/announcement'},
    ];
    return Column(
      children: items.map((item) => _buildSidebarItem(
        context,
        item['icon'] as IconData,
        item['label'] as String,
        item['route'] as String,
      )).toList(),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String label, String route) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Coming soon: $label')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF2E7D5E), size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFF1A3A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade400, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                'log out',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}