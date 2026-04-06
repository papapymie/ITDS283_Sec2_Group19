import 'dart:async';
import 'package:flutter/material.dart';
import '../fonts/my_flutter_app_icons.dart';

enum DeviceType { electrical, water, add }

class DeviceItem {
  final String name;
  final IconData icon;
  final DeviceType type;
  final Color cardColor;
  final Color iconColor;

  const DeviceItem({
    required this.name,
    required this.icon,
    required this.type,
    required this.cardColor,
    required this.iconColor,
  });
}

class DeviceProvider extends ChangeNotifier {
  static final DeviceProvider _instance = DeviceProvider._internal();
  factory DeviceProvider() => _instance;
  DeviceProvider._internal();

  // Timer state
  final Map<int, Duration> durations = {};
  final Map<int, bool> isRunning = {};
  final Map<int, Timer?> timers = {};

  void initTimersIfNeeded(int length) {
    for (int i = 0; i < length; i++) {
      durations.putIfAbsent(i, () => Duration.zero);
      isRunning.putIfAbsent(i, () => false);
      timers.putIfAbsent(i, () => null);
    }
  }

  void toggleTimer(int index, VoidCallback onExceed24h) {
    if (isRunning[index] == true) {
      timers[index]?.cancel();
      isRunning[index] = false;
      notifyListeners();
    } else {
      timers[index] = Timer.periodic(const Duration(seconds: 1), (_) {
        final current = durations[index] ?? Duration.zero;
        if (current.inDays >= 1) {
          timers[index]?.cancel();
          isRunning[index] = false;
          notifyListeners();
          onExceed24h();
          return;
        }
        durations[index] = current + const Duration(seconds: 1);
        notifyListeners();
      });
      isRunning[index] = true;
      notifyListeners();
    }
  }

  void resetTimer(int index) {
    timers[index]?.cancel();
    durations[index] = Duration.zero;
    isRunning[index] = false;
    notifyListeners();
  }

  List<DeviceItem> electricalDevices = [
    const DeviceItem(
      name: 'คอมพิวเตอร์',
      icon: MyFlutterApp.computer,
      type: DeviceType.electrical,
      cardColor: Color(0xFFF4D487),
      iconColor: Color(0xFF7B411F),
    ),
    const DeviceItem(
      name: 'ปลั๊กไฟ',
      icon: MyFlutterApp.plug,
      type: DeviceType.electrical,
      cardColor: Color(0xFFF4D487),
      iconColor: Color(0xFF7B411F),
    ),
    const DeviceItem(
      name: 'หลอดไฟ',
      icon: MyFlutterApp.light,
      type: DeviceType.electrical,
      cardColor: Color(0xFFF4D487),
      iconColor: Color(0xFF7B411F),
    ),
    const DeviceItem(
      name: 'พัดลม',
      icon: MyFlutterApp.fan,
      type: DeviceType.electrical,
      cardColor: Color(0xFFF4D487),
      iconColor: Color(0xFF7B411F),
    ),
  ];

  List<DeviceItem> waterDevices = [
    const DeviceItem(
      name: 'ก๊อกน้ำ',
      icon: MyFlutterApp.faucet,
      type: DeviceType.water,
      cardColor: Color(0xFFB8E3F7),
      iconColor: Color(0xFF234F88),
    ),
    const DeviceItem(
      name: 'อ่างอาบน้ำ',
      icon: MyFlutterApp.bathtub,
      type: DeviceType.water,
      cardColor: Color(0xFFB8E3F7),
      iconColor: Color(0xFF234F88),
    ),
    const DeviceItem(
      name: 'เครื่องซักผ้า',
      icon: MyFlutterApp.washing_machine,
      type: DeviceType.water,
      cardColor: Color(0xFFB8E3F7),
      iconColor: Color(0xFF234F88),
    ),
  ];

  List<DeviceItem> get allDevices => [...electricalDevices, ...waterDevices];

  void addDevice(DeviceItem item) {
    if (item.type == DeviceType.electrical) {
      if (!electricalDevices.any((e) => e.name == item.name)) {
        electricalDevices.add(item);
        notifyListeners();
      }
    } else if (item.type == DeviceType.water) {
      if (!waterDevices.any((e) => e.name == item.name)) {
        waterDevices.add(item);
        notifyListeners();
      }
    }
  }

  void deleteDevice(DeviceItem item) {
    if (item.type == DeviceType.electrical) {
      electricalDevices.remove(item);
    } else {
      waterDevices.remove(item);
    }
    notifyListeners();
  }
}