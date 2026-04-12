  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
  import '../providers/device_provider.dart';
  import 'add_device_screen.dart';
  import 'timer_screen.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  class AddElectricalWaterScreen extends StatefulWidget {
    final bool fromTimer; 

    const AddElectricalWaterScreen({
      super.key,
      this.fromTimer = false,
    });

    @override
    State<AddElectricalWaterScreen> createState() =>
        _AddElectricalWaterScreenState();
    }

  DeviceType getDeviceTypeFromString(String type) {
    return type == 'electrical' ? DeviceType.electrical : DeviceType.water;
  }

  class _AddElectricalWaterScreenState extends State<AddElectricalWaterScreen> {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Future<void> _openAddDevicePage() async {
      final result = await Navigator.push<AddDeviceResult>(
        context,
        MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
      );

      if (result == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('devices').add({
        'user_id': user.uid,
        'name': result.name,
        'type': result.type == DeviceType.electrical ? 'electrical' : 'water',
        'iconKey': result.type == DeviceType.electrical ? 'electrical' : 'water',
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    void _goToTimerPage(List<_DeviceData> allDevices, _DeviceData device) {
      final index = allDevices.indexWhere((d) => d.id == device.id);

      final timerDevices = allDevices.map((d) {
        return TimerDevice(
          id: d.id,
          name: d.name,
          type: getDeviceTypeFromString(d.type.toString()),
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

    Future<void> _deleteDevice(String docId) async {
      await _firestore.collection('devices').doc(docId).delete();
    }

    Color _getCardColor(DeviceType type) {
      switch (type) {
        case DeviceType.electrical:
          return const Color(0xFFF4D487);
        case DeviceType.water:
          return const Color(0xFFB8E3F7);
      }
    }

    Color _getIconColor(DeviceType type) {
      switch (type) {
        case DeviceType.electrical:
          return const Color(0xFF7B411F);
        case DeviceType.water:
          return const Color(0xFF234F88);
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F4C8),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: const Color(0xFFCFEFC0),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  ),
                  child: const Icon(
                    Icons.arrow_circle_left_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
                child: Text(
                  'ELECTRICAL & WATER',
                  style: TextStyle(
                    fontFamily: 'Koulen',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('devices').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    final allDevices = docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return _DeviceData(
                        id: doc.id,
                        name: data['name'] ?? '',
                        type: getDeviceTypeFromString(data['type'] ?? ''),
                        iconKey: data['iconKey'] ?? '',
                      );
                    }).toList();

                    final electricalDevices = allDevices
                        .where((d) => d.type == DeviceType.electrical)
                        .toList();

                    final waterDevices = allDevices
                        .where((d) => d.type == DeviceType.water)
                        .toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'กดเลือกเครื่องใช้ไฟฟ้าและน้ำประปาเพื่อจับเวลาการใช้งาน',
                            style: TextStyle(
                              fontFamily: 'NotoSansThai',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: electricalDevices.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final device = electricalDevices[index];
                              return _deviceCard(
                                title: device.name,
                                icon: getDeviceIcon(device.iconKey),
                                cardColor: _getCardColor(device.type),
                                iconColor: _getIconColor(device.type),
                                onTap: () => _goToTimerPage(allDevices, device),
                                onLongPress: () => _deleteDevice(device.id),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Divider(thickness: 2, color: Colors.black),
                          const SizedBox(height: 24),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: waterDevices.length + 1,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              if (index == waterDevices.length) {
                                return _deviceCard(
                                  title: 'เพิ่มเครื่องใช้อื่นๆ',
                                  icon: Icons.add_circle_outline,
                                  cardColor: const Color(0xFFD3DEE5),
                                  iconColor: const Color(0xFF222222),
                                  onTap: _openAddDevicePage,
                                );
                              }

                              final device = waterDevices[index];
                              return _deviceCard(
                                title: device.name,
                                icon: getDeviceIcon(device.iconKey),
                                cardColor: _getCardColor(device.type),
                                iconColor: _getIconColor(device.type),
                                onTap: () => _goToTimerPage(allDevices, device),
                                onLongPress: () => _deleteDevice(device.id),
                              );
                            },
                          ),
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

    static Widget _deviceCard({
      required String title,
      required IconData icon,
      required Color cardColor,
      required Color iconColor,
      required VoidCallback onTap,
      VoidCallback? onLongPress,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Ink(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSansThai',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(icon, size: 80, color: iconColor),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  class _DeviceData {
    final String id;
    final String name;
    final DeviceType type;
    final String iconKey;

    _DeviceData({
      required this.id,
      required this.name,
      required this.type,
      required this.iconKey,
    });
  }
