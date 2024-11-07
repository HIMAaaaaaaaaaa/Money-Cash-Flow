import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  String _searchQuery = ''; // المتغير لتخزين استعلام البحث عن الملاحظات
  double? _searchAmount; // المتغير لتخزين مبلغ البحث
  DateTime? _selectedDate; // المتغير لتخزين التاريخ المحدد
  String? userId; // المتغير لتخزين معرف المستخدم الحالي

  @override
  void initState() {
    super.initState();
    // الحصول على userId للمستخدم الحالي من Firebase
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Details'), // عنوان الشاشة
        automaticallyImplyLeading: false, // تعطيل زر العودة
      ),
      body: Column(
        children: [
          _buildSearchField(), // حقل البحث للملاحظات
          _buildAmountField(), // حقل البحث عن المبلغ
          _buildDatePicker(), // حقل اختيار التاريخ
          Expanded(child: _buildExpenseList()), // عرض قائمة المصروفات
        ],
      ),
    );
  }

  // حقل البحث للملاحظات
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Note', // تسمية الحقل
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          // تحديث _searchQuery عند تغيير النص
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  // حقل البحث عن المبلغ
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Amount', // تسمية الحقل
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number, // تحديد نوع الإدخال ليكون أرقام فقط
        onChanged: (value) {
          // تحديث _searchAmount عند تغيير النص
          setState(() {
            _searchAmount = value.isNotEmpty ? double.tryParse(value) : null;
          });
        },
      ),
    );
  }

  // حقل اختيار التاريخ
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              // اختيار التاريخ باستخدام showDatePicker
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate; // تحديث التاريخ المحدد
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // بناء قائمة المصروفات بعد تصفيتها وفقًا للبحث
  Widget _buildExpenseList() {
    if (userId == null) {
      // إذا لم يتم العثور على userId، عرض رسالة خطأ
      return Center(child: Text('No user ID found.'));
    }

    // استعلام لجلب المصروفات من Firebase للمستخدم الحالي
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses');

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('date', descending: true).snapshots(), // جلب المصروفات بترتيب تنازلي حسب التاريخ
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // عرض مؤشر تحميل أثناء الانتظار
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // عرض رسالة في حالة عدم وجود بيانات
          return Center(child: Text('No expenses recorded.'));
        }

        // تصفية البيانات بناءً على شروط البحث
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final note = doc['note'] ?? '';
          final amount = doc['amount'] ?? 0.0;
          final date = (doc['date'] as Timestamp).toDate();

          // التحقق من تطابق الملاحظة، المبلغ، والتاريخ مع شروط البحث
          bool matchesNote = note.toLowerCase().contains(_searchQuery);
          bool matchesAmount = _searchAmount == null || amount == _searchAmount;
          bool matchesDate = _selectedDate == null || 
              DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate!);

          return matchesNote && matchesAmount && matchesDate;
        }).toList();

        if (filteredDocs.isEmpty) {
          // في حالة عدم وجود نتائج تطابق البحث
          return Center(child: Text('No matching expenses found.'));
        }

        // عرض قائمة المصروفات المتوافقة مع الفلاتر
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var expense = filteredDocs[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('\$${expense['amount'].toStringAsFixed(2)}'), // عرض المبلغ
                subtitle: Text('${expense['category']} - ${expense['note']} - ${DateFormat('yyyy-MM-dd').format((expense['date'] as Timestamp).toDate())}'), // عرض الفئة، الملاحظة، والتاريخ
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red), // زر الحذف
                  onPressed: () => _deleteExpense(expense.id), // حذف المصروف عند الضغط
                ),
                onTap: () {
                  // اختياري: الانتقال إلى شاشة تعديل المصروفات (إذا لزم الأمر)
                },
              ),
            );
          },
        );
      },
    );
  }

  // دالة لحذف المصروف من Firebase
  void _deleteExpense(String id) async {
    if (userId != null) {
      // حذف المصروف من قاعدة البيانات بناءً على المعرف
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(id)
          .delete();
      print('Expense deleted: $id'); // طباعة المعرف المحذوف في الـ console
    }
  }
}






