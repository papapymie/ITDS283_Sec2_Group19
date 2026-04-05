import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar_screen.dart';
import 'announcement_screen.dart';
import 'calculate_screen.dart';
import 'review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBanner = 0;
  int _bottomIndex = 0;
  String _userName = 'USER';

  final List<Map<String, String>> _banners = [
    {
      'title': 'Welcome!\nto Electric Home',
      'subtitle': '⚡ Stay watts-aware,\nsave more...',
      'desc': 'ดูแลการใช้ไฟฟ้าที่บ้าน',
    },
    {
      'title': 'ประหยัดพลังงาน\nเพื่ออนาคต',
      'subtitle': '🌿 ลดการใช้ไฟ\nช่วยโลก...',
      'desc': 'เช็คบิลค่าไฟของคุณ >',
    },
    {
      'title': 'แจ้งเตือน\nค่าไฟล่าสุด',
      'subtitle': '📊 ติดตามการใช้\nพลังงาน...',
      'desc': 'ดูรายละเอียด >',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.serverAndCache));

    if (doc.exists && mounted) {
      setState(() {
        _userName = doc.data()?['name'] ?? 'USER';
      });
    }
  }

  void _onMenuTap(String label) {
    switch (label) {
      case 'CALCULATE':
        Navigator.pushNamed(context, '/calculate');
        break;
      case 'WRITE THE\nREVIEW':
        Navigator.pushNamed(context, '/review');
        break;
      case 'PAYMENT\nLOCATION':
        Navigator.pushNamed(context, '/location');
        break;
      case 'PAYMENT\nTRACKING':
        Navigator.pushNamed(context, '/tracking');
        break;
      case 'ADD\nELECTRICAL':
        Navigator.pushNamed(context, '/add_electrical_water');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF5),
      drawer: const SidebarScreen(),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _buildTopBar(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBannerCarousel(),
                  const SizedBox(height: 8),
                  _buildBannerDots(),
                  const SizedBox(height: 28),
                  _buildMenuGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.menu, color: Color(0xFF1A3A2E), size: 20),
              ),
            ),
          ),
          Text(
            'HELLO, ${_userName.toUpperCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Color(0xFF1A3A2E),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _banners.length,
        onPageChanged: (i) => setState(() => _currentBanner = i),
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4CAF87), Color(0xFF2E7D5E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF87).withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: -30,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 20,
                  child: Row(
                    children: [
                      _buildBulbIcon(Colors.yellow, 44),
                      const SizedBox(width: 6),
                      _buildBulbIcon(Colors.lightGreen, 36),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 20,
                  child: Row(
                    children: [
                      _buildBulbIcon(Colors.orange.shade300, 30),
                      const SizedBox(width: 8),
                      _buildPlugIcon(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner['subtitle']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          banner['desc']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulbIcon(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)],
      ),
      child: const Icon(Icons.lightbulb, color: Colors.white, size: 18),
    );
  }

  Widget _buildPlugIcon() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.power, color: Colors.white, size: 16),
    );
  }

  Widget _buildBannerDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentBanner == i ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: _currentBanner == i ? const Color(0xFF4CAF87) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {'icon': Icons.calculate_outlined, 'label': 'CALCULATE'},
      {'icon': Icons.location_on_outlined, 'label': 'PAYMENT\nLOCATION'},
      {'icon': Icons.receipt_long_outlined, 'label': 'PAYMENT\nTRACKING'},
      {'icon': Icons.rate_review_outlined, 'label': 'WRITE THE\nREVIEW'},
      {'icon': Icons.add_home_outlined, 'label': 'ADD\nELECTRICAL'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: menuItems.take(3).map((item) => _buildMenuItem(
              item['icon'] as IconData,
              item['label'] as String,
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...menuItems.skip(3).map((item) => _buildMenuItem(
                item['icon'] as IconData,
                item['label'] as String,
              )).toList(),
              const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _onMenuTap(label),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2E7D5E), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3A2E),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, 'HOME PAGE', 0,
                onTap: () => setState(() => _bottomIndex = 0),
              ),
              _buildNavItem(Icons.campaign_outlined, 'ANNOUNCEMENT', 1,
                onTap: () async {
                  setState(() => _bottomIndex = 1);
                  await Navigator.pushNamed(context, '/announcement');
                  setState(() => _bottomIndex = 0);
                },
              ),
              _buildNavItem(Icons.person_outline, 'ACCOUNT', 2,
                onTap: () async {
                  setState(() => _bottomIndex = 2);
                  await Navigator.pushNamed(context, '/profile');
                  setState(() {
                    _bottomIndex = 0;
                    _loadUserName();
                  });
                },
              ),
              _buildNavItem(Icons.add_home_outlined, 'ADD ELECTRICAL', 3,
                onTap: () async {
                  setState(() => _bottomIndex = 3);
                  await Navigator.pushNamed(context, '/add_electrical_water');
                  setState(() => _bottomIndex = 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {VoidCallback? onTap}) {
    final isActive = _bottomIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4CAF87) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF4CAF87) : Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}