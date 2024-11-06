import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  @override
  _FinancialAnalysisScreenState createState() =>
      _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  List<double> _weeklyExpenses = [];
  List<double> _monthlyExpenses = [];
  double _monthlyIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch monthly income
    final incomeDoc = await FirebaseFirestore.instance
        .collection('finance')
        .doc('monthly_income')
        .get();
    if (incomeDoc.exists) {
      setState(() {
        _monthlyIncome = incomeDoc.data()?['monthly_income']?.toDouble() ?? 0.0;
      });
    }

    // Fetch expenses (Assuming expenses are stored with a date)
    final expensesSnapshot =
        await FirebaseFirestore.instance.collection('expenses').get();
    List<double> weeklyData = List.filled(7, 0.0); // 7 days for weekly analysis
    List<double> monthlyData =
        List.filled(12, 0.0); // 12 months for monthly analysis

    for (var expense in expensesSnapshot.docs) {
      DateTime date = (expense.data()['date'] as Timestamp).toDate();
      double amount = expense.data()['amount']?.toDouble() ?? 0.0;

      // Weekly Analysis
      int dayOfWeek = date.weekday - 1; // 0 = Monday, 6 = Sunday
      weeklyData[dayOfWeek] += amount;

      // Monthly Analysis
      int monthIndex = date.month - 1; // 0 = January, 11 = December
      monthlyData[monthIndex] += amount;
    }

    setState(() {
      _weeklyExpenses = weeklyData;
      _monthlyExpenses = monthlyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Analysis'),
      ),
      body: SingleChildScrollView(
        // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the start
            children: [
              Text(
                'Weekly Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                              toY: _weeklyExpenses[index], color: Colors.blue),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Monthly Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(12, (index) {
                          return FlSpot(
                              index.toDouble(), _monthlyExpenses[index]);
                        }),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 4,
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: List.generate(12, (index) {
                          return FlSpot(index.toDouble(), _monthlyIncome);
                        }),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 4,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Comparison: Income vs Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Monthly Income: \$${_monthlyIncome.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Total Monthly Expenses: \$${_monthlyExpenses.reduce((a, b) => a + b).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
