import 'package:flutter/material.dart';

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

  static const double electricityRate = 3.88;
  static const double waterRate = 27.83;

  void _calculate() {
    final elec = double.tryParse(_electricityController.text.trim());
    final water = double.tryParse(_waterController.text.trim());

    if (elec == null || water == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกตัวเลขให้ครบทั้งสองช่อง')),
      );
      return;
    }

    setState(() {
      _electricityCost = elec * electricityRate;
      _waterCost = water * waterRate;
      _totalBill = _electricityCost! + _waterCost!;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A9E82),
        foregroundColor: Colors.white,
        title: const Text(
          'Calculate & Energy',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DEBIT NOTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3A9E82),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('BKK, THAILAND',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('MONTH: 1/2026',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'กรอกข้อมูลการใช้งาน',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3A2E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Electricity input
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

            // Water input
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

            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text(
                  'คำนวณค่าบิล',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A9E82),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // Result section — แสดงหลังกด คำนวณ
            if (_totalBill != null) ...[
              const SizedBox(height: 24),

              _buildResultRow(
                icon: Icons.bolt,
                iconColor: const Color(0xFFFFC107),
                label: 'ค่าไฟฟ้า',
                value: '${_electricityCost!.toStringAsFixed(2)} THB',
              ),
              const SizedBox(height: 10),

              _buildResultRow(
                icon: Icons.water_drop,
                iconColor: const Color(0xFF29B6F6),
                label: 'ค่าน้ำ',
                value: '${_waterCost!.toStringAsFixed(2)} THB',
              ),

              const SizedBox(height: 16),

              // Total bill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BILL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _totalBill!.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A3A2E),
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'THB',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A9E82),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Saving tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF3A9E82).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield, color: Color(0xFF3A9E82), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ELECTRICITY SAVING TIPS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A3A2E),
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.shield, color: Color(0xFF3A9E82), size: 20),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTip(Icons.lightbulb_outline,
                        'ถอดปลั๊กอุปกรณ์ที่ไม่ใช้งานออกจากเต้ารับทุกครั้ง'),
                    const SizedBox(height: 10),
                    _buildTip(Icons.thermostat, 'ปรับแอร์ที่ 26–27°C'),
                    const SizedBox(height: 10),
                    _buildTip(Icons.air, 'หมั่นล้างแอร์เป็นประจำ'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required String rate,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(rate,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A3A2E)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3A2E))),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A9E82))),
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
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A2E))),
        ),
      ],
    );
  }
}
