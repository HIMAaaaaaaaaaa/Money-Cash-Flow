import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Cash Flow'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Money Cash Flow',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Manage your finances with ease!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // توجيه المستخدم إلى صفحة التسجيل
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Sign Up'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // توجيه المستخدم إلى صفحة تسجيل الدخول
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
