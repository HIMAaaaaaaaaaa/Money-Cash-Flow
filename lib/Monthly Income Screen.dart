import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyIncomeScreen extends StatefulWidget {
  @override
  _MonthlyIncomeScreenState createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  double? _monthlyIncome;
  double? _dailyAllowance;
  DateTime _incomeDate = DateTime.now();
  String _notes = "";
  List<FlSpot> _incomeData = [];

  final _incomeController = TextEditingController();
  final _allowanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentIncomeAndAllowance();
  }

  Future<void> _fetchCurrentIncomeAndAllowance() async {
    final doc = await FirebaseFirestore.instance.collection('finance').doc('monthly_income').get();
    if (doc.exists) {
      setState(() {
        _monthlyIncome = doc.data()?['monthly_income']?.toDouble();
        _dailyAllowance = doc.data()?['daily_allowance']?.toDouble();
        _incomeController.text = _monthlyIncome?.toString() ?? '';
        _allowanceController.text = _dailyAllowance?.toString() ?? '';
      });
      _fetchIncomeData(); // Fetch income data for the chart
    }
  }

  Future<void> _fetchIncomeData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('finance').doc('monthly_income').collection('daily_income').get();
    setState(() {
      _incomeData = querySnapshot.docs.map((doc) {
        final date = doc.data()['date'].toDate();
        final amount = doc.data()['amount']?.toDouble() ?? 0;
        return FlSpot(date.day.toDouble(), amount);
      }).toList();
    });
  }

  Future<void> _saveIncomeAndAllowance() async {
    double? income = double.tryParse(_incomeController.text);
    double? allowance = double.tryParse(_allowanceController.text);

    if (income != null && allowance != null) {
      await FirebaseFirestore.instance.collection('finance').doc('monthly_income').set({
        'monthly_income': income,
        'daily_allowance': allowance,
        'income_date': _incomeDate.toIso8601String(),
        'notes': _notes,
      });
      await _saveDailyIncome(); // Save daily income for the chart
      _checkDailyExpense(allowance); // Check daily expenses
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Income and allowance saved successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid values!')));
    }
  }

  Future<void> _saveDailyIncome() async {
    await FirebaseFirestore.instance.collection('finance').doc('monthly_income').collection('daily_income').add({
      'date': _incomeDate,
      'amount': _monthlyIncome,
    });
    await _fetchIncomeData(); // Update the chart data
  }

  void _checkDailyExpense(double allowance) {
    // Dummy data to demonstrate daily expenses
    double dailyExpense = 100; // This should come from your expenses data

    if (dailyExpense > allowance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Warning: Daily expenses exceed your allowance!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(
                labelText: 'Monthly Income',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _allowanceController,
              decoration: InputDecoration(
                labelText: 'Daily Allowance',
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
            SizedBox(height: 16),
            Text("Select Income Date:"),
            Row(
              children: [
                Text(DateFormat('yyyy-MM-dd').format(_incomeDate)),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _incomeDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _incomeDate) {
                      setState(() {
                        _incomeDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIncomeAndAllowance,
              child: Text('Save'),
            ),
            SizedBox(height: 20),
            Text('Income Distribution Chart', style: TextStyle(fontSize: 18)),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 1,
                  maxX: 31,
                  minY: 0,
                  maxY: _incomeData.isNotEmpty ? _incomeData.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 200,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _incomeData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
