import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // لا تنسَ استيراد FirebaseAuth

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // تعريف متغيرات للتحكم في المدخلات
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  
  // قائمة الفئات المتاحة للمصروفات
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // عنوان الصفحة
        title: Text('Add Expense'),
        automaticallyImplyLeading: false, // تعطيل زر العودة
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField لإدخال المبلغ
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number, // تحديد نوع الإدخال ليكون أرقام فقط
            ),
            SizedBox(height: 16),
            
            // DropdownButtonFormField لاختيار الفئة
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                // تحديث الفئة المحددة عند تغيير الاختيار
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 16),

            // TextField لإدخال الملاحظة (اختياري)
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note (optional)'),
            ),
            SizedBox(height: 16),
            
            // زر إضافة المصروف
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لإضافة المصروفات إلى Firebase
  void _addExpense() async {
    // التحقق من المدخلات (المبلغ والفئة)
    if (_amountController.text.isNotEmpty && _selectedCategory != null) {
      // تحويل المبلغ المدخل إلى قيمة عددية
      double amount = double.tryParse(_amountController.text) ?? 0.0;
      String note = _noteController.text;

      // جلب معرف المستخدم الحالي من Firebase
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        // إذا لم يكن المستخدم مسجل دخول، إظهار رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      // إضافة المصروف إلى Firebase في مجموعة المصروفات الخاصة بالمستخدم
      await FirebaseFirestore.instance
          .collection('users') // مجموعة المستخدمين
          .doc(userId) // تحديد مستند المستخدم بناءً على معرف المستخدم
          .collection('expenses') // مجموعة المصروفات الخاصة بالمستخدم
          .add({
        'amount': amount, // المبلغ
        'category': _selectedCategory, // الفئة
        'note': note, // الملاحظة
        'date': DateTime.now(), // التاريخ الحالي
      });

      // تنظيف الحقول بعد إضافة المصروف
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCategory = null; // إعادة تعيين الفئة المحددة
      });

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully!')),
      );
    } else {
      // إظهار رسالة خطأ إذا كانت المدخلات غير مكتملة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields.')),
      );
    }
  }
}




