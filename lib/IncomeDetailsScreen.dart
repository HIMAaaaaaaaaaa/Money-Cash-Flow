import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeDetailsScreen extends StatefulWidget {
  @override
  _IncomeDetailsScreenState createState() => _IncomeDetailsScreenState();
}

class _IncomeDetailsScreenState extends State<IncomeDetailsScreen> {
  List<QueryDocumentSnapshot> _incomeList = [];
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? userId;

  @override
  void initState() {
    super.initState();
    // الحصول على userId للمستخدم الحالي
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchIncomeData();
  }

  // Fetch all income data from Firestore based on userId
  Future<void> _fetchIncomeData({String? amount, String? notes, DateTime? date}) async {
    if (userId == null) return;

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc('monthly_income')
        .collection('daily_income');

    if (amount != null && amount.isNotEmpty) {
      query = query.where('amount', isEqualTo: double.tryParse(amount));
    }

    if (notes != null && notes.isNotEmpty) {
      query = query.where('notes', isEqualTo: notes);
    }

    if (date != null) {
      // Filtering based on exact date
      Timestamp startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
      Timestamp endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
      query = query.where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay);
    }

    final snapshot = await query.get();
    setState(() {
      _incomeList = snapshot.docs;
    });
  }

  // Widget to display the income list with search filters
  Widget _buildIncomeList() {
    return ListView.builder(
      itemCount: _incomeList.length,
      itemBuilder: (context, index) {
        final income = _incomeList[index].data() as Map<String, dynamic>;
        final date = (income['date'] as Timestamp).toDate();
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        final amount = income['amount'] ?? 0.0;
        final notes = income['notes'] ?? 'No notes';

        return ListTile(
          title: Text('\$${amount.toString()}'),
          subtitle: Text('Date: $formattedDate\nNotes: $notes'),
        );
      },
    );
  }

  // Show date picker to select a date for filtering
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _fetchIncomeData(date: pickedDate);
    }
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Details'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Search by Amount',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _fetchIncomeData(
                        amount: value,
                        notes: _notesController.text,
                        date: _selectedDate,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Search by Notes',
                    ),
                    onChanged: (value) {
                      _fetchIncomeData(
                        amount: _amountController.text,
                        notes: value,
                        date: _selectedDate,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Date Picker Button
            ElevatedButton(
              onPressed: _selectDate,
              child: Text('Select Date'),
            ),
            SizedBox(height: 16),
            // Display the filtered income list
            Expanded(child: _buildIncomeList()),
          ],
        ),
      ),
    );
  }
}

