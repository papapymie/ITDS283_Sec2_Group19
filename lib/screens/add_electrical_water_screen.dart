import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../providers/device_provider.dart';
import 'add_device_screen.dart';
import 'timer_screen.dart';

class AddElectricalWaterScreen extends StatefulWidget {
  final bool fromTimer;

  const AddElectricalWaterScreen({
    super.key,
    this.fromTimer = false,
  });

  @override
  State<AddElectricalWaterScreen> createState() => _AddElectricalWaterScreenState();
}

class _AddElectricalWaterScreenState extends State<AddElectricalWaterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isDeleteMode = false;

  // --- Logic Methods ---

  Future<void> _openAddDevicePage() async {
    final result = await Navigator.push<AddDeviceResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
    );

    if (result == null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('devices').add({
      'name': result.name,
      'type': result.type == DeviceType.electrical ? 'electrical' : 'water',
      'iconKey': result.type == DeviceType.electrical ? 'electrical' : 'water',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _goToTimerPage(List<_DeviceData> allDevices, _DeviceData device) {
    final index = allDevices.indexWhere((d) => d.id == device.id);
    final timerDevices = allDevices.map((d) {
      return TimerDevice(
        id: d.id,
        name: d.name,
        type: d.type,
        iconKey: d.iconKey,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          devices: timerDevices,
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(_DeviceData device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${device.name}" ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Color.fromARGB(255, 119, 32, 26))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteDevice(device);
    }
  }

  Future<void> _deleteDevice(_DeviceData device) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (device.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบเฉพาะในเครื่อง (ค่า default ไม่ถูกลบจริง)')),
      );
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device.id)
        .delete();
  }

  // --- UI Helper Methods ---

  Color _getCardColor(DeviceType type) {
    return type == DeviceType.electrical ? const Color(0xFFF4D487) : const Color(0xFFB8E3F7);
  }

  Color _getIconColor(DeviceType type) {
    return type == DeviceType.electrical ? const Color(0xFF7B411F) : const Color(0xFF234F88);
  }

  DeviceType _getDeviceType(String type) {
    return type == 'electrical' ? DeviceType.electrical : DeviceType.water;
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4C8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildHeaderNav(),
            
            // Title & Delete Toggle
            _buildTitleSection(),

            // Device Lists
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('devices')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (_auth.currentUser == null) {
                    return const Center(child: Text('กรุณาเข้าสู่ระบบเพื่อดูอุปกรณ์ของคุณ'));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }

                  // Data Processing
                  final docs = snapshot.data?.docs ?? [];
                  final customDevices = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _DeviceData(
                      id: doc.id,
                      name: data['name'] ?? '',
                      type: _getDeviceType(data['type'] ?? 'electrical'),
                      iconKey: data['iconKey'] ?? 'electrical',
                      isDefault: false,
                    );
                  }).toList();

                  final allDevices = [..._defaultDevices(), ...customDevices];
                  final electrical = allDevices.where((d) => d.type == DeviceType.electrical).toList();
                  final water = allDevices.where((d) => d.type == DeviceType.water).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'กดเลือกเครื่องใช้ไฟฟ้าและน้ำประปาเพื่อจับเวลาการใช้งาน',
                          style: TextStyle(fontFamily: 'NotoSansThai', fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 24),
                        _buildDeviceGrid(electrical, allDevices),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(thickness: 2, color: Colors.black),
                        ),
                        _buildDeviceGrid(water, allDevices, showAddButton: true),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeaderNav() {
    return Container(
      height: 50,
      width: double.infinity,
      color: const Color(0xFFCFEFC0),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        child: const Icon(Icons.arrow_circle_left_outlined, size: 30),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ELECTRICAL & WATER',
            style: TextStyle(fontFamily: 'Koulen', fontSize: 26, fontWeight: FontWeight.w900),
          ),
          IconButton(
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete, color: Color.fromARGB(255, 119, 32, 26)),
            onPressed: () => setState(() => isDeleteMode = !isDeleteMode),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(List<_DeviceData> devices, List<_DeviceData> allDevices, {bool showAddButton = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length + (showAddButton ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (showAddButton && index == devices.length) {
          return _deviceCard(
            title: 'เพิ่มเครื่องใช้อื่นๆ',
            icon: Icons.add_circle_outline,
            cardColor: const Color(0xFFD3DEE5),
            iconColor: const Color(0xFF222222),
            onTap: _openAddDevicePage,
          );
        }

        final device = devices[index];
        return _deviceCard(
          title: device.name,
          icon: getDeviceIcon(device.iconKey),
          cardColor: _getCardColor(device.type),
          iconColor: _getIconColor(device.type),
          onTap: () => isDeleteMode ? _confirmDelete(device) : _goToTimerPage(allDevices, device),
        );
      },
    );
  }

  Widget _deviceCard({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'NotoSansThai', fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Icon(icon, size: 80, color: iconColor),
          ],
        ),
      ),
    );
  }
}

// --- Data Models & Defaults ---

List<_DeviceData> _defaultDevices() {
  return [
    _DeviceData(id: 'def_elec_1', name: 'คอมพิวเตอร์', type: DeviceType.electrical, iconKey: 'computer', isDefault: true),
    _DeviceData(id: 'def_elec_2', name: 'ปลั๊กไฟ', type: DeviceType.electrical, iconKey: 'plug', isDefault: true),
    _DeviceData(id: 'def_elec_3', name: 'หลอดไฟ', type: DeviceType.electrical, iconKey: 'light', isDefault: true),
    _DeviceData(id: 'def_elec_4', name: 'พัดลม', type: DeviceType.electrical, iconKey: 'fan', isDefault: true),
    _DeviceData(id: 'def_wat_1', name: 'ก๊อกน้ำ', type: DeviceType.water, iconKey: 'faucet', isDefault: true),
    _DeviceData(id: 'def_wat_2', name: 'อ่างอาบน้ำ', type: DeviceType.water, iconKey: 'bathtub', isDefault: true),
    _DeviceData(id: 'def_wat_3', name: 'เครื่องซักผ้า', type: DeviceType.water, iconKey: 'washing_machine', isDefault: true),
  ];
}

class _DeviceData {
  final String id;
  final String name;
  final DeviceType type;
  final String iconKey;
  final bool isDefault;

  _DeviceData({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.isDefault,
  });
}