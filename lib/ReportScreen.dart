import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double totalExpenses = 0.0;
  double totalIncome = 0.0;
  double savingPercentage = 0.0;
  double? monthlyIncome;
  double? dailyAllowance;
  List<String> tips = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchReportData();
  }


  Future<void> _fetchReportData() async {
    if (userId == null) return;

    // استرجاع المصاريف بناءً على userId
    final expensesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    // استرجاع الدخل الشهري بناءً على userId
    final incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc('monthly_income')
        .get();

    setState(() {
      // حساب إجمالي المصاريف
      totalExpenses = expensesSnapshot.docs.fold(0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0));

      // الحصول على إجمالي الدخل من صفحة الدخل الشهري
      if (incomeSnapshot.exists) {
        monthlyIncome = incomeSnapshot.data()?['monthly_income']?.toDouble();
        dailyAllowance = incomeSnapshot.data()?['daily_allowance']?.toDouble();
      }
      totalIncome = monthlyIncome ?? 0.0;

      // حساب نسبة التوفير
      savingPercentage = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

      // تحديث النصائح بناءً على نسبة التوفير
      tips = _generateSavingsTips();
    });
  }

  List<String> _generateSavingsTips() {
    List<String> tipsList = [];

    if (totalIncome > totalExpenses) {
      tipsList = [
        'جيد جدًا! حافظ على هذا الأداء، وحاول زيادة نسبة التوفير.',
        'قم باستثمار جزء من الدخل لزيادة الموارد المالية المستقبلية.',
        'احفظ جزء من الدخل كمدخرات للطوارئ.',
      ];
    } else if (totalExpenses > totalIncome) {
      tipsList = [
        'حاول تقليل الإنفاق على الأشياء غير الضرورية.',
        'حدد ميزانية شهرية واضحة لكل فئة مصاريف.',
        'تجنب الإنفاق العشوائي وراقب عاداتك الإنفاقية.',
        'استفد من العروض والتخفيضات لتقليل النفقات.',
      ];
    } else {
      tipsList = [
        'حافظ على توازن بين الدخل والمصاريف.',
        'فكر في طرق لزيادة دخلك إذا كانت المصاريف ثابتة.',
        'حاول تخصيص جزء للتوفير حتى مع توازن الدخل والمصاريف.',
      ];
    }

    return tipsList;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقرير المالي'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إجمالي المصاريف: \$${totalExpenses.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('إجمالي الدخل: \$${totalIncome.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('نسبة التوفير: ${savingPercentage.toStringAsFixed(2)}%', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('نصائح لتحسين الأداء المالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            for (var tip in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- $tip', style: TextStyle(fontSize: 16)),
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

