import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // تأكد من استيراد FirebaseAuth

class MonthlyIncomeScreen extends StatefulWidget {
  @override
  _MonthlyIncomeScreenState createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  // متغير لتخزين الدخل الشهري الحالي
  double _monthlyIncome = 0.0;
  
  // متغير لتخزين الملاحظات التي يضيفها المستخدم
  String _notes = "";

  // متغير للتحكم في TextField الخاص بإدخال الدخل
  final _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentMonthlyIncome(); // استدعاء الدالة لتحميل الدخل الشهري الحالي عند بدء الشاشة
  }

  // دالة لقراءة الدخل الشهري الحالي من قاعدة البيانات (Firestore)
  Future<void> _fetchCurrentMonthlyIncome() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid; // الحصول على الـ userId من الـ Firebase
    if (userId == null) return; // إذا كان المستخدم غير مسجل الدخول، نوقف العملية

    // قراءة البيانات من Firestore لجلب الدخل الشهري
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc('monthly_income')
        .get();

    if (doc.exists) {
      setState(() {
        _monthlyIncome = doc.data()?['monthly_income']?.toDouble() ?? 0.0;
      });
    }
  }

  // دالة لإضافة دخل جديد
  Future<void> _addNewIncome() async {
    // محاولة تحويل الدخل المدخل إلى قيمة عددية من نوع double
    double? newIncome = double.tryParse(_incomeController.text);
    if (newIncome != null && newIncome > 0) {
      // إذا كانت القيمة المدخلة صحيحة وغير صفرية، نضيفها إلى الدخل الشهري الحالي
      setState(() {
        _monthlyIncome += newIncome;
      });

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return; // إذا كان المستخدم غير مسجل الدخول، نوقف العملية

      // حفظ الدخل الشهري الجديد في قاعدة البيانات (Firestore)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('incomes')
          .doc('monthly_income')
          .set({
        'monthly_income': _monthlyIncome,
      });

      // إضافة الدخل اليومي إلى مجموعة فرعية داخل قاعدة البيانات مع ملاحظات المستخدم
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('incomes')
          .doc('monthly_income')
          .collection('daily_income')
          .add({
        'date': DateTime.now(),
        'amount': newIncome,
        'notes': _notes,
      });

      // تنظيف حقل الإدخال بعد إضافة الدخل
      _incomeController.clear();

      // إظهار رسالة تأكيد للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Income added successfully!')));
    } else {
      // إذا كانت القيمة المدخلة غير صحيحة أو صفرية، نعرض رسالة خطأ
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid amount!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Monthly Income'),
        automaticallyImplyLeading: false, // إزالة زر الرجوع
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل نصي لإدخال قيمة الدخل الشهري
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(
                labelText: 'Income Amount', // نص الحقل
                border: OutlineInputBorder(),
                prefixText: '\$', // إضافة الرمز \$ قبل القيمة
              ),
              keyboardType: TextInputType.number, // تعيين نوع الإدخال لرقم
            ),
            SizedBox(height: 16), // إضافة مسافة بين الحقول
            // حقل نصي لإدخال الملاحظات
            TextField(
              decoration: InputDecoration(
                labelText: 'Notes', // نص الحقل
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _notes = value; // تحديث الملاحظات عند التغيير
              },
            ),
            SizedBox(height: 20),
            // زر لإضافة الدخل
            ElevatedButton(
              onPressed: _addNewIncome, // عند الضغط، يتم استدعاء دالة إضافة الدخل
              child: Text('Add Income'),
            ),
            SizedBox(height: 20),
            // عرض الدخل الشهري الإجمالي
            Text(
              'Total Monthly Income: \$$_monthlyIncome',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}



