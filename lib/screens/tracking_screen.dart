import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _status = 'unpaid';
  DateTime? selectedDate;
  final TextEditingController amountController = TextEditingController();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPaymentData();
    });
  }

  Future<void> _initPaymentData() async {
    final provider = context.read<PaymentProvider>();
    await provider.loadHistory();

    final currentPayment = provider.currentMonthPayment;

    if (!mounted) return;

    setState(() {
      if (currentPayment != null) {
        _status = 'paid';
        selectedDate = currentPayment.date;
        amountController.text = currentPayment.amount.toStringAsFixed(0);
      } else {
        _status = 'unpaid';
        selectedDate = null;
        amountController.clear();
      }
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _onTapBag() {
    setState(() {
      _status = 'confirming';
    });
  }

  Future<void> _confirmPayment() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันที่ชำระเงิน')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกจำนวนเงินให้ถูกต้อง')),
      );
      return;
    }

    final provider = context.read<PaymentProvider>();

    final isLate = await provider.addPayment(
      date: selectedDate!,
      amount: amount,
    );

    if (!mounted) return;

    setState(() {
      _status = isLate ? 'late' : 'paid';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLate ? 'ชำระเงินย้อนหลังสำเร็จ!' : 'บันทึกการชำระเงินเรียบร้อยแล้ว',
        ),
        backgroundColor: isLate ? Colors.orange : Colors.green,
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
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
    );
  }

  Widget _buildUnpaidCard() {
    return GestureDetector(
      onTap: _onTapBag,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFDCEAF4),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Image.asset(
                'assets/images/not_payment.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กดเพื่อยืนยันการชำระเงิน',
              style: TextStyle(fontSize: 12, color: Color(0xFF4A6360)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmingCard() {
    return Column(
      children: [
        Container(
          width: 210,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFD9F2C4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Text(
                'ยืนยันการชำระเงิน',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: Image.asset(
                  'assets/images/payment_completed.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: _pickDate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF194D8C),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              selectedDate == null
                  ? 'วัน/เดือน/ปี ที่ชำระเงิน'
                  : dateFormat.format(selectedDate!),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'กรอกจำนวนเงินที่ชำระ',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 170,
          child: ElevatedButton(
            onPressed: _confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF194D8C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('ยืนยัน'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaidCard() {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F2C4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text(
            'ชำระเงินแล้ว !',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: Image.asset(
              'assets/images/payment_completed.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateCard() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'ชำระเงินย้อนหลังสำเร็จ\nอย่าลืมชำระเงินเดือนนี้นะ!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE65100),
            ),
          ),
        ),
        GestureDetector(
          onTap: _onTapBag,
          child: Container(
            width: 210,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEAF4),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    'assets/images/not_payment.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'กดเพื่อชำระเงินเดือนนี้',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4A6360)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(PaymentHistory item, String currentMonthKey) {
    final isCurrentMonth = item.monthKey == currentMonthKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? const Color(0xFFD9F2C4)
            : const Color(0xFFCDEFFC),
        borderRadius: BorderRadius.circular(24),
        border: isCurrentMonth
            ? Border.all(color: const Color(0xFF4CAF87), width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(item.date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF35556A),
                ),
              ),
              if (isCurrentMonth)
                const Text(
                  'เดือนนี้',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF87),
                  ),
                ),
            ],
          ),
          Text(
            '${item.amount.toStringAsFixed(0)} บาท',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(PaymentProvider provider) {
    final currentPayment = provider.currentMonthPayment;

    if (currentPayment != null) {
      return _buildPaidCard(); 
    }

    if (_status == 'confirming') {
      return _buildConfirmingCard();
    }

    if (_status == 'late') {
      return _buildLateCard();
    }

    return _buildUnpaidCard(); 
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        final history = provider.paymentHistory;
        final currentMonthKey = provider.currentMonthKey();

        return Scaffold(
          backgroundColor: const Color(0xFFF3F3F3),
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFCFEFFF),
                ),
                Column(
                  children: [
                    _buildHeaderBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'PAYMENT TRACKING',
                                  style: TextStyle(
                                    fontFamily: 'Koulen',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatusSection(provider),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/payment_location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF184A86),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: const Icon(Icons.location_on_outlined),
                              label: const Text('ดูสถานที่รับชำระเงิน'),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height - 250,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(40),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  const Text(
                                    'ประวัติการชำระเงิน',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  history.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.all(40),
                                          child: Text('ยังไม่มีประวัติการชำระเงิน'),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          itemCount: history.length,
                                          itemBuilder: (context, index) {
                                            return _buildHistoryItem(
                                              history[index],
                                              currentMonthKey,
                                            );
                                          },
                                        ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}