import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

// استخدام StatelessWidget لأن الشاشة تعتمد على StreamBuilder لتحديث البيانات تلقائياً
class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب بيانات المستخدم الحالي للتأكد من هويته
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // خلفية داكنة وفخمة
      appBar: AppBar(
        title: const Text('تتبع طلباتي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // فحص: إذا كان المستخدم غير مسجل دخول، نعرض رسالة تنبيه
      body: user == null
          ? const Center(child: Text('يرجى تسجيل الدخول لتتبع الطلبات', style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
        // الاستماع لبث مباشر لطلبات هذا المستخدم فقط عبر UID الخاص به
        stream: dbService.streamUserOrders(user.uid),
        builder: (context, snapshot) {
          // حالة الانتظار أثناء جلب البيانات من السيرفر
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          }
          // حالة عدم وجود أي طلبات مسجلة للمستخدم
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد طلبات حالياً', style: TextStyle(color: Colors.grey)));
          }

          // بناء قائمة الطلبات
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // جلب بيانات كل وثيقة طلب وتحويلها إلى Map
              var orderDoc = snapshot.data!.docs[index];
              var orderData = orderDoc.data() as Map<String, dynamic>;
              String status = orderData['status'] ?? 'Processing'; // الحالة الافتراضية

              // معالجة السعر بشكل آمن (دبل) لتجنب أخطاء أنواع البيانات
              double total = 0.0;
              var rawTotal = orderData['totalPrice'];
              if (rawTotal is num) {
                total = rawTotal.toDouble();
              } else if (rawTotal is String) {
                total = double.tryParse(rawTotal.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
              }

              // الحصول على اللون المناسب بناءً على حالة الطلب
              Color statusColor = _getStatusColor(status);
              // تقصير طول المعرف الخاص بالطلب لعرضه بشكل أنيق (أول 8 أحرف)
              String orderIdShort = orderDoc.id.length > 8
                  ? orderDoc.id.substring(0, 8).toUpperCase()
                  : orderDoc.id.toUpperCase();

              // تصميم بطاقة الطلب (Container)
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  // إضافة حافة ملونة جهة اليمين تعبر عن حالة الطلب
                  border: Border(right: BorderSide(color: statusColor, width: 4)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(_getStatusIcon(status), color: statusColor),
                  ),
                  title: Text(
                    'طلب #$orderIdShort',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('الإجمالي: \$${total.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      // ملصق (Tag) يوضح حالة الطلب باللغة العربية
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _translateStatus(status),
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    // مكان مخصص مستقبلاً للانتقال لصفحة تفاصيل الطلب
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // دالة مساعدة لاختيار اللون بناءً على حالة الطلب القادمة من Firebase
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return Colors.orangeAccent;
      case 'accepted': return Colors.greenAccent;
      case 'shipped': return Colors.blueAccent;
      case 'delivered': return Colors.green;
      case 'canceled':
      case 'cancelled': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  // دالة مساعدة لاختيار الأيقونة المناسبة للحالة
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return Icons.timer_outlined;
      case 'accepted': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.task_alt;
      case 'canceled':
      case 'cancelled': return Icons.error_outline;
      default: return Icons.help_outline;
    }
  }

  // دالة لترجمة حالة الطلب من الإنجليزية (في السيرفر) إلى العربية (للمستخدم)
  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return 'قيد الانتظار';
      case 'accepted': return 'تم القبول';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم الاستلام';
      case 'canceled':
      case 'cancelled': return 'ملغي';
      default: return 'غير معروف';
    }
  }
}