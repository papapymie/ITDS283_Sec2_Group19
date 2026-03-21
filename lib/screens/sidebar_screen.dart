import 'package:flutter/material.dart';

class SidebarScreen extends StatelessWidget {
  const SidebarScreen({super.key});

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
              _buildMenuSection(),
              const Divider(color: Color(0xFFB0DDC8), thickness: 1, indent: 24, endIndent: 24),
              _buildSecondSection(),
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
          Container(
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
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ข้อมูลส่วนตัว',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3A2E),
              ),
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

  Widget _buildMenuSection() {
    final items = [
      {'icon': Icons.calculate_outlined, 'label': 'CALCULATE'},
      {'icon': Icons.location_on_outlined, 'label': 'PAYMENT LOCATION'},
      {'icon': Icons.receipt_long_outlined, 'label': 'PAYMENT TRACKING'},
    ];
    return Column(
      children: items
          .map((item) => _buildSidebarItem(
                item['icon'] as IconData,
                item['label'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildSecondSection() {
    final items = [
      {'icon': Icons.rate_review_outlined, 'label': 'WRITE THE REVIEW'},
      {'icon': Icons.add_home_outlined, 'label': 'ADD ELECTRICAL'},
      {'icon': Icons.campaign_outlined, 'label': 'ANNOUNCEMENT'},
    ];
    return Column(
      children: items
          .map((item) => _buildSidebarItem(
                item['icon'] as IconData,
                item['label'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
                'ออกจากระบบ',
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
