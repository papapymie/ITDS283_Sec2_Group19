import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'location_map_screen.dart';

class PaymentLocationScreen extends StatefulWidget {
  const PaymentLocationScreen({super.key});

  @override
  State<PaymentLocationScreen> createState() => _PaymentLocationScreenState();
}

class PaymentLocation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  bool isFavorite;
  double? distanceKm;

  PaymentLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.distanceKm,
  });

  factory PaymentLocation.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return PaymentLocation(
      id: id,
      name: (data['name'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }
}

class _PaymentLocationScreenState extends State<PaymentLocationScreen> {
  List<PaymentLocation> _locations = [];

  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String _locationMode = 'none'; // none | gps | address
  String _locationStatusText = '';
  bool _isUpdatingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadLocations().then((_) => _loadFavorites());
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payment_location')
          .get();

      final loadedLocations = snapshot.docs.map((doc) {
        return PaymentLocation.fromFirestore(doc.id, doc.data());
      }).toList();

      if (!mounted) return;

      setState(() {
        _locations = loadedLocations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError('โหลดข้อมูลสถานที่ไม่สำเร็จ: $e');
    }
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite_locations')
        .get();

    final favoriteIds = snap.docs.map((d) => d.id).toSet();

    setState(() {
      for (final loc in _locations) {
        loc.isFavorite = favoriteIds.contains(loc.id);
      }
    });
  }

  void _calculateDistances(double userLat, double userLng) {
    for (final loc in _locations) {
      final distMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        loc.latitude,
        loc.longitude,
      );
      loc.distanceKm = distMeters / 1000;
    }

    setState(() {});
  }

  Future<void> _useGPS() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatusText = 'กำลังหาตำแหน่งของคุณ...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('กรุณาเปิด Location Service ก่อน');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('กรุณาเปิดสิทธิ์ตำแหน่งจากการตั้งค่าเครื่อง');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _calculateDistances(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _locationMode = 'gps';
        _locationStatusText = 'เรียงตามตำแหน่ง GPS ของคุณ';
      });
    } catch (e) {
      _showError('ไม่สามารถหาตำแหน่งได้: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
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
        _showError('ไม่พบข้อมูลใน Profile กรุณากรอกที่อยู่ก่อน');
        return;
      }

      final data = doc.data()!;
      final subdistrict = data['subdistrict']?.toString() ?? '';
      final district = data['district']?.toString() ?? '';
      final province = data['province']?.toString() ?? '';
      final postcode = data['postcode']?.toString() ?? '';

      if (subdistrict.isEmpty &&
          district.isEmpty &&
          province.isEmpty &&
          postcode.isEmpty) {
        _showError('ไม่พบข้อมูลที่อยู่ใน Profile');
        return;
      }

      setState(() {
        _locationStatusText = 'กำลังแปลงที่อยู่เป็นพิกัด...';
      });

      final addressQuery =
          '$subdistrict $district $province $postcode Thailand'
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');

      final result = await locationFromAddress(addressQuery);

      if (result.isEmpty) {
        _showError('ไม่สามารถหาพิกัดจากที่อยู่ได้');
        return;
      }

      final loc = result.first;
      _calculateDistances(loc.latitude, loc.longitude);

      if (!mounted) return;

      setState(() {
        _locationMode = 'address';
        _locationStatusText = 'เรียงตามที่อยู่: $district, $province';
      });
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = false;
      _locationStatusText = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  void _showLocationModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'เรียงตามระยะทาง',
            style: TextStyle(
              fontFamily: 'NotoSansThai',
              fontWeight: FontWeight.w800,
            ),
          ),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavorite(PaymentLocation location) async {
    if (_isUpdatingFavorite) return;
    _isUpdatingFavorite = true;

    setState(() => location.isFavorite = !location.isFavorite);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite_locations')
          .doc(location.id);

      if (location.isFavorite) {
        await favRef.set({'locationId': location.id});
      } else {
        await favRef.delete();
      }
    } catch (e) {
      setState(() => location.isFavorite = !location.isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')),
      );
    } finally {
      _isUpdatingFavorite = false;
    }
  }

  void _openMapPage(PaymentLocation location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationMapScreen(location: location),
      ),
    );
  }

  List<PaymentLocation> _sorted(List<PaymentLocation> list) {
    if (_locationMode == 'none') return list;

    final sorted = List<PaymentLocation>.from(list);
    sorted.sort(
      (a, b) => (a.distanceKm ?? 999999).compareTo(b.distanceKm ?? 999999),
    );
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
                  horizontal: 16,
                  vertical: 8,
                ),
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
                    GestureDetector(
                      onTap: _showLocationModeDialog,
                      child: const Text(
                        'เปลี่ยน',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isLoadingLocation)
              const LinearProgressIndicator(
                color: Color(0xFF4CAF87),
                backgroundColor: Color(0xFFB2DFDB),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _locations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadLocations,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (favorites.isNotEmpty) ...[
                                  const Text(
                                    'รายการโปรด',
                                    style: TextStyle(
                                      fontFamily: 'NotoSansThai',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...favorites.map(_buildLocationCard),
                                  const SizedBox(height: 18),
                                ],
                                const Text(
                                  'สถานที่รับชำระเงินอื่น ๆ',
                                  style: TextStyle(
                                    fontFamily: 'NotoSansThai',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...others.map(_buildLocationCard),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 72,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'ยังไม่มีข้อมูลสถานที่รับชำระเงิน',
                style: TextStyle(
                  fontFamily: 'NotoSansThai',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'กรุณาเพิ่มข้อมูลใน Firestore collection: locations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NotoSansThai',
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
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
                Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.address,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                if (location.distanceKm != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 14,
                        color: Color(0xFF4CAF87),
                      ),
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
            label: const Text(
              'แผนที่',
              style: TextStyle(
                fontFamily: 'NotoSansThai',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6F1FA),
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}