import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double totalExpenses = 0.0;
  double totalIncome = 0.0;
  double savingPercentage = 0.0;
  List<String> tips = [];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    final expensesSnapshot = await FirebaseFirestore.instance.collection('expenses').get();
    final incomeSnapshot = await FirebaseFirestore.instance.collection('income').doc('currentUserId').get();

    // حساب إجمالي المصاريف
    totalExpenses = expensesSnapshot.docs.fold(0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0));

    // الحصول على إجمالي الدخل
    if (incomeSnapshot.exists) {
      totalIncome = incomeSnapshot.data()?['monthly_income'] ?? 0.0;
    }

    // حساب نسبة التوفير
    if (totalIncome > 0) {
      savingPercentage = ((totalIncome - totalExpenses) / totalIncome) * 100;
    } else {
      savingPercentage = 0;
    }

    // إعداد نصائح للتقليل من الإنفاق
    tips = _generateSavingsTips();

    setState(() {});
  }

  List<String> _generateSavingsTips() {
    List<String> tipsList = [
      'حدد ميزانية شهرية لكل فئة مصاريف.',
      'تجنب شراء الأشياء غير الضرورية.',
      'استفد من العروض والتخفيضات.',
      'احفظ جزء من الدخل كل شهر.',
      'راقب عاداتك الإنفاقية وحاول تعديلها.',
    ];
    return tipsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقرير النهائي'),
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
            Text('نصائح لتقليل الإنفاق:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            for (var tip in tips) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- $tip', style: TextStyle(fontSize: 16)),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // هنا يمكنك إضافة كود لتصدير التقرير أو إرساله عبر البريد الإلكتروني
              },
              child: Text('تصدير التقرير'),
            ),
          ],
        ),
      ),
    );
  }
}
