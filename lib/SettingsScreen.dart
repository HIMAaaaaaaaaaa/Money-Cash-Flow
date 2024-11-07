import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String _userId = '';
  String _username = '';
  String _email = '';
  String _phoneNumber = '';
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';

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

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] ?? '';
          _phoneNumber = userDoc.data()?['phone_number'] ?? '';
          _usernameController.text = _username;
          _phoneNumberController.text = _phoneNumber;
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_userId);

      await userRef.set({
        'username': _username,
        'email': _email,
        'phone_number': _phoneNumber,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح')));
    }
  }

  Future<void> _updatePassword() async {
    if (_newPassword != _confirmNewPassword) {
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

      await user?.reauthenticateWithCredential(authCredential);
      await user?.updatePassword(_newPassword);

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

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('كلمة المرور الحالية غير صحيحة')));
    }
  }

  Future<void> _showChangePasswordDialog() async {
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
                  _oldPassword = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
                onChanged: (value) {
                  _newPassword = value;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration:
                    InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
                onChanged: (value) {
                  _confirmNewPassword = value;
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
                await _updatePassword();
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
    _usernameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
        automaticallyImplyLeading:
            false, // Disable the back arrow or drawer icon
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Icon for logout
            onPressed: () {
              _logout(context); // Call the logout function
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
                onChanged: (value) {
                  _username = value;
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
                readOnly: true,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
                onChanged: (value) {
                  _phoneNumber = value;
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
  void _logout(BuildContext context) {
    // يمكنك هنا إضافة كود لتسجيل الخروج، مثل مسح البيانات أو التوجيه لشاشة تسجيل الدخول.
    // مثال:
    Navigator.pushReplacementNamed(context, '/login');
  }
}
