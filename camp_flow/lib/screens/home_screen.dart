import 'dart:convert'; // مكتبة لتحويل النصوص المشفرة (Base64) إلى بيانات صور
import 'package:firebase_auth/firebase_auth.dart'; // مكتبة التحقق من هوية المستخدم
import 'package:flutter/material.dart'; // المكتبة الأساسية لواجهات فلاتر
import 'package:provider/provider.dart'; // مكتبة إدارة الحالة (State Management)
import '../services/database_service.dart'; // استدعاء خدمة قاعدة البيانات
import '../models/product_model.dart'; // استدعاء نموذج المنتج
import '../models/user_model.dart'; // استدعاء نموذج المستخدم
import '../providers/cart_provider.dart'; // استدعاء مزود السلة
import 'cart_screen.dart'; // شاشة السلة
import 'profile_screen.dart'; // شاشة الملف الشخصي
import 'order_tracking_screen.dart'; // شاشة تتبع الطلبات

// تعريف الشاشة كـ StatefulWidget لأنها تحتاج لتحديث بياناتها (مثل صورة البروفايل)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // إنشاء نسخة من خدمة قاعدة البيانات للوصول للدوال البرمجية
  final dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // لون خلفية التطبيق (أسود داكن)
      appBar: AppBar(
        title: const Text('KASHATAT Store', style: TextStyle(letterSpacing: 1.5, color: Colors.white)),
        backgroundColor: Colors.transparent, // جعل شريط التطبيق شفافاً
        elevation: 0, // إزالة الظل أسفل شريط التطبيق
        actions: [
          // 1. FutureBuilder: لجلب بيانات المستخدم وصورته الشخصية بشكل غير متزامن
          FutureBuilder<UserModel?>(
            // جلب بيانات المستخدم الحالي باستخدام الـ UID الخاص به
            future: dbService.getUserData(FirebaseAuth.instance.currentUser?.uid ?? ""),
            builder: (context, snapshot) {
              String? base64Image = snapshot.data?.profileImage;
              // التأكد من أن الصورة موجودة وليست نصاً فارغاً أو كلمة "null"
              bool hasImage = base64Image != null && base64Image.isNotEmpty && base64Image != "null";

              return GestureDetector(
                onTap: () {
                  // الانتقال لصفحة البروفايل، وعند العودة يتم تحديث الشاشة الرئيسية (setState)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ).then((_) => setState(() {}));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF1A1A1A),
                      // تحويل نص الـ Base64 إلى صورة حقيقية تعرض في الدائرة
                      backgroundImage: hasImage
                          ? MemoryImage(base64Decode(base64Image))
                          : null,
                      // إذا لم توجد صورة، يتم عرض أيقونة شخص افتراضية
                      child: !hasImage
                          ? const Icon(Icons.person_outline, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. زر عرض سجل الطلبات (تتبع الطلبات)
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen())),
          ),

          // 3. أيقونة السلة مع عداد المنتجات (Stack)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              // وضع الدائرة الحمراء فوق أيقونة السلة في الزاوية
              Positioned(
                right: 8,
                top: 8,
                // Consumer: يراقب الـ CartProvider ويقوم بتغيير الرقم فوراً عند إضافة منتج
                child: Consumer<CartProvider>(
                  builder: (_, cart, __) => cart.items.isEmpty
                      ? const SizedBox() // لا تعرض شيئاً إذا كانت السلة فارغة
                      : Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    // عرض عدد المنتجات الموجودة في قائمة السلة
                    child: Text('${cart.items.length}', style: const TextStyle(fontSize: 10, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      // 4. StreamBuilder: لفتح اتصال مباشر مع قاعدة البيانات لعرض المنتجات وتحديثها لحظياً
      body: StreamBuilder<List<Product>>(
        stream: dbService.streamProducts(), // البث المباشر للمنتجات من السيرفر
        builder: (context, snapshot) {
          // عرض مؤشر تحميل أثناء انتظار البيانات
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          // رسالة في حال عدم وجود منتجات في المتجر
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No products available', style: TextStyle(color: Colors.white)));

          final products = snapshot.data!;
          // عرض المنتجات بشكل شبكي (GridView)
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عرض منتجين في كل صف
              childAspectRatio: 0.75, // نسبة العرض إلى الطول للبطاقة
              crossAxisSpacing: 15, // المسافة الأفقية بين البطاقات
              mainAxisSpacing: 15, // المسافة الرأسية بين البطاقات
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // بطاقة المنتج (Card)
              return Card(
                color: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض صورة المنتج مع حواف دائرية
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover)
                            : Container(color: Colors.grey[800], child: const Icon(Icons.image, size: 50, color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم المنتج
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          // سعر المنتج باللون الأزرق
                          Text('\$${product.price}', style: const TextStyle(color: Color(0xFF4A80F0), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          // زر الإضافة للسلة
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // استدعاء دالة الإضافة في الـ Provider لإدراج المنتج في السلة
                                context.read<CartProvider>().addToCart(product);
                                // إظهار رسالة تأكيد صغيرة (SnackBar) أسفل الشاشة
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A80F0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Add to Cart', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}