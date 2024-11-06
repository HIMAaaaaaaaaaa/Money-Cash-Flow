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

    setState(() {
      // حساب إجمالي المصاريف
      totalExpenses = expensesSnapshot.docs.fold(0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0));

      // الحصول على إجمالي الدخل
totalIncome = incomeSnapshot.exists && incomeSnapshot.data() != null? incomeSnapshot.data()!['monthly_income'] ?? 0.0 : 0.0;

      // حساب نسبة التوفير
      savingPercentage = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

      // تحديث النصائح بناءً على نسبة التوفير
      tips = _generateSavingsTips();
    });
  }

  List<String> _generateSavingsTips() {
    List<String> tipsList = [];

    if (totalIncome > totalExpenses) {
      // النصائح في حالة أن الدخل أكثر من النفقات
      tipsList = [
        'جيد جدًا! حافظ على هذا الأداء، وحاول زيادة نسبة التوفير.',
        'قم باستثمار جزء من الدخل لزيادة الموارد المالية المستقبلية.',
        'احفظ جزء من الدخل كمدخرات للطوارئ.',
      ];
    } else if (totalExpenses > totalIncome) {
      // النصائح في حالة أن النفقات أكثر من الدخل
      tipsList = [
        'حاول تقليل الإنفاق على الأشياء غير الضرورية.',
        'حدد ميزانية شهرية واضحة لكل فئة مصاريف.',
        'تجنب الإنفاق العشوائي وراقب عاداتك الإنفاقية.',
        'استفد من العروض والتخفيضات لتقليل النفقات.',
      ];
    } else {
      // نصائح عامة إذا كان الدخل يساوي تقريبًا النفقات
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
