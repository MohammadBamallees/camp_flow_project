import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/database_service.dart';

// الكلاس StatelessWidget لأن الشاشة تعتمد على Provider لتحديث بياناتها وليس على State داخلية
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الاتصال بمزود البيانات (Provider) للحصول على محتويات السلة والعمليات عليها
    final cart = Provider.of<CartProvider>(context);
    // إنشاء نسخة من خدمة قاعدة البيانات لإتمام عملية الشراء
    final dbService = DatabaseService();
    // جلب بيانات المستخدم الحالي المسجل دخوله عبر Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      // شرط: إذا كانت السلة فارغة نعرض نصاً في المنتصف، وإذا كانت تحتوي عناصر نعرض القائمة
      body: cart.items.isEmpty
          ? const Center(child: Text('سلتك فارغة حالياً'))
          : Column(
        children: [
          // Expanded لجعل القائمة تأخذ كل المساحة المتاحة وتترك مساحة للزر في الأسفل
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length, // عدد العناصر في السلة
              itemBuilder: (context, index) {
                final item = cart.items[index]; // جلب المنتج الحالي بناءً على ترتيبه
                return ListTile(
                  // عرض صورة المنتج مع حواف دائرية (ClipRRect)
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image),
                  ),
                  title: Text(item.name), // اسم المنتج
                  subtitle: Text('\$${item.price}'), // سعر المنتج
                  // زر الحذف من السلة
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => cart.removeFromCart(item), // استدعاء دالة الحذف من الـ Provider
                  ),
                );
              },
            ),
          ),
          // جزء "تأكيد الطلب" في أسفل الشاشة
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A), // خلفية داكنة لتمييز منطقة الدفع
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // حواف علوية دائرية
            ),
            child: Column(
              children: [
                // عرض إجمالي السعر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    // تقريب السعر لخانة عشرية واحدة أو اثنتين
                    Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, color: Color(0xFF4A80F0), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                // زر تأكيد الطلب
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A80F0), // لون الزر الأزرق
                      foregroundColor: Colors.white, // لون النص داخل الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      // التأكد أولاً من أن العميل مسجل دخول
                      if (user != null) {
                        // إرسال الطلب لقاعدة البيانات (UID المستخدم، العناصر، الإجمالي)
                        await dbService.placeOrder(user.uid, cart.items, cart.totalPrice);
                        // تفريغ السلة بعد نجاح الطلب
                        cart.clearCart();
                        // إظهار رسالة نجاح والرجوع للشاشة السابقة
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم إرسال طلبك بنجاح!')));
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text(
                      'تأكيد الطلب',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}