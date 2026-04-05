import 'package:flutter/material.dart';
import '../providers/device_provider.dart'; // ← import จากที่เดียว
import '../fonts/my_flutter_app_icons.dart';

// ลบ enum DeviceType ออก (ย้ายไป device_provider.dart แล้ว)

class AddDeviceResult {
  final String name;
  final DeviceType type; // ← ใช้จาก device_provider.dart

  const AddDeviceResult({
    required this.name,
    required this.type,
  });
}

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _nameController = TextEditingController();
  DeviceType selectedType = DeviceType.electrical;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อเครื่องใช้')),
      );
      return;
    }
    Navigator.pop(
      context,
      AddDeviceResult(name: name, type: selectedType),
    );
  }

  Widget _typeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        height: 135,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: isSelected
              ? Border.all(color: Colors.black, width: 2.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
            const SizedBox(height: 10),
            Icon(icon, size: 62, color: iconColor),
          ],
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F4C8),
    // 1. ใช้ AppBar เพื่อให้หัวข้อ "ลอย" และมีระยะห่างที่ถูกต้อง
    appBar: AppBar(
      backgroundColor: const Color(0xFFCFEFC0), // สีเดียวกับหน้าหลัก
      elevation: 2, // ให้ลอยมีเงาจางๆ
      leading: IconButton(
        icon: const Icon(Icons.arrow_circle_left_outlined, size: 32, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'ADD DEVICE', // หรือใช้ 'ELECTRICAL & WATER' ตามเดิมก็ได้ครับ
        style: TextStyle(fontFamily: 'Koulen', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
      ),
      centerTitle: false,
    ),
    body: SingleChildScrollView( // ใช้ SingleChildScrollView กันหน้าจอเลื่อนไม่ได้ตอนคีย์บอร์ดเด้ง
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เพิ่มเครื่องใช้ไฟฟ้าและน้ำประปาเพื่อจับเวลาการใช้งาน',
              style: TextStyle(
                  fontFamily: 'NotoSansThai',
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            
            // ส่วนเลือกประเภท (Type Selection)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded( // ใช้ Expanded เพื่อให้ปุ่มปรับขนาดตามหน้าจอได้ดีขึ้น
                  child: _typeButton(
                    title: 'เครื่องใช้ไฟฟ้า',
                    icon: MyFlutterApp.electrical,
                    isSelected: selectedType == DeviceType.electrical,
                    bgColor: const Color(0xFFF4D487),
                    iconColor: const Color(0xFF7B411F),
                    onTap: () => setState(() => selectedType = DeviceType.electrical),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _typeButton(
                    title: 'เครื่องใช้น้ำประปา',
                    icon: MyFlutterApp.water,
                    isSelected: selectedType == DeviceType.water,
                    bgColor: const Color(0xFFB8E3F7),
                    iconColor: const Color(0xFF234F88),
                    onTap: () => setState(() => selectedType = DeviceType.water),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Text('ชื่อเครื่องใช้',
                style: TextStyle(
                    fontFamily: 'NotoSansThai',
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            
            // ช่องกรอกชื่อ (TextField)
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // เปลี่ยนเป็นสีขาวให้ตัดกับพื้นหลังเหลือง
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontFamily: 'NotoSansThai', fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'เขียนชื่อเครื่องใช้...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // ปุ่ม SAVE
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E7B8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('SAVE',
                    style: TextStyle(fontFamily: 'Koulen', color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ปุ่ม CANCEL
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE9B9B),
                  elevation: 0, // ปุ่ม Cancel ไม่ต้องมีเงาเพื่อให้ดูเด่นน้อยกว่า Save
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('CANCEL',
                    style: TextStyle(fontFamily: 'Koulen', color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}