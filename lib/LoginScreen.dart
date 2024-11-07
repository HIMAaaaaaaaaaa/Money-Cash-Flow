import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // للتحكم في مدخل البريد الإلكتروني
  final _passwordController = TextEditingController(); // للتحكم في مدخل كلمة المرور
  bool _showPassword = false; // متغير لتحديد إذا كان يجب عرض كلمة المرور أم لا
  final _formKey = GlobalKey<FormState>(); // مفتاح النموذج للتحقق من صحة المدخلات

  // دالة للتحقق من صحة البريد الإلكتروني
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required'; // إذا كانت المدخلات فارغة
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email'; // إذا كان البريد الإلكتروني غير صالح
    }
    return null;
  }

  // دالة للتحقق من صحة كلمة المرور
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required'; // إذا كانت كلمة المرور فارغة
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters'; // إذا كانت كلمة المرور أقل من 6 حروف
    }
    return null;
  }

  // دالة لإنشاء مستند للمستخدم في Firebase إذا لم يكن موجودًا
  Future<void> _createUserDocument(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid); // مرجع للمستند الخاص بالمستخدم
    final docSnapshot = await userRef.get(); // جلب البيانات الخاصة بالمستخدم

    if (!docSnapshot.exists) { // إذا لم يكن المستند موجودًا
      // حفظ بيانات المستخدم في Firebase
      await userRef.set({
        'user_id': user.uid,
        'email': user.email,
        'password': _passwordController.text.trim(), // حفظ كلمة المرور بدون تشفير (يجب تشفيرها في تطبيق حقيقي)
        'username': '', // سيتم ملؤه لاحقًا
        'phone_number': '', // سيتم ملؤه لاحقًا
      });
    }
  }

  // دالة لتسجيل الدخول
  void _login() async {
    if (_formKey.currentState!.validate()) { // التحقق من صحة المدخلات
      try {
        // محاولة تسجيل الدخول باستخدام Firebase
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await _createUserDocument(user); // إذا لم يكن المستند موجودًا، يتم إنشاؤه
          Navigator.pushReplacementNamed(context, '/dashboard'); // الانتقال إلى الشاشة الرئيسية
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        // التعامل مع الأخطاء التي قد تحدث أثناء تسجيل الدخول
        if (e.code == 'user-not-found') {
          errorMessage = 'This email is not registered. Please check your email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not formatted correctly.';
        } else {
          errorMessage = 'Login failed: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), // عرض رسالة الخطأ للمستخدم
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'), // في حالة حدوث خطأ غير متوقع
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
        title: Text('Login'), // عنوان التطبيق
      ),
      body: Form(
        key: _formKey, // ربط النموذج بالمفتاح للتحقق من صحة المدخلات
        child: Padding(
          padding: EdgeInsets.all(16.0), // المسافة بين العناصر
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // محاذاة العناصر في المنتصف
            children: [
              // حقل إدخال البريد الإلكتروني
              TextFormField(
                controller: _emailController, // ربط الحقل بـ _emailController
                decoration: InputDecoration(
                  labelText: 'Email', // النص التوضيحي للحقل
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                keyboardType: TextInputType.emailAddress, // تعيين نوع المدخلات للبريد الإلكتروني
                validator: (value) => _validateEmail(value ?? ''), // التحقق من صحة البريد الإلكتروني
              ),
              SizedBox(height: 16),
              // حقل إدخال كلمة المرور
              TextFormField(
                controller: _passwordController, // ربط الحقل بـ _passwordController
                decoration: InputDecoration(
                  labelText: 'Password', // النص التوضيحي للحقل
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off, // تغيير أيقونة إظهار كلمة المرور
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword; // تغيير حالة العرض
                      });
                    },
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                obscureText: !_showPassword, // إخفاء كلمة المرور عند التسجيل
                validator: (value) => _validatePassword(value ?? ''), // التحقق من صحة كلمة المرور
              ),
              SizedBox(height: 16),
              // زر تسجيل الدخول
              ElevatedButton(
                onPressed: _login, // عند الضغط يتم استدعاء دالة _login
                child: Text('Login'),
              ),
              // رابط للتسجيل (في حال لم يكن لدى المستخدم حساب)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup'); // الانتقال إلى صفحة التسجيل
                },
                child: Text('Don’t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



