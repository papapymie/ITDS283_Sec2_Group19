import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart'; 

class TimerDevice {
  final String id;
  final String name;
  final DeviceType type;
  final String iconKey;

  const TimerDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
  });

  IconData get icon => getDeviceIcon(iconKey);
}

class TimerScreen extends StatefulWidget {
  final List<TimerDevice> devices;
  final int initialIndex;

  const TimerScreen({
    super.key,
    required this.devices,
    this.initialIndex = 0,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.devices.length - 1);

    // init ทุก device ใน TimerProvider
    final timerProvider = context.read<TimerProvider>();
    for (final device in widget.devices) {
      timerProvider.initDevice(device.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── toggle ผ่าน TimerProvider โดยใช้ device.id ──
  void _toggleTimer(String deviceId) {
    final timerProvider = context.read<TimerProvider>();

    final isRunning = timerProvider.isRunning[deviceId] ?? false;
    if (!isRunning) {
      // ส่ง callback เมื่อเกิน 24 ชั่วโมง
      timerProvider.toggleTimer(deviceId, onExceed24h: () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                '⏰ หมดเวลา',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: const Text(
                'คุณใช้เครื่องใช้เกิน 1 วันแล้ว\nระบบจะตัดการจับเวลาให้อัตโนมัติ',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'รับทราบ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF184A86),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      });
    } else {
      timerProvider.toggleTimer(deviceId);
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (widget.devices.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('ไม่มีเครื่องใช้')),
      );
    }

    final timerProvider = context.watch<TimerProvider>();
    final appliance = widget.devices[_currentIndex];

    final duration = timerProvider.durations[appliance.id] ?? Duration.zero;
    final isRunning = timerProvider.isRunning[appliance.id] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFBFE6F1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              height: 38,
              width: double.infinity,
              color: const Color(0xFFCFEFC0),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_circle_left_outlined,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USAGE TIMER',
                      style: TextStyle(
                        fontFamily: 'Koulen',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'จับเวลาการใช้งานเครื่องใช้ไฟฟ้าและน้ำประปา',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 28),
                            // Device Card
                            Container(
                              width: 160,
                              height: 188,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    appliance.icon,
                                    size: 86,
                                    color: const Color(0xFF1E4D7B),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    appliance.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E4D7B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 34),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(18, 40, 18, 40),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(48),
                                    topRight: Radius.circular(48),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _timeUnit(_pad(duration.inHours), 'HOURS'),
                                        _colon(),
                                        _timeUnit(
                                          _pad(duration.inMinutes.remainder(60)),
                                          'MINS',
                                        ),
                                        _colon(),
                                        _timeUnit(
                                          _pad(duration.inSeconds.remainder(60)),
                                          'SEC',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    // Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => timerProvider.resetTimer(appliance.id),
                                          child: _controlBox(Icons.refresh, Colors.white),
                                        ),
                                        const SizedBox(width: 14),
                                        GestureDetector(
                                          onTap: () => _toggleTimer(appliance.id),
                                          child: Container(
                                            width: 115,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: isRunning
                                                  ? const Color(0xFFE89A9A)
                                                  : const Color(0xFFC8E7B8),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              isRunning ? 'STOP' : 'START',
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'เครื่องใช้อื่น ๆ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildHorizontalList(widget.devices, timerProvider),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _controlBox(IconData icon, Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1A3A2E), size: 26),
    );
  }

  Widget _buildHorizontalList(List<TimerDevice> devices, TimerProvider timerProvider) {
    return Row(
      children: [
        IconButton(onPressed: _scrollLeft, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final ap = devices[index];

                if (ap.id == widget.devices[_currentIndex].id) {
                  return const SizedBox.shrink();
                }

                final running = timerProvider.isRunning[ap.id] ?? false;

                // ── เช็คสีจาก iconKey โดยตรง ──
                final isWater = ['faucet', 'bathtub', 'washing_machine', 'water']
                    .contains(ap.iconKey);
                final cardColor = isWater
                    ? const Color(0xFFB8E3F7) 
                    : const Color(0xFFF4D487); 
                final iconColor = isWater
                    ? const Color(0xFF234F88)  
                    : const Color(0xFF7B411F);

                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    width: 75,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: running
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ap.icon, size: 32, color: iconColor),
                        Text(
                          ap.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(onPressed: _scrollRight, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _timeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2F427F),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _colon() {
    return const Padding(
      padding: EdgeInsets.only(left: 4, right: 4, bottom: 18),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: Color(0xFF2F427F),
        ),
      ),
    );
  }
}