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
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  
  Future<void>? _initializeUserFuture; // تخزين Future هنا
  
  @override
  void initState() {
    super.initState();
    _initializeUserFuture = _initializeUserData(); // استدعاء الدالة مرة واحدة فقط
  }

  Future<void> _initializeUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          setState(() {
            _username = userDoc.data()?['username'] ?? '';
            _email = user.email ?? '';
            _phoneNumber = userDoc.data()?['phone_number'] ?? '';
          });
        } else {
          print('User data not found');
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error loading user data: $e');
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
                decoration: InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: FutureBuilder<void>(
        future: _initializeUserFuture, // استخدم Future المخزن هنا
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          } else {
            return Padding(
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
                      readOnly: true,
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
            );
          }
        },
      ),
    );
  }
}

