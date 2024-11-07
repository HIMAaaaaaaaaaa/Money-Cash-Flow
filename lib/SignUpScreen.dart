import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  // التحقق من صحة الإيميل
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // التحقق من كلمة المرور
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // إنشاء المستخدم باستخدام Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
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
            content: Text('تم التسجيل بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );

        // الانتقال إلى صفحة تسجيل الدخول بعد التسجيل الناجح
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        // إظهار رسالة الخطأ في حالة الفشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: ${e.toString()}'),
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
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => _validateEmail(value ?? ''),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) => _validatePassword(value ?? ''),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
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




