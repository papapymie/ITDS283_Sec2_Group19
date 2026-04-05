import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/device_provider.dart';

class TimerScreen extends StatefulWidget {
  final int initialIndex;

  const TimerScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _provider = DeviceProvider();
  late int _currentIndex;

  final Map<int, Duration> _durations = {};
  final Map<int, bool> _isRunning = {};
  final Map<int, Timer?> _timers = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initTimers();
  }

  void _initTimers() {
    for (int i = 0; i < _provider.allDevices.length; i++) {
      _durations.putIfAbsent(i, () => Duration.zero);
      _isRunning.putIfAbsent(i, () => false);
      _timers.putIfAbsent(i, () => null);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var t in _timers.values) {
      t?.cancel();
    }
    super.dispose();
  }

  void _toggleTimer(int index) {
    if (_isRunning[index] == true) {
      _timers[index]?.cancel();
      setState(() {
        _isRunning[index] = false;
      });
    } else {
      _timers[index] = Timer.periodic(const Duration(seconds: 1), (_) {
        final current = _durations[index] ?? Duration.zero;
        if (current.inHours >= 24) {
          _timers[index]?.cancel();
          setState(() => _isRunning[index] = false);
          return;
        }
        setState(() {
          _durations[index] = current + const Duration(seconds: 1);
        });
      });
      setState(() => _isRunning[index] = true);
    }
  }

  void _resetTimer(int index) {
    _timers[index]?.cancel();
    setState(() {
      _durations[index] = Duration.zero;
      _isRunning[index] = false;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 100).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 100).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final devices = _provider.allDevices;
    if (devices.isEmpty) return const Scaffold(body: Center(child: Text('ไม่มีเครื่องใช้')));

    if (_currentIndex >= devices.length) _currentIndex = 0;

    final appliance = devices[_currentIndex];
    final duration = _durations[_currentIndex] ?? Duration.zero;
    final isRunning = _isRunning[_currentIndex] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFBFE6F1),
      body: SafeArea(
        bottom: false, // ปล่อยให้สีขาวลงไปจนสุดพื้นที่ด้านล่าง (Home Indicator)
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
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_circle_left_outlined, size: 24),
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
                            const SizedBox(height: 20),
                            // Title section
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('USAGE TIMER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                                    Text('จับเวลาการใช้งานเครื่องใช้ไฟฟ้าและน้ำประปา', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Device Card Icon
                            Container(
                              width: 160,
                              height: 188,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(appliance.icon, size: 86, color: const Color(0xFF1E4D7B)),
                                  const SizedBox(height: 12),
                                  Text(appliance.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E4D7B))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 34),

                            // แผ่นสีขาวด้านล่าง (ยืดสุดจอ)
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(18, 40, 18, 40),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF4F4F4), // หรือ Colors.white ตามดีไซน์
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(48),
                                    topRight: Radius.circular(48),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Timer Display
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _timeUnit(_pad(duration.inHours), 'HOURS'),
                                        _colon(),
                                        _timeUnit(_pad(duration.inMinutes.remainder(60)), 'MINS'),
                                        _colon(),
                                        _timeUnit(_pad(duration.inSeconds.remainder(60)), 'SEC'),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // Control Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _resetTimer(_currentIndex),
                                          child: _controlBox(Icons.refresh, Colors.white),
                                        ),
                                        const SizedBox(width: 14),
                                        GestureDetector(
                                          onTap: () => _toggleTimer(_currentIndex),
                                          child: Container(
                                            width: 115,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: isRunning ? const Color(0xFFE89A9A) : const Color(0xFFC8E7B8),
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(isRunning ? 'STOP' : 'START', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),

                                    // Other Devices List
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('เครื่องใช้อื่น ๆ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildHorizontalList(devices),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Icon(icon, color: const Color(0xFF1A3A2E), size: 26),
    );
  }

  Widget _buildHorizontalList(List<DeviceItem> devices) {
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
                if (index == _currentIndex) return const SizedBox.shrink();
                final ap = devices[index];
                final running = _isRunning[index] ?? false;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    width: 75,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: ap.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: running ? Border.all(color: Colors.green, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ap.icon, size: 32, color: ap.iconColor),
                        Text(ap.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
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
        Text(value, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2F427F))),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _colon() {
    return const Padding(
      padding: EdgeInsets.only(left: 4, right: 4, bottom: 18),
      child: Text(':', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2F427F))),
    );
  }
}