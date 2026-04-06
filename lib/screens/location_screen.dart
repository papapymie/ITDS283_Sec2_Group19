import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentLocationsPage();
  }
}

class PaymentLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  bool isFavorite;
  double? distanceKm; // ระยะห่างจากผู้ใช้

  PaymentLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.distanceKm,
  });
}

class PaymentLocationsPage extends StatefulWidget {
  const PaymentLocationsPage({super.key});

  @override
  State<PaymentLocationsPage> createState() => _PaymentLocationsPageState();
}

class _PaymentLocationsPageState extends State<PaymentLocationsPage> {
  bool _isLoadingLocation = false;
  String _locationMode = 'none'; // 'none' | 'gps' | 'address'
  String _locationStatusText = '';

  final List<PaymentLocation> _locations = [
    PaymentLocation(
      name: 'เซ็นทรัล เวสต์เกต',
      address: '199/3 หมู่ที่ 6 ตำบลเสาธงหิน อำเภอบางใหญ่ นนทบุรี 11000',
      latitude: 13.876876442743596,
      longitude: 100.4113751645286,
      isFavorite: true,
    ),
    PaymentLocation(
      name: 'เซ็นทรัล แจ้งวัฒนะ',
      address: '99, 99/9 หมู่ที่ 2 ถ.แจ้งวัฒนะ ตำบลบางตลาด อำเภอปากเกร็ด นนทบุรี 11120',
      latitude: 13.904085593826958,
      longitude: 100.52811260332135,
    ),
    PaymentLocation(
      name: 'การไฟฟ้านครหลวง เขตสามเสน',
      address: '54 1 ถ.พิชัย แขวงถนนนครไชยศรี เขตดุสิต กรุงเทพมหานคร 10300',
      latitude: 13.7808376000774,
      longitude: 100.51750960979712,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาค สาขาพุทธมณฑล',
      address: 'ตำบลศาลายา อำเภอพุทธมณฑล นครปฐม 73170',
      latitude: 13.802724026215826,
      longitude: 100.2950119540693,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาค สาขาอ้อมน้อย',
      address: '72 106 หมู่ที่ 9 ถ.พุทธมณฑลสาย 5 ตำบลไร่ขิง อำเภอสามพราน นครปฐม 73210',
      latitude: 13.726461645846777,
      longitude: 100.29753684633786,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคอำเภอสามพราน',
      address: '33/1 หมู่1 ถนนเพชรเกษม ตำบลท่าตลาด อำเภอสามพราน นครปฐม 73110',
      latitude: 13.754892273825087,
      longitude: 100.21196363897545,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคอำเภอนครชัยศรี',
      address: 'R53Q+4CF ตำบลไทยาวาส อำเภอนครชัยศรี นครปฐม 73120',
      latitude: 13.813410137303379,
      longitude: 100.18861769167175,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคจังหวัดนครปฐม',
      address: '2018 ซอย 25 มกรา 3 ตำบลพระปฐมเจดีย์ อำเภอเมืองนครปฐม นครปฐม 73000',
      latitude: 13.851747211923758,
      longitude: 100.06210324261107,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคอำเภอบางเลน',
      address: '1 1 ถนนดอนตูม ตำบลบางเลน อำเภอบางเลน นครปฐม 73130',
      latitude: 14.02118773015315,
      longitude: 100.17642973371755,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคสาขาอำเภอดอนตูม',
      address: '230 ซอยเทศบาล 9 ตำบลสามง่าม อำเภอดอนตูม นครปฐม 73150',
      latitude: 13.996037765586163,
      longitude: 100.08544918957195,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาคอำเภอกำแพงแสน',
      address: 'หมู่ที่ 1 236 ตำบลทุ่งกระพังโหม อำเภอกำแพงแสน นครปฐม 73140',
      latitude: 14.023685920258698,
      longitude: 100.0088882145367,
    ),
    PaymentLocation(
      name: 'การไฟฟ้าส่วนภูมิภาค (สำนักงานใหญ่)',
      address: '200 ถนนงามวงศ์วาน แขวงลาดยาว เขตจตุจักร กรุงเทพมหานคร 10900',
      latitude: 13.864169617702952,
      longitude: 100.55760234945282,
    ),
  ];

