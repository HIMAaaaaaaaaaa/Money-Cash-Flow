import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
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
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note (optional)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() async {
    if (_amountController.text.isNotEmpty && _selectedCategory != null) {
      double amount = double.tryParse(_amountController.text) ?? 0.0;
      String note = _noteController.text;

      // إضافة المصروفات إلى Firestore
      await FirebaseFirestore.instance.collection('expenses').add({
        'amount': amount,
        'category': _selectedCategory,
        'note': note,
        'date': DateTime.now(),
      });

      // تنظيف الحقول بعد الإضافة
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCategory = null;
      });

      // رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully!')),
      );
    } else {
      // رسالة خطأ في حال عدم اكتمال البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields.')),
      );
    }
  }
}

