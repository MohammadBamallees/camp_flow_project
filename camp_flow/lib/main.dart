import 'package:firebase_core/firebase_core.dart'; // المكتبة الأساسية لتشغيل خدمات فايربيز
import 'package:flutter/material.dart'; // مكتبة واجهات فلاتر الأساسية
import 'package:provider/provider.dart'; // مكتبة إدارة الحالة (State Management)
import 'auth_wrapper.dart'; // استدعاء ملف التأكد من تسجيل الدخول الذي شرحناه سابقاً
import 'providers/cart_provider.dart'; // استدعاء خزان السلة

// دالة main هي أول دالة ينفذها التطبيق عند تشغيله
// استخدمنا async لأننا نحتاج للانتظار حتى يتصل فايربيز قبل فتح التطبيق
void main() async {
  // هذا السطر إلزامي عندما تستخدم أوامر (async/await) قبل تشغيل runApp
  // وهو يضمن أن محرك فلاتر الداخلي جاهز للعمل
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الاتصال بقاعدة بيانات فايربيز
  await Firebase.initializeApp();

  // تشغيل التطبيق، وقمنا بتغليفه بـ MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // توفير CartProvider (السلة) على مستوى التطبيق بالكامل
        // هذا يعني أن أي شاشة في التطبيق يمكنها الوصول للسلة وإضافة أو قراءة المنتجات منها
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const KashatatApp(), // تشغيل الواجهة الأساسية للتطبيق
    ),
  );
}

// الكلاس الأساسي للتطبيق (Stateless لأنه مجرد هيكل ولا تتغير بياناته داخلياً)
class KashatatApp extends StatelessWidget {
  const KashatatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط "Debug" الأحمر المزعج من زاوية الشاشة
      title: 'KASHATAT - Camping Store', // اسم التطبيق (يظهر في إدارة المهام في الجوال)

      // Theme: هو "الهوية البصرية الموحدة" للتطبيق
      theme: ThemeData(
        brightness: Brightness.dark, // تفعيل الوضع الليلي (Dark Mode) كلون أساسي
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // لون خلفية جميع الشاشات (أسود داكن)
        primaryColor: const Color(0xFF4A80F0), // اللون الأساسي للتطبيق (أزرق)

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A80F0),
          secondary: Color(0xFF4A80F0),
        ),

        // توحيد تصميم جميع الأزرار (ElevatedButton) في التطبيق
        // هذا يوفر عليك كتابة التصميم في كل شاشة
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A80F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),

        // توحيد تصميم جميع حقول الإدخال (TextField) في التطبيق
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // نقطة البداية الفعلية للمستخدم:
      // نوجهه إلى AuthWrapper ليقرر هل يفتح له الشاشة الرئيسية أم شاشة تسجيل الدخول
      home: const AuthWrapper(),
    );
  }
}