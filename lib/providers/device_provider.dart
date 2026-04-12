import 'dart:async';
import 'package:flutter/material.dart';
import '../fonts/my_flutter_app_icons.dart';

enum DeviceType {
  electrical,
  water,
}

DeviceType getDeviceTypeFromString(String type) {
  return type == 'electrical'
      ? DeviceType.electrical
      : DeviceType.water;
}

String getDeviceTypeString(DeviceType type) {
  switch (type) {
    case DeviceType.electrical:
      return 'electrical';
    case DeviceType.water:
      return 'water';
  }
}

const Map<String, IconData> deviceIconMap = {
  'computer': MyFlutterApp.computer,
  'plug': MyFlutterApp.plug,
  'light': MyFlutterApp.light,
  'fan': MyFlutterApp.fan,
  'faucet': MyFlutterApp.faucet,
  'bathtub': MyFlutterApp.bathtub,
  'washing_machine': MyFlutterApp.washing_machine,
  'electrical': MyFlutterApp.electrical,
  'water': MyFlutterApp.water,
};

IconData getDeviceIcon(String iconKey) {
  return deviceIconMap[iconKey] ?? Icons.device_unknown;
}

class TimerProvider extends ChangeNotifier {
  final Map<String, Duration> durations = {};
  final Map<String, bool> isRunning = {};
  final Map<String, Timer?> _timers = {};

  void initDevice(String deviceId) {
    durations.putIfAbsent(deviceId, () => Duration.zero);
    isRunning.putIfAbsent(deviceId, () => false);
    _timers.putIfAbsent(deviceId, () => null);
  }

  void toggleTimer(String deviceId, {VoidCallback? onExceed24h}) {
    initDevice(deviceId);

    final running = isRunning[deviceId] ?? false;

    if (running) {
      _timers[deviceId]?.cancel();
      isRunning[deviceId] = false;
      notifyListeners();
      return;
    }

    isRunning[deviceId] = true;
    _timers[deviceId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = durations[deviceId] ?? Duration.zero;
      final updated = current + const Duration(seconds: 1);

      if (updated.inDays >= 1) {
        timer.cancel();
        durations[deviceId] = updated;
        isRunning[deviceId] = false;
        notifyListeners();
        onExceed24h?.call(); // ← แจ้ง UI
        return;
      }

      durations[deviceId] = updated;
      notifyListeners();
    });

    notifyListeners();
  }

  void resetTimer(String deviceId) {
    _timers[deviceId]?.cancel();
    durations[deviceId] = Duration.zero;
    isRunning[deviceId] = false;
    notifyListeners();
  }
}