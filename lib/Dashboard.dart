import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_money_cash_flow/AddExpenseScreen.dart';
import 'package:flutter_application_money_cash_flow/Expense%20Details%20Screen.dart';
import 'package:flutter_application_money_cash_flow/Financial%20Analysis%20Screen.dart';
import 'package:flutter_application_money_cash_flow/Monthly%20Income%20Screen.dart';
import 'package:flutter_application_money_cash_flow/ReportScreen.dart';
import 'package:flutter_application_money_cash_flow/SettingsScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    AddExpenseScreen(),
    ExpenseDetailsScreen(),
    MonthlyIncomeScreen(),
    FinancialAnalysisScreen(),
    SettingsScreen(),
    ReportScreen(),
  ];

  final List<Color> _iconColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.yellow,
  ];

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text('Dashboard'),
            )
          : null, // لا تظهر العنوان في الصفحات الأخرى
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Color(0xFF004D40),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_pages.length, (index) {
            return IconButton(
              icon: Icon(
                _getIconForIndex(index),
                color: _currentIndex == index ? Colors.white : _iconColors[index],
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = index;
                });
              },
            );
          }),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.add;
      case 2:
        return Icons.details;
      case 3:
        return Icons.money;
      case 4:
        return Icons.analytics;
      case 5:
        return Icons.settings;
      case 6:
        return Icons.report;
      default:
        return Icons.dashboard;
    }
  }
}

class DashboardContent extends StatelessWidget {
  final double dailyExpenses = 150.0;
  final double weeklyExpenses = 1050.0;
  final double monthlyExpenses = 4200.0;
  final double totalIncome = 5000.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No expenses added yet.'));
        }

        // حساب مجموع المصروفات لكل فئة
        Map<String, double> categoryTotals = {};
        snapshot.data!.docs.forEach((doc) {
          String category = doc['category'];
          double amount = doc['amount'];
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        });

        double totalExpense = categoryTotals.values.fold(0, (sum, item) => sum + item);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('finance').doc('monthly_income').snapshots(),
          builder: (context, incomeSnapshot) {
            if (incomeSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!incomeSnapshot.hasData || !incomeSnapshot.data!.exists) {
              return Center(child: Text('No income data available.'));
            }

            final incomeData = incomeSnapshot.data!.data() as Map<String, dynamic>;
            double monthlyIncome = incomeData['monthly_income']?.toDouble() ?? 0;
            double dailyAllowance = incomeData['daily_allowance']?.toDouble() ?? 0;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIncomeOverview(totalExpense, monthlyIncome, dailyAllowance),
                    SizedBox(height: 20),
                    _buildExpenseSummary(),
                    SizedBox(height: 20),
                    _buildExpenseChart(categoryTotals, totalExpense), // إضافة فلو شارت
                    SizedBox(height: 20),
                    _buildExpenseList(snapshot),
                    SizedBox(height: 20),
                    _buildTipsAndAlerts(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomeOverview(double totalExpense, double monthlyIncome, double dailyAllowance) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Total Income: \$${monthlyIncome.toStringAsFixed(2)}'),
            Text('Daily Allowance: \$${dailyAllowance.toStringAsFixed(2)}'),
            Text('Total Expenses: \$${totalExpense.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Daily', dailyExpenses),
                _buildSummaryCard('Weekly', weeklyExpenses),
                _buildSummaryCard('Monthly', monthlyExpenses),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildExpenseChart(Map<String, double> categoryTotals, double totalExpense) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.map((entry) {
                  final percentage = (entry.value / totalExpense) * 100;
                  return PieChartSectionData(
                    color: _getColorForCategory(entry.key),
                    value: entry.value,
                    title: '${entry.key} (${percentage.toStringAsFixed(1)}%)', // عرض اسم الفئة والنسبة المئوية
                    radius: 60,
                    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getColorForCategory(String category) {
  switch (category) {
    case 'Food':
      return Colors.blue;
    case 'Transport':
      return const Color.fromARGB(255, 174, 54, 244);
    case 'Shopping':
      return Colors.green;
    case 'Bills':
      return Colors.orange;
    default:
      return Colors.yellow;
  }
}




  Widget _buildSummaryCard(String title, double value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildExpenseList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Card(
      elevation: 4,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.data!.docs[index];
          return ListTile(
            leading: Icon(Icons.category),
            title: Text('${doc['category']} - \$${doc['amount']}'),
            subtitle: Text(doc['note'] ?? ''),
            trailing: Text(
              (doc['date'] as Timestamp).toDate().toString().split(' ')[0],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsAndAlerts() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tips & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Tip: Review your weekly spending to identify potential savings.'),
            SizedBox(height: 5),
            Text('Alert: You have reached 80% of your monthly budget.'),
          ],
        ),
      ),
    );
  }
}




