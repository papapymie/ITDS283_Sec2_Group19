import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistory {
  final DateTime date;
  final double amount;
  final String monthKey;

  PaymentHistory({
    required this.date,
    required this.amount,
    required this.monthKey,
  });

  // แปลงจาก Firestore → PaymentHistory
  factory PaymentHistory.fromFirestore(Map<String, dynamic> data) {
    return PaymentHistory(
      date: (data['date'] as Timestamp).toDate(),
      amount: (data['amount'] as num).toDouble(),
      monthKey: data['monthKey'] as String? ?? '',
    );
  }

  // แปลงจาก PaymentHistory → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date), // ← Firebase ใช้ Timestamp ไม่ใช่ String
      'amount': amount,
      'monthKey': monthKey,
    };
  }
}

class PaymentProvider extends ChangeNotifier {
  final List<PaymentHistory> _paymentHistory = [];

  List<PaymentHistory> get paymentHistory => List.unmodifiable(_paymentHistory);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _paymentsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('payments');

  String currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String monthKeyOf(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
  }

  PaymentHistory? get currentMonthPayment {
    try {
      return _paymentHistory.firstWhere(
        (item) => item.monthKey == currentMonthKey(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> loadHistory() async {
    if (_uid == null) return;

    try {
      final snap = await _paymentsRef
          .orderBy('date', descending: true) 
          .get();

      _paymentHistory.clear();
      _paymentHistory.addAll(
        snap.docs.map((doc) =>
            PaymentHistory.fromFirestore(doc.data() as Map<String, dynamic>)),
      );

      notifyListeners();
    } catch (e) {
      print('loadHistory error: $e');
    }
  }

  // ── บันทึกการชำระเงินลง Firebase ──
  Future<bool> addPayment({
    required DateTime date,
    required double amount,
  }) async {
    if (_uid == null) return false;

    final paymentMonth = monthKeyOf(date);
    final isLate = paymentMonth != currentMonthKey();

    try {
      final existing = await _paymentsRef
          .where('monthKey', isEqualTo: paymentMonth)
          .get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }

      final newPayment = PaymentHistory(
        date: date,
        amount: amount,
        monthKey: paymentMonth,
      );
      await _paymentsRef.add(newPayment.toFirestore());

      // อัปเดต local list 
      _paymentHistory.removeWhere((item) => item.monthKey == paymentMonth);
      _paymentHistory.insert(0, newPayment);

      notifyListeners();
      return isLate;
    } catch (e) {
      print('addPayment error: $e');
      return false;
    }
  }
}