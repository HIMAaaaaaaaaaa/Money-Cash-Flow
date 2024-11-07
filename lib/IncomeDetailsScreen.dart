import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeDetailsScreen extends StatefulWidget {
  @override
  _IncomeDetailsScreenState createState() => _IncomeDetailsScreenState();
}

class _IncomeDetailsScreenState extends State<IncomeDetailsScreen> {
  // قائمة لتخزين بيانات الدخل المسترجعة من Firestore
  List<QueryDocumentSnapshot> _incomeList = [];
  // Controllers للتحكم في النصوص المدخلة من المستخدم
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  // متغير لتخزين التاريخ المختار للفلاتر
  DateTime? _selectedDate;
  // متغير لتخزين معرف المستخدم
  String? userId;

  @override
  void initState() {
    super.initState();
    // الحصول على userId للمستخدم الحالي من FirebaseAuth
    userId = FirebaseAuth.instance.currentUser?.uid;
    // استرجاع بيانات الدخل عند تحميل الصفحة
    _fetchIncomeData();
  }

  // دالة لاسترجاع جميع بيانات الدخل من Firestore بناءً على معايير الفلترة
  Future<void> _fetchIncomeData({String? amount, String? notes, DateTime? date}) async {
    if (userId == null) return; // التأكد من أن معرف المستخدم ليس فارغًا

    // بناء الاستعلام لقاعدة البيانات
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc('monthly_income')
        .collection('daily_income');

    // فلترة البيانات حسب المبلغ إذا تم إدخاله
    if (amount != null && amount.isNotEmpty) {
      query = query.where('amount', isEqualTo: double.tryParse(amount));
    }

    // فلترة البيانات حسب الملاحظات إذا تم إدخالها
    if (notes != null && notes.isNotEmpty) {
      query = query.where('notes', isEqualTo: notes);
    }

    // فلترة البيانات حسب التاريخ إذا تم تحديده
    if (date != null) {
      // تحديد بداية ونهاية اليوم للفلترة
      Timestamp startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
      Timestamp endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));
      query = query.where('date', isGreaterThanOrEqualTo: startOfDay).where('date', isLessThanOrEqualTo: endOfDay);
    }

    // استرجاع البيانات من Firestore
    final snapshot = await query.get();
    setState(() {
      // تحديث قائمة الدخل بالبيانات المسترجعة
      _incomeList = snapshot.docs;
    });
  }

  // دالة لإنشاء قائمة تعرض دخل المستخدم مع الفلاتر
  Widget _buildIncomeList() {
    return ListView.builder(
      itemCount: _incomeList.length,
      itemBuilder: (context, index) {
        // استخراج بيانات الدخل من الـ snapshot
        final income = _incomeList[index].data() as Map<String, dynamic>;
        final date = (income['date'] as Timestamp).toDate();
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        final amount = income['amount'] ?? 0.0;
        final notes = income['notes'] ?? 'No notes';

        return ListTile(
          title: Text('\$${amount.toString()}'), // عرض المبلغ
          subtitle: Text('Date: $formattedDate\nNotes: $notes'), // عرض التاريخ والملاحظات
        );
      },
    );
  }

  // دالة لاختيار التاريخ من الـ Date Picker لفلترة الدخل حسب التاريخ
  Future<void> _selectDate() async {
    // عرض الـ DatePicker لاختيار التاريخ
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        // تحديث التاريخ المختار
        _selectedDate = pickedDate;
      });
      // جلب بيانات الدخل بناءً على التاريخ المختار
      _fetchIncomeData(date: pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Details'), // عنوان الـ AppBar
        automaticallyImplyLeading: false, // إزالة زر الرجوع من الـ AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // إضافة Padding حول المحتوى
        child: Column(
          children: [
            // حقول البحث
            Row(
              children: [
                // حقل البحث حسب المبلغ
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Search by Amount', // النص التوضيحي
                    ),
                    keyboardType: TextInputType.number, // تحديد نوع لوحة المفاتيح
                    onChanged: (value) {
                      // عند تغيير القيمة في الحقل، يتم تحديث بيانات الدخل
                      _fetchIncomeData(
                        amount: value,
                        notes: _notesController.text,
                        date: _selectedDate,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16), // مسافة بين الحقول
                // حقل البحث حسب الملاحظات
                Expanded(
                  child: TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Search by Notes', // النص التوضيحي
                    ),
                    onChanged: (value) {
                      // عند تغيير القيمة في الحقل، يتم تحديث بيانات الدخل
                      _fetchIncomeData(
                        amount: _amountController.text,
                        notes: value,
                        date: _selectedDate,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // مسافة بين الحقول والزر
            // زر لاختيار التاريخ
            ElevatedButton(
              onPressed: _selectDate, // عند الضغط، يتم فتح الـ Date Picker
              child: Text('Select Date'),
            ),
            SizedBox(height: 16), // مسافة قبل عرض قائمة الدخل
            // عرض قائمة الدخل مع الفلاتر
            Expanded(child: _buildIncomeList()),
          ],
        ),
      ),
    );
  }
}
