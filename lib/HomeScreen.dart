import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold: بيحدد هيكل الصفحة مع الأجزاء الأساسية زي الـ appBar و body
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Cash Flow'), // العنوان في الـ appBar
      ),
      body: Center( // بيخلي المحتوى في منتصف الشاشة
        child: Padding( // إضافة مسافة (Padding) حول المحتوى عشان يكون الشكل أنيق
          padding: const EdgeInsets.all(16.0), // مسافة بين المحتوى والـ edges
          child: Column( // ترتيب العناصر بشكل عمودي داخل الصفحة
            mainAxisAlignment: MainAxisAlignment.center, // بيخلي العناصر تتوزع بشكل متساوي عموديًا في وسط الشاشة
            children: [
              Text(
                'Welcome to Money Cash Flow', // النص الترحيبي في الشاشة
                style: TextStyle(
                  fontSize: 24, // حجم الخط
                  fontWeight: FontWeight.bold, // جعل الخط سميك
                ),
                textAlign: TextAlign.center, // تنسيق النص في المنتصف
              ),
              SizedBox(height: 20), // مسافة بين النصين
              Text(
                'Manage your finances with ease!', // النص التوضيحي
                style: TextStyle(fontSize: 16), // حجم الخط أصغر
                textAlign: TextAlign.center, // تنسيق النص في المنتصف
              ),
              SizedBox(height: 40), // مسافة أكبر بين النصين
              ElevatedButton( // زر مرفوع (Elevated Button) مع وظيفة عند الضغط
                onPressed: () {
                  // عند الضغط على الزر، هيتوجه المستخدم إلى صفحة التسجيل
                  Navigator.pushNamed(context, '/signup'); 
                },
                child: Text('Sign Up'), // النص الموجود على الزر
              ),
              SizedBox(height: 20), // مسافة بين الأزرار
              ElevatedButton(
                onPressed: () {
                  // عند الضغط على الزر، هيتوجه المستخدم إلى صفحة تسجيل الدخول
                  Navigator.pushNamed(context, '/login'); 
                },
                child: Text('Login'), // النص الموجود على الزر
              ),
            ],
          ),
        ),
      ),
    );
  }
}