  // คำนวณระยะห่างและเรียงลำดับ
  void _calculateDistances(double userLat, double userLng) {
    for (var loc in _locations) {
      final distMeters = Geolocator.distanceBetween(
        userLat, userLng,
        loc.latitude, loc.longitude,
      );
      loc.distanceKm = distMeters / 1000;
    }

    // เรียง favorites ตามระยะ และ others ตามระยะ แยกกัน
    setState(() {});
  }

  // ใช้ GPS ปัจจุบัน
  Future<void> _useGPS() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatusText = 'กำลังหาตำแหน่งของคุณ...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('กรุณาเปิด Permission ตำแหน่งในการตั้งค่า');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _calculateDistances(position.latitude, position.longitude);

      setState(() {
        _locationMode = 'gps';
        _locationStatusText = 'เรียงตามตำแหน่ง GPS ของคุณ';
      });
    } catch (e) {
      _showError('ไม่สามารถหาตำแหน่งได้: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _useProfileAddress() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatusText = 'กำลังโหลดที่อยู่จาก Profile...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('กรุณาเข้าสู่ระบบก่อน');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        _showError('ไม่พบข้อมูลใน Profile\nกรุณากรอกข้อมูลที่อยู่ในหน้า Profile ก่อน');
        return;
      }

      final data = doc.data()!;
      final subdistrict = data['subdistrict']?.toString() ?? '';
      final district = data['district']?.toString() ?? '';
      final province = data['province']?.toString() ?? '';
      final postcode = data['postcode']?.toString() ?? '';

      if (subdistrict.isEmpty && district.isEmpty && province.isEmpty) {
        _showError('ไม่พบที่อยู่ใน Profile\nกรุณาอัปเดตข้อมูลที่อยู่ในหน้า Profile ก่อน');
        return;
      }

      setState(() => _locationStatusText = 'กำลังแปลงที่อยู่เป็นพิกัด...');

      final addressQuery =
          '$subdistrict $district $province $postcode Thailand'
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');

      final locations = await locationFromAddress(addressQuery);

      if (locations.isEmpty) {
        _showError('ไม่สามารถหาพิกัดจากที่อยู่ได้\nลองอัปเดตที่อยู่ใน Profile');
        return;
      }

      final loc = locations.first;
      _calculateDistances(loc.latitude, loc.longitude);

      setState(() {
        _locationMode = 'address';
        _locationStatusText = 'เรียงตามที่อยู่: $district, $province';
      });
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showError(String msg) {
    setState(() {
      _isLoadingLocation = false;
      _locationStatusText = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // popup เลือกโหมด
  void _showLocationModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('เรียงตามระยะทาง',
            style: TextStyle(fontFamily: 'NotoSansThai', fontWeight: FontWeight.w800)),
        content: const Text('เลือกวิธีระบุตำแหน่งของคุณ'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _useGPS();
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('ตำแหน่ง GPS ปัจจุบัน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF87),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _useProfileAddress();
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('ที่อยู่ใน Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF184A86),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก',
                    style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(PaymentLocation location) {
    setState(() => location.isFavorite = !location.isFavorite);
  }

  void _openMapPage(PaymentLocation location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentLocationMapPage(location: location),
      ),
    );
  }

  // เรียงรายการตามระยะ (favorites แยก, others แยก)
  List<PaymentLocation> _sorted(List<PaymentLocation> list) {
    if (_locationMode == 'none') return list;
    final sorted = List<PaymentLocation>.from(list);
    sorted.sort((a, b) =>
        (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999));
    return sorted;
  }

  List<PaymentLocation> get _favoriteLocations =>
      _sorted(_locations.where((l) => l.isFavorite).toList());

  List<PaymentLocation> get _otherLocations =>
      _sorted(_locations.where((l) => !l.isFavorite).toList());

  @override
  Widget build(BuildContext context) {
    final favorites = _favoriteLocations;
    final others = _otherLocations;

    return Scaffold(
      backgroundColor: const Color(0xFFCFEFFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_locationStatusText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: _locationMode == 'gps'
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFE3F2FD),
                child: Row(
                  children: [
                    Icon(
                      _locationMode == 'gps'
                          ? Icons.my_location
                          : Icons.home_outlined,
                      size: 16,
                      color: _locationMode == 'gps'
                          ? const Color(0xFF4CAF87)
                          : const Color(0xFF184A86),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationStatusText,
                        style: TextStyle(
                          fontFamily: 'NotoSansThai',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _locationMode == 'gps'
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF184A86),
                        ),
                      ),
                    ),
                    // ปุ่มเปลี่ยนโหมด
                    GestureDetector(
                      onTap: _showLocationModeDialog,
                      child: const Text('เปลี่ยน',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoadingLocation)
              const LinearProgressIndicator(
                  color: Color(0xFF4CAF87),
                  backgroundColor: Color(0xFFB2DFDB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (favorites.isNotEmpty) ...[
                      const Text('รายการโปรด',
                          style: TextStyle(
                            fontFamily: 'NotoSansThai',
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      ...favorites.map(_buildLocationCard),
                      const SizedBox(height: 18),
                    ],
                    const Text('สถานที่รับชำระเงินอื่น ๆ',
                        style: TextStyle(
                            fontFamily: 'NotoSansThai',
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    ...others.map(_buildLocationCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              }
            },
            child: const Icon(
              Icons.arrow_circle_left_outlined,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
        // ปุ่มเรียงตามระยะ
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showLocationModeDialog,
              icon: const Icon(Icons.near_me, size: 16),
              label: Text(
                _locationMode == 'none' ? 'เรียงตามระยะ' : 'เปลี่ยนโหมด',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF87),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ),
        // Title แยกออกมาอิสระ
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Text(
            'Payment Locations',
            style: TextStyle(
              fontFamily: 'Koulen',
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(PaymentLocation location) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: location.isFavorite
            ? const Color(0xFFFFFDE7)
            : const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(18),
        border: location.isFavorite
            ? Border.all(color: const Color(0xFFFFC107), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleFavorite(location),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Icon(
                location.isFavorite ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFC107),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(location.address,
                    style: const TextStyle(
                        fontSize: 12, height: 1.4, color: Colors.black54)),
                // แสดงระยะทาง
                if (location.distanceKm != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk,
                          size: 14, color: Color(0xFF4CAF87)),
                      const SizedBox(width: 4),
                      Text(
                        location.distanceKm! < 1
                            ? '${(location.distanceKm! * 1000).toStringAsFixed(0)} ม.'
                            : '${location.distanceKm!.toStringAsFixed(1)} กม.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF87),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _openMapPage(location),
            icon: const Icon(Icons.location_on_outlined, size: 18),
            label: const Text('แผนที่',
                style: TextStyle(fontFamily: 'NotoSansThai', fontSize: 13, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6F1FA),
              foregroundColor: Colors.black87,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentLocationMapPage extends StatelessWidget {
  final PaymentLocation location;

  const PaymentLocationMapPage({super.key, required this.location});

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(location.latitude, location.longitude);

    return Scaffold(
      backgroundColor: const Color(0xFFCFEFFF),
      body: SafeArea(
        child: Column(
          children: [
            Column(
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_circle_left_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontFamily: 'Koulen',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (location.distanceKm != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 18, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_walk,
                            size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          location.distanceKm! < 1
                              ? 'ห่าง ${(location.distanceKm! * 1000).toStringAsFixed(0)} ม.'
                              : 'ห่าง ${location.distanceKm!.toStringAsFixed(1)} กม.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: point,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.electric_home',
                              maxZoom: 19,
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: point,
                                  width: 120,
                                  height: 80,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 40, color: Colors.red),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          location.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F0E4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(location.name,
                              style: const TextStyle(
                                  fontFamily: 'NotoSansThai',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87)),
                          const SizedBox(height: 10),
                          Text( location.address,
                              style: const TextStyle(
                                  fontFamily: 'NotoSansThai', fontSize: 13, height: 1.4, color: Colors.black54)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _openInGoogleMaps(context),
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('เปิดใน Google Maps'
                                  , style: TextStyle(fontFamily: 'NotoSansThai', fontSize: 14, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD6F1FA),
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}