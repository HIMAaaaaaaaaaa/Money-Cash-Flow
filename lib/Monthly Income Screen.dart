import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyIncomeScreen extends StatefulWidget {
  @override
  _MonthlyIncomeScreenState createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  double _monthlyIncome = 0.0;
  String _notes = "";

  final _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentMonthlyIncome();
  }

  Future<void> _fetchCurrentMonthlyIncome() async {
    final doc = await FirebaseFirestore.instance
        .collection('finance')
        .doc('monthly_income')
        .get();
    if (doc.exists) {
      setState(() {
        _monthlyIncome = doc.data()?['monthly_income']?.toDouble() ?? 0.0;
      });
    }
  }

  Future<void> _addNewIncome() async {
    double? newIncome = double.tryParse(_incomeController.text);
    if (newIncome != null && newIncome > 0) {
      // Update total monthly income
      setState(() {
        _monthlyIncome += newIncome;
      });

      // Save the updated income in the database
      await FirebaseFirestore.instance
          .collection('finance')
          .doc('monthly_income')
          .update({
        'monthly_income': _monthlyIncome,
      });

      // Add the new income entry to daily income collection
      await FirebaseFirestore.instance
          .collection('finance')
          .doc('monthly_income')
          .collection('daily_income')
          .add({
        'date': DateTime.now(),
        'amount': newIncome,
        'notes': _notes,
      });

      // Clear the input field and show success message
      _incomeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Income added successfully!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid amount!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Monthly Income'),
                automaticallyImplyLeading: false, // This removes the back button

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(
                labelText: 'Income Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _notes = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNewIncome,
              child: Text('Add Income'),
            ),
            SizedBox(height: 20),
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

