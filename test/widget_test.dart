import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:electric_home/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const ElectricHomeApp());

    // ตรวจสอบว่าหน้า Login แสดงขึ้นมา
    expect(find.text('ELECTRIC HOME'), findsOneWidget);
  });
}