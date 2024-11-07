import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();  // للتحكم في حقل البريد الإلكتروني
  final _passwordController = TextEditingController();  // للتحكم في حقل كلمة المرور
  bool _showPassword = false;  // لتحديد ما إذا كانت كلمة المرور مرئية أم لا
  final _formKey = GlobalKey<FormState>();  // مفتاح للتحقق من صحة النموذج

  // التحقق من صحة الإيميل
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';  // التحقق من أن البريد الإلكتروني غير فارغ
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';  // التحقق من أن البريد الإلكتروني صالح
    }
    return null;
  }

  // التحقق من صحة كلمة المرور
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';  // التحقق من أن كلمة المرور غير فارغة
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';  // التحقق من أن كلمة المرور تحتوي على 6 أحرف على الأقل
    }
    return null;
  }

  // وظيفة التسجيل
  void _signUp() async {
    if (_formKey.currentState!.validate()) {  // إذا كانت المدخلات صحيحة
      try {
        // إنشاء المستخدم باستخدام Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),  // إزالة الفراغات في الإيميل
          password: _passwordController.text.trim(),  // إزالة الفراغات في كلمة المرور
        );
        
        // الحصول على معرف المستخدم
        String userId = userCredential.user!.uid;

        // إضافة بيانات المستخدم إلى Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId': userId,
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          // أضف أي بيانات أخرى تريد تخزينها للمستخدم هنا مثل الاسم أو رقم الهاتف
        });

        // إظهار رسالة النجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التسجيل بنجاح!'),  // رسالة نجاح
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال إلى صفحة تسجيل الدخول بعد التسجيل الناجح
        await Future.delayed(Duration(seconds: 2));  // تأخير لعرض رسالة النجاح
        Navigator.pushReplacementNamed(context, '/login');  // الانتقال لصفحة تسجيل الدخول
      } catch (e) {
        // إظهار رسالة الخطأ في حالة الفشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: ${e.toString()}'),  // رسالة خطأ
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),  // عنوان صفحة التسجيل
      ),
      body: Form(
        key: _formKey,  // تعيين مفتاح النموذج
        child: Padding(
          padding: EdgeInsets.all(16.0),  // إضافة حواف للنموذج
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // محاذاة العناصر في وسط الصفحة
            children: [
              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,  // تعيين المتحكم للبريد الإلكتروني
                decoration: InputDecoration(
                  labelText: 'Email',  // تسمية الحقل
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),  // إطار الخطأ باللون الأحمر
                  ),
                ),
                keyboardType: TextInputType.emailAddress,  // تحديد نوع الإدخال كإيميل
                validator: (value) => _validateEmail(value ?? ''),  // التحقق من صحة البريد الإلكتروني
              ),
              SizedBox(height: 16),  // مسافة بين الحقول
              
              // حقل كلمة المرور
              TextFormField(
                controller: _passwordController,  // تعيين المتحكم لكلمة المرور
                decoration: InputDecoration(
                  labelText: 'Password',  // تسمية الحقل
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,  // تغيير الأيقونة بين عرض و إخفاء كلمة المرور
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;  // تغيير حالة عرض كلمة المرور
                      });
                    },
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),  // إطار الخطأ باللون الأحمر
                  ),
                ),
                obscureText: !_showPassword,  // إخفاء كلمة المرور إذا كانت _showPassword false
                validator: (value) => _validatePassword(value ?? ''),  // التحقق من صحة كلمة المرور
              ),
              SizedBox(height: 16),  // مسافة بين الحقول
              
              // زر التسجيل
              ElevatedButton(
                onPressed: _signUp,  // عند الضغط على الزر، يتم استدعاء دالة التسجيل
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');  // الانتقال لصفحة تسجيل الدخول إذا كان لدى المستخدم حساب
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





