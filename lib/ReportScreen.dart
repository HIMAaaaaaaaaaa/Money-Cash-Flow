import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double totalExpenses = 0.0; // لتخزين إجمالي المصاريف
  double totalIncome = 0.0; // لتخزين إجمالي الدخل
  double savingPercentage = 0.0; // لتخزين نسبة التوفير
  double? monthlyIncome; // لتخزين الدخل الشهري من Firebase
  double? dailyAllowance; // لتخزين بدل يومي من Firebase
  List<String> tips = []; // لتخزين النصائح بناءً على نسبة التوفير
  String? userId; // لتخزين معرّف المستخدم من Firebase

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid; // الحصول على معرّف المستخدم الحالي
    _fetchReportData(); // استرجاع البيانات الخاصة بالتقرير المالي
  }

  // دالة لجلب بيانات التقرير المالي من Firebase
  Future<void> _fetchReportData() async {
    if (userId == null) return; // إذا لم يكن هناك معرّف مستخدم، الخروج من الدالة

    // استرجاع البيانات الخاصة بالمصاريف
    final expensesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    // استرجاع البيانات الخاصة بالدخل الشهري
    final incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc('monthly_income')
        .get();

    setState(() {
      // حساب إجمالي المصاريف
      totalExpenses = expensesSnapshot.docs.fold(0.0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0));

      // جلب الدخل الشهري من البيانات المحفوظة
      if (incomeSnapshot.exists) {
        monthlyIncome = incomeSnapshot.data()?['monthly_income']?.toDouble();
        dailyAllowance = incomeSnapshot.data()?['daily_allowance']?.toDouble();
      }

      // تعيين إجمالي الدخل
      totalIncome = monthlyIncome ?? 0.0;

      // حساب نسبة التوفير بناءً على إجمالي الدخل والمصاريف
      savingPercentage = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

      // تحديث النصائح بناءً على نسبة التوفير
      tips = _generateSavingsTips();
    });
  }

  // دالة لتوليد النصائح بناءً على مقارنة الدخل بالمصاريف
  List<String> _generateSavingsTips() {
    List<String> tipsList = [];

    if (totalIncome > totalExpenses) {
      // إذا كان الدخل أكبر من المصاريف
      tipsList = [
        'جيد جدًا! حافظ على هذا الأداء، وحاول زيادة نسبة التوفير.',
        'قم باستثمار جزء من الدخل لزيادة الموارد المالية المستقبلية.',
        'احفظ جزء من الدخل كمدخرات للطوارئ.',
      ];
    } else if (totalExpenses > totalIncome) {
      // إذا كانت المصاريف أكبر من الدخل
      tipsList = [
        'حاول تقليل الإنفاق على الأشياء غير الضرورية.',
        'حدد ميزانية شهرية واضحة لكل فئة مصاريف.',
        'تجنب الإنفاق العشوائي وراقب عاداتك الإنفاقية.',
        'استفد من العروض والتخفيضات لتقليل النفقات.',
      ];
    } else {
      // إذا كان الدخل يساوي المصاريف
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
        title: Text('التقرير المالي'), // عنوان الصفحة
        automaticallyImplyLeading: false, // لإزالة زر العودة
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // إضافة هوامش حول المحتوى
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // محاذاة المحتوى لليمين
          children: [
            // عرض إجمالي المصاريف
            Text('إجمالي المصاريف: \$${totalExpenses.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10), // مسافة بين العناصر
            // عرض إجمالي الدخل
            Text('إجمالي الدخل: \$${totalIncome.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            // عرض نسبة التوفير
            Text('نسبة التوفير: ${savingPercentage.toStringAsFixed(2)}%', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // عنوان النصائح
            Text('نصائح لتحسين الأداء المالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // عرض النصائح
            for (var tip in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- $tip', style: TextStyle(fontSize: 16)),
              ),
            Spacer(), // لتوزيع المسافة المتبقية بين النصائح
          ],
        ),
      ),
    );
  }
}


