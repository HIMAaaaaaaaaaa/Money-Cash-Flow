import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc('currentUserId').get();
    if (userDoc.exists) {
      setState(() {
        _username = userDoc.data()?['username'] ?? '';
        _email = userDoc.data()?['email'] ?? '';
        _phoneNumber = userDoc.data()?['phone_number'] ?? '';
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc('currentUserId').update({
        'username': _username,
        'email': _email,
        'phone_number': _phoneNumber,
        'password': _password, // تأكد من التعامل مع كلمة المرور بشكل آمن
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ التغييرات بنجاح')));
    }
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
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'الرجاء إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
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
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'كلمة المرور (للتحديث)'),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: (value) {
                  if (value != null && value.length < 6) {
                    return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text('حفظ التغييرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
