import 'package:flutter/material.dart';
import '../providers/device_provider.dart';
import '../fonts/my_flutter_app_icons.dart';
import 'add_device_screen.dart';
import 'timer_screen.dart';

class AddElectricalWaterScreen extends StatefulWidget {
  const AddElectricalWaterScreen({super.key});

  @override
  State<AddElectricalWaterScreen> createState() =>
      _AddElectricalWaterScreenState();
}

class _AddElectricalWaterScreenState extends State<AddElectricalWaterScreen> {
  final _provider = DeviceProvider();

  Future<void> _openAddDevicePage() async {
    final result = await Navigator.push<AddDeviceResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
    );
    if (result == null) return;

    final newItem = DeviceItem(
      name: result.name,
      icon: result.type == DeviceType.electrical
          ? MyFlutterApp.electrical
          : MyFlutterApp.water,
      type: result.type,
      cardColor: result.type == DeviceType.electrical
          ? const Color(0xFFF4D487)
          : const Color(0xFFB8E3F7),
      iconColor: result.type == DeviceType.electrical
          ? const Color(0xFF7B411F)
          : const Color(0xFF234F88),
    );

    setState(() => _provider.addDevice(newItem));
  }

  void _goToTimerPage(DeviceItem device) {
    final index = _provider.allDevices.indexOf(device);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final electricalDevices = _provider.electricalDevices;
    final waterDevices = _provider.waterDevices;

    // การ์ด "เพิ่มเครื่องใช้อื่นๆ" สำหรับ water grid
    final addCard = DeviceItem(
      name: 'เพิ่มเครื่องใช้อื่นๆ',
      icon: Icons.add_circle_outline,
      type: DeviceType.add,
      cardColor: const Color(0xFFD3DEE5),
      iconColor: const Color(0xFF222222),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4C8),
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Container(
              height: 38,
              width: double.infinity,
              color: const Color(0xFFCFEFC0),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false),
                child: const Icon(Icons.arrow_circle_left_outlined,
                    size: 24, color: Colors.black),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ELECTRICAL & WATER',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'กดเลือกเครื่องใช้ไฟฟ้าและน้ำประปาเพื่อจับเวลาการใช้งาน',
                      style: TextStyle(
                          fontFamily: 'NotoSansThai',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),

                    // ── Electrical Grid ──
                    GridView.builder(
                      itemCount: electricalDevices.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final device = electricalDevices[index];
                        return _deviceCard(
                          title: device.name,
                          icon: device.icon,
                          cardColor: device.cardColor,
                          iconColor: device.iconColor,
                          onTap: () => _goToTimerPage(device),
                          onLongPress: () =>
                              setState(() => _provider.deleteDevice(device)),
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                    Container(width: double.infinity, height: 2, color: Colors.black),
                    const SizedBox(height: 18),

                    // ── Water Grid ──
                    GridView.builder(
                      itemCount: waterDevices.length + 1, // +1 สำหรับปุ่ม Add
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        if (index == waterDevices.length) {
                          // ปุ่ม "เพิ่มเครื่องใช้"
                          return _deviceCard(
                            title: addCard.name,
                            icon: addCard.icon,
                            cardColor: addCard.cardColor,
                            iconColor: addCard.iconColor,
                            onTap: _openAddDevicePage,
                          );
                        }
                        final device = waterDevices[index];
                        return _deviceCard(
                          title: device.name,
                          icon: device.icon,
                          cardColor: device.cardColor,
                          iconColor: device.iconColor,
                          onTap: () => _goToTimerPage(device),
                          onLongPress: () =>
                              setState(() => _provider.deleteDevice(device)),
                        );
                      },
                    ),
                  ],
                ),
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
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'NotoSansThai',
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
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