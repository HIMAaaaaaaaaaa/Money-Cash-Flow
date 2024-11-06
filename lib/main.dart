import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_money_cash_flow/AddExpenseScreen.dart';
import 'package:flutter_application_money_cash_flow/Dashboard.dart';
import 'package:flutter_application_money_cash_flow/Expense%20Details%20Screen.dart';
import 'package:flutter_application_money_cash_flow/Financial%20Analysis%20Screen.dart';
import 'package:flutter_application_money_cash_flow/HomeScreen.dart';
import 'package:flutter_application_money_cash_flow/Monthly%20Income%20Screen.dart';
import 'package:flutter_application_money_cash_flow/ReportScreen.dart';
import 'package:flutter_application_money_cash_flow/SettingsScreen.dart';
import 'package:flutter_application_money_cash_flow/SignUpScreen.dart';
import 'firebase_options.dart';
import 'package:flutter_application_money_cash_flow/LoginScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // المسار الابتدائي الآن يشير إلى الصفحة الرئيسية
      routes: {
        '/': (context) => HomeScreen(), // تعيين الصفحة الرئيسية
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/expense_entry': (context) => AddExpenseScreen(),
        '/expense_details': (context) => ExpenseDetailsScreen(),
        '/monthly_income': (context) => MonthlyIncomeScreen(),
        '/financial_analysis': (context) => FinancialAnalysisScreen(),
        '/settings': (context) => SettingsScreen(),
        '/report': (context) => ReportScreen(),
      },
    );
  }
}