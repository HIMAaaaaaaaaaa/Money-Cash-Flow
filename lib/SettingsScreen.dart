import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>(); // المفتاح للتحقق من صحة النموذج
  final TextEditingController _usernameController = TextEditingController(); // للتحكم في حقل اسم المستخدم
  final TextEditingController _phoneNumberController = TextEditingController(); // للتحكم في حقل رقم الهاتف

  String _userId = ''; // معرف المستخدم
  String _username = ''; // اسم المستخدم
  String _email = ''; // البريد الإلكتروني
  String _phoneNumber = ''; // رقم الهاتف
  String _oldPassword = ''; // كلمة المرور القديمة
  String _newPassword = ''; // كلمة المرور الجديدة
  String _confirmNewPassword = ''; // تأكيد كلمة المرور الجديدة

  @override
  void initState() {
    super.initState();
    _initializeUserData(); // تحميل بيانات المستخدم عند بدء الشاشة
  }

  // دالة لتحميل بيانات المستخدم من Firebase
  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser; // الحصول على المستخدم الحالي
    if (user != null) {
      _userId = user.uid; // تعيين معرف المستخدم
      _email = user.email ?? ''; // تعيين البريد الإلكتروني للمستخدم

      // استرجاع بيانات المستخدم من قاعدة البيانات
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] ?? ''; // تعيين اسم المستخدم
          _phoneNumber = userDoc.data()?['phone_number'] ?? ''; // تعيين رقم الهاتف
          _usernameController.text = _username; // تعيين القيمة لحقل اسم المستخدم
          _phoneNumberController.text = _phoneNumber; // تعيين القيمة لحقل رقم الهاتف
        });
      }
    }
  }

  // دالة لتحديث بيانات المستخدم في Firebase
  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) { // التحقق من صحة النموذج
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_userId); // مرجع المستخدم في قاعدة البيانات

      // تحديث بيانات المستخدم في Firebase
      await userRef.set({
        'username': _username,
        'email': _email,
        'phone_number': _phoneNumber,
      }, SetOptions(merge: true)); // دمج البيانات مع البيانات الحالية

      // عرض رسالة تأكيد بعد التحديث
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح')));
    }
  }

  // دالة لتحديث كلمة المرور
  Future<void> _updatePassword() async {
    if (_newPassword != _confirmNewPassword) { // التحقق من تطابق كلمة المرور الجديدة مع تأكيدها
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('كلمة المرور الجديدة غير متطابقة')));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final authCredential = EmailAuthProvider.credential(
        email: _email,
        password: _oldPassword,
      );

      // إعادة مصادقة المستخدم باستخدام كلمة المرور القديمة
      await user?.reauthenticateWithCredential(authCredential);
      // تحديث كلمة المرور الجديدة
      await user?.updatePassword(_newPassword);

      // تحديث كلمة المرور في Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'password': _newPassword}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في تحديث كلمة المرور: $error')));
      });

      Navigator.pop(context); // العودة إلى الشاشة السابقة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('كلمة المرور الحالية غير صحيحة')));
    }
  }

  // دالة لإظهار مربع حوار لتغيير كلمة المرور
  Future<void> _showChangePasswordDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعيين إعادة كلمة سر جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // حقل إدخال كلمة المرور الحالية
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور الحالية'),
                onChanged: (value) {
                  _oldPassword = value; // تعيين القيمة لكلمة المرور الحالية
                },
              ),
              // حقل إدخال كلمة المرور الجديدة
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
                onChanged: (value) {
                  _newPassword = value; // تعيين القيمة لكلمة المرور الجديدة
                },
              ),
              // حقل تأكيد كلمة المرور الجديدة
              TextFormField(
                obscureText: true,
                decoration:
                    InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
                onChanged: (value) {
                  _confirmNewPassword = value; // تعيين القيمة لتأكيد كلمة المرور
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // إغلاق مربع الحوار
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                await _updatePassword(); // تنفيذ تحديث كلمة المرور
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose(); // تحرير الموارد
    _phoneNumberController.dispose(); // تحرير الموارد
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
        automaticallyImplyLeading:
            false, // تعطيل السهم الخلفي أو أيقونة القائمة الجانبية
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // أيقونة لتسجيل الخروج
            onPressed: () {
              _logout(context); // استدعاء دالة تسجيل الخروج
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // التحقق من صحة النموذج
          child: Column(
            children: [
              // حقل إدخال اسم المستخدم
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
                onChanged: (value) {
                  _username = value; // تعيين القيمة لاسم المستخدم
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم'; // التحقق من وجود قيمة
                  }
                  return null;
                },
              ),
              // حقل إدخال البريد الإلكتروني (قراءة فقط)
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                readOnly: true, // جعل الحقل للقراءة فقط
              ),
              // حقل إدخال رقم الهاتف
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                onChanged: (value) {
                  _phoneNumber = value; // تعيين القيمة لرقم الهاتف
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف'; // التحقق من وجود قيمة
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // زر حفظ التغييرات
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('حفظ التغييرات'),
              ),
              // زر تعيين كلمة مرور جديدة
              ElevatedButton(
                onPressed: _showChangePasswordDialog,
                child: Text('تعيين إعادة كلمة سر جديدة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لتسجيل الخروج
  void _logout(BuildContext context) {
    // يمكنك هنا إضافة كود لتسجيل الخروج، مثل مسح البيانات أو التوجيه لشاشة تسجيل الدخول.
    // مثال:
    Navigator.pushReplacementNamed(context, '/login'); // التوجيه إلى شاشة تسجيل الدخول
  }
}

