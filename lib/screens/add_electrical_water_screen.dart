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
                    context, '/home', (route) => false),
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
            // เนื้อหา
            Expanded(
              child: SingleChildScrollView(
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.0,
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
                    const SizedBox(height: 24),
                    const Divider(thickness: 2, color: Colors.black),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: waterDevices.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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