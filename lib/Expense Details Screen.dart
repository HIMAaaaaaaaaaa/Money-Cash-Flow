import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  String _searchQuery = '';
  double? _searchAmount;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Details'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildAmountField(),
          _buildDatePicker(),
          Expanded(child: _buildExpenseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Note',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Amount',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _searchAmount = value.isNotEmpty ? double.tryParse(value) : null;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    Query query = FirebaseFirestore.instance.collection('expenses');

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No expenses recorded.'));
        }

        // Filter results based on search query
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final note = doc['note'] ?? '';
          final amount = doc['amount'] ?? 0.0;
          final date = (doc['date'] as Timestamp).toDate();

          bool matchesNote = note.toLowerCase().contains(_searchQuery);
          bool matchesAmount = _searchAmount == null || amount == _searchAmount;
          bool matchesDate = _selectedDate == null || 
              DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate!);

          return matchesNote && matchesAmount && matchesDate;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(child: Text('No matching expenses found.'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var expense = filteredDocs[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('\$${expense['amount'].toStringAsFixed(2)}'),
                subtitle: Text('${expense['category']} - ${expense['note']} - ${DateFormat('yyyy-MM-dd').format((expense['date'] as Timestamp).toDate())}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteExpense(expense.id),
                ),
                onTap: () {
                  // Optional: Navigate to edit expense screen
                },
              ),
            );
          },
        );
      },
    );
  }

  void _deleteExpense(String id) async {
    await FirebaseFirestore.instance.collection('expenses').doc(id).delete();
    print('Expense deleted: $id');
  }
}





