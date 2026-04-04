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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_circle_left_outlined),
              ),
              const SizedBox(height: 16),
              const Text('ELECTRICAL & WATER',
                  style: TextStyle(
                      fontFamily: 'Koulen',
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text(
                'เพิ่มเครื่องใช้ไฟฟ้าและน้ำประปาเพื่อจับเวลาการใช้งาน',
                style: TextStyle(
                    fontFamily: 'NotoSansThai',
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _typeButton(
                    title: 'เครื่องใช้ไฟฟ้า',
                    icon: MyFlutterApp.electrical,
                    isSelected: selectedType == DeviceType.electrical,
                    bgColor: const Color(0xFFF4D487),
                    iconColor: const Color(0xFF7B411F),
                    onTap: () =>
                        setState(() => selectedType = DeviceType.electrical),
                  ),
                  const SizedBox(width: 24),
                  _typeButton(
                    title: 'เครื่องใช้น้ำประปา',
                    icon: MyFlutterApp.water,
                    isSelected: selectedType == DeviceType.water,
                    bgColor: const Color(0xFFB8E3F7),
                    iconColor: const Color(0xFF234F88),
                    onTap: () =>
                        setState(() => selectedType = DeviceType.water),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('ชื่อเครื่องใช้',
                  style: TextStyle(
                      fontFamily: 'NotoSansThai',
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'เขียนชื่อเครื่องใช้',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 52),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8E7B8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('SAVE',
                      style: TextStyle(
                          fontFamily: 'Koulen',
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE9B9B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('CANCEL',
                      style: TextStyle(
                          fontFamily: 'Koulen',
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}