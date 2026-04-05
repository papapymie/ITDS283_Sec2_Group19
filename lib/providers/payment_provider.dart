import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentHistory {
  final DateTime date;
  final double amount;
  final String monthKey;

  PaymentHistory({
    required this.date,
    required this.amount,
    required this.monthKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'monthKey': monthKey,
    };
  }

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      monthKey: json['monthKey'] ?? '',
    );
  }
}

class PaymentProvider extends ChangeNotifier {
  static const String storageKey = 'payment_history_all';

  final List<PaymentHistory> _paymentHistory = [];

  List<PaymentHistory> get paymentHistory => List.unmodifiable(_paymentHistory);

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
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(storageKey);

    _paymentHistory.clear();

    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _paymentHistory.addAll(
          decoded.map(
            (e) => PaymentHistory.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _paymentHistory.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(storageKey, encoded);
  }

  Future<bool> addPayment({
    required DateTime date,
    required double amount,
  }) async {
    final paymentMonth = monthKeyOf(date);
    final isLate = paymentMonth != currentMonthKey();

    _paymentHistory.removeWhere((item) => item.monthKey == paymentMonth);
    _paymentHistory.insert(
      0,
      PaymentHistory(
        date: date,
        amount: amount,
        monthKey: paymentMonth,
      ),
    );

    await saveHistory();
    notifyListeners();

    return isLate;
  }
}