import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalculateScreen extends StatefulWidget {
  const CalculateScreen({super.key});

  @override
  State<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();

  double? _totalBill;
  double? _electricityCost;
  double? _waterCost;

  // ตัวแปรสำหรับระบบเปรียบเทียบ
  double? _lastBillTotal;
  String _comparisonMessage = "";
  Color _comparisonColor = Colors.grey;

  String _locationDisplay = "BKK, THAILAND"; 

  static const double electricityRate = 3.88;
  static const double waterRate = 27.83;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        String province = data?['province'] ?? 'BKK';
        String district = data?['district'] ?? 'THAILAND';
        setState(() {
          _locationDisplay = "${district.toUpperCase()}, ${province.toUpperCase()}";
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    final elec = double.tryParse(_electricityController.text.trim());
    final water = double.tryParse(_waterController.text.trim());

    if (elec == null || water == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกตัวเลขให้ครบทั้งสองช่อง')),
      );
      return;
    }

    final elecCost = elec * electricityRate;
    final waterCost = water * waterRate;
    final total = elecCost + waterCost;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // --- 🔍 จุดที่แก้ไข: ดึงบิลล่าสุดแบบชัวร์ๆ ---
        final snapshot = await FirebaseFirestore.instance
            .collection('electricity_usage')
            .where('user_id', isEqualTo: user.uid)
            .get(); // ดึงมาก่อนแล้วค่อยเรียงในโค้ดเพื่อเลี่ยงปัญหา Index

        if (snapshot.docs.isNotEmpty) {
          // เรียงลำดับตาม recorded_at จากใหม่ไปเก่าในฝั่ง App
          final docs = snapshot.docs;
          docs.sort((a, b) {
            Timestamp t1 = a['recorded_at'] ?? Timestamp.now();
            Timestamp t2 = b['recorded_at'] ?? Timestamp.now();
            return t2.compareTo(t1);
          });

          _lastBillTotal = docs.first.data()['total'];
          
          if (total < _lastBillTotal!) {
            _comparisonMessage = "🎉 ยินดีด้วย! บิลรอบนี้ประหยัดกว่าครั้งก่อน ${(_lastBillTotal! - total).toStringAsFixed(2)} THB";
            _comparisonColor = const Color(0xFF3A9E82);
          } else if (total > _lastBillTotal!) {
            _comparisonMessage = "📈 บิลรอบนี้สูงกว่าเดิม พยายามประหยัดอีกนิดนะ!";
            _comparisonColor = Colors.orange.shade800;
          } else {
            _comparisonMessage = "⚖️ ยอดเท่าเดิมเลย รักษามาตรฐานไว้นะ!";
            _comparisonColor = Colors.blue.shade700;
          }
        } else {
          _comparisonMessage = "✨ บันทึกบิลครั้งแรก มาเริ่มประหยัดไฟกัน!";
          _comparisonColor = const Color(0xFF3A9E82);
        }

        // บันทึกข้อมูลปัจจุบัน
        await FirebaseFirestore.instance.collection('electricity_usage').add({
          'user_id': user.uid,
          'electricity_units': elec,
          'water_units': water,
          'electricity_cost': elecCost,
          'water_cost': waterCost,
          'total': total,
          'location': _locationDisplay,
          'recorded_at': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Comparison Error: $e");
      }
    }

    setState(() {
      _electricityCost = elecCost;
      _waterCost = waterCost;
      _totalBill = total;
    });
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FAF4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A9E82),
          foregroundColor: Colors.white,
          title: const Text('Calculate & Energy', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DEBIT NOTE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DEBIT NOTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3A9E82))),
                      const SizedBox(height: 4),
                      Text(_locationDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text('MONTH: 1/2026', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildInputCard(
                  controller: _electricityController,
                  icon: Icons.bolt,
                  iconColor: const Color(0xFFFFC107),
                  label: 'หน่วยไฟฟ้าที่ใช้ (KWH)',
                  hint: 'เช่น 127',
                  rate: 'อัตรา ${electricityRate.toStringAsFixed(2)} THB / KWH',
                  cardColor: const Color(0xFFE8F5E9),
                ),
                const SizedBox(height: 14),
                _buildInputCard(
                  controller: _waterController,
                  icon: Icons.water_drop,
                  iconColor: const Color(0xFF29B6F6),
                  label: 'หน่วยน้ำที่ใช้ (UNIT)',
                  hint: 'เช่น 2',
                  rate: 'อัตรา ${waterRate.toStringAsFixed(2)} THB / UNIT',
                  cardColor: const Color(0xFFE3F2FD),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A9E82),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('คำนวณค่าบิล', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                if (_totalBill != null) ...[
                  const SizedBox(height: 24),
                  
                  // --- ส่วนเปรียบเทียบ (Message Card) ---
                  if (_comparisonMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _comparisonColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _comparisonColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_lastBillTotal != null && _totalBill! < _lastBillTotal!) 
                                ? Icons.stars_rounded : Icons.info_outline,
                            color: _comparisonColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _comparisonMessage,
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold, 
                                color: _comparisonColor
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildResultRow(Icons.bolt, const Color(0xFFFFC107), 'ค่าไฟฟ้า', '${_electricityCost!.toStringAsFixed(2)} THB'),
                  const SizedBox(height: 10),
                  _buildResultRow(Icons.water_drop, const Color(0xFF29B6F6), 'ค่าน้ำ', '${_waterCost!.toStringAsFixed(2)} THB'),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL BILL', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_totalBill!.toStringAsFixed(2), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 6),
                            const Text('THB', style: TextStyle(color: Color(0xFF3A9E82), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('ELECTRICITY SAVING TIPS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF3A9E82))),
                  const SizedBox(height: 14),
                  _buildTip(Icons.lightbulb_outline, 'ถอดปลั๊กอุปกรณ์ที่ไม่ใช้งานออกเสมอ'),
                  const SizedBox(height: 10),
                  _buildTip(Icons.thermostat, 'ปรับแอร์ที่ 26 องศาเซลเซียส'),
                  const SizedBox(height: 10),
                  _buildTip(Icons.air, 'หมั่นล้างแอร์เป็นประจำทุก 6 เดือน'),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ); 
  }

  // --- Widgets ย่อยเหมือนเดิม ---
  Widget _buildInputCard({required TextEditingController controller, required IconData icon, required Color iconColor, required String label, required String hint, required String rate, required Color cardColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: iconColor, size: 18), const SizedBox(width: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
          Text(rate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint, border: InputBorder.none)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A9E82))),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3A9E82), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A2E))),
        ),
      ],
    );
  }
}