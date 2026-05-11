import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// تعريف الكلاس كـ StatelessWidget لأن الشاشة تعتمد على StreamBuilder لتحديث نفسها تلقائياً
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  // دالة لتحديث حالة الطلب في قاعدة البيانات Firebase Firestore
  void _updateStatus(String id, String status) {
    // الوصول لمجلد (collection) الطلبات، ثم تحديد مستند الطلب عبر معرفه (id)، ثم تحديث حقل الحالة فقط
    FirebaseFirestore.instance.collection('orders').doc(id).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // تعيين خلفية غامقة متناسقة مع التصميم
      appBar: AppBar(
        title: const Text('إدارة الطلبات السريعة'),
        centerTitle: true,
        backgroundColor: Colors.transparent, // جعل شريط التطبيق شفافاً لمظهر عصري
      ),
      // StreamBuilder: هو المسؤول عن جلب البيانات بشكل حي؛ أي تغيير في Firebase سيظهر هنا فوراً بدون تحديث يدوي
      body: StreamBuilder<QuerySnapshot>(
        // تحديد مصدر البيانات: جلب الطلبات التي حالتها "Processing" فقط
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'Processing')
            .snapshots(),
        builder: (context, snapshot) {
          // عرض مؤشر تحميل إذا كانت البيانات لا تزال قيد الجلب من السيرفر
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // تخزين قائمة المستندات القادمة في متغير لسهولة التعامل معها
          final orders = snapshot.data!.docs;

          // بناء قائمة قابلة للتمرير بكفاءة عالية
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var orderDoc = orders[index];
              var data = orderDoc.data() as Map<String, dynamic>; // تحويل بيانات الطلب لخريطة (Map)

              // Dismissible: ويدجيت يسمح بسحب العنصر لليمين أو اليسار لتنفيذ أمر معين
              return Dismissible(
                key: Key(orderDoc.id), // مفتاح فريد لكل عنصر ليميزه فلاتر عند الحذف أو التحريك

                // دالة تُنفذ عند سحب البطاقة وتطلب التأكيد أو التنفيذ
                confirmDismiss: (direction) async {
                  // إذا سحب المستخدم من اليسار لليمين (بداية السطر لنهايته)
                  if (direction == DismissDirection.startToEnd) {
                    _updateStatus(orderDoc.id, 'Accepted'); // تغيير الحالة لمقبول
                    return true; // إخفاء العنصر من القائمة الحالية
                  } else {
                    // إذا سحب المستخدم بالاتجاه المعاكس
                    _updateStatus(orderDoc.id, 'Canceled'); // تغيير الحالة لملغي
                    return true;
                  }
                },

                // التصميم الذي يظهر خلف البطاقة عند السحب لليمين (القبول)
                background: Container(
                  color: Colors.green, // لون أخضر للقبول
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check, color: Colors.white, size: 30),
                ),

                // التصميم الذي يظهر خلف البطاقة عند السحب لليسار (الإلغاء)
                secondaryBackground: Container(
                  color: Colors.red, // لون أحمر للإلغاء
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.cancel, color: Colors.white, size: 30),
                ),

                // محتوى البطاقة الفعلي (الذي يراه المستخدم)
                child: Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // عرض أول 5 أحرف فقط من معرف الطلب الطويل لشكل أنظف
                    title: Text("طلب #${orderDoc.id.substring(0, 5)}", style: const TextStyle(color: Colors.white)),
                    subtitle: Text("المجموع: \$${data['totalPrice']}", style: const TextStyle(color: Colors.grey)),
                    // أيقونة توحي للمستخدم بأن هذا العنصر قابل للسحب
                    trailing: const Icon(Icons.swipe, color: Colors.blueAccent, size: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}