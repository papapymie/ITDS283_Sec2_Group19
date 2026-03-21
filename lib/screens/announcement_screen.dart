import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = [
      {
        'date': '7 October 2025',
        'title': 'การสมัครใช้บริการข้อมูลข่าวสารอิเล็กทรอนิกส์',
        'isPinned': true,
        'isNew': false,
        'color': const Color(0xFF4CAF87),
      },
      {
        'date': '15 September 2025',
        'title': 'ดาวน์โหลดเกียรติบัตร ผู้ผ่านเกณฑ์การทดสอบ พ.ร.บ.ข้อมูลข่าวสาร',
        'isPinned': true,
        'isNew': false,
        'color': const Color(0xFF4CAF87),
      },
      {
        'date': '23 June 2025',
        'title': 'รายชื่อหน่วยงานที่ผ่านเกณฑ์การประเมินปรับปรุงข้อมูลสารสนเทศโดยเด็ดขาด ปี ชั่วร้าย',
        'isPinned': false,
        'isNew': true,
        'color': const Color(0xFFE91E63),
      },
      {
        'date': '20 June 2025',
        'title': 'แนวทางในการปรับรหัสผ่าน(Password) สำหรับการเข้าใช้งานระบบศูนย์ข้อมูลข่าวสารอิเล็กทรอนิกส์ (Infocenter)',
        'isPinned': false,
        'isNew': true,
        'color': const Color(0xFFE91E63),
      },
      {
        'date': '13 January 2025',
        'title': 'วิธีการเปลี่ยนชื่อหน่วยงานและโลโก้หน่วยงาน',
        'isPinned': false,
        'isNew': true,
        'color': const Color(0xFFE91E63),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildCard(announcements[index]);
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF1A3A2E), size: 16),
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

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
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
                    item['date'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A3A2E),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildBadge(item),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> item) {
    final isPinned = item['isPinned'] as bool;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: (item['color'] as Color).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPinned ? Icons.star : Icons.location_on,
        color: item['color'] as Color,
        size: 16,
      ),
    );
  }
}
