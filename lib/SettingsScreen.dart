import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';




class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userId = '';
  String _username = '';
  String _email = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _email = user.email ?? '';

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] ?? '';
          _phoneNumber = userDoc.data()?['phone_number'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

      await userRef.set({
        'username': _username,
        'email': _email,
        'phone_number': _phoneNumber,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح')));
    }
  }

  Future<void> _showChangePasswordDialog() async {
    String currentPassword = '';
    String newPassword = '';
    String confirmNewPassword = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعيين إعادة كلمة سر جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور الحالية'),
                onChanged: (value) {
                  currentPassword = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
                onChanged: (value) {
                  newPassword = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
                onChanged: (value) {
                  confirmNewPassword = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (newPassword == confirmNewPassword) {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final authCredential = EmailAuthProvider.credential(
                      email: _email,
                      password: currentPassword,
                    );

                    // إعادة التحقق من كلمة المرور القديمة وتحديثها بالجديدة
                    await user?.reauthenticateWithCredential(authCredential);
                    await user?.updatePassword(newPassword);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كلمة المرور الحالية غير صحيحة')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('كلمة المرور الجديدة غير متطابقة')));
                }
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                readOnly: true, // جعل البريد الإلكتروني للعرض فقط
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('حفظ التغييرات'),
              ),
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
}




