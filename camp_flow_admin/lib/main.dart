import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/admin_dashboard.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

// الدالة الرئيسية التي يبدأ منها تشغيل التطبيق (جعلناها async لأننا سننتظر بعض العمليات)
void main() async {
  // هذا السطر إلزامي جداً: يخبر فلاتر أن ينتظر حتى يتم تجهيز المحرك الداخلي
  // قبل تنفيذ أي كود غير متزامن (مثل الاتصال بقاعدة البيانات)
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة والاتصال بقاعدة بيانات Firebase باستخدام المفاتيح الموجودة في ملف firebase_options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // التحقق من حالة الجلسة: هل المدير مسجل دخوله مسبقاً في هذا المتصفح/الجهاز؟
  bool isLoggedIn = await AuthService.isLoggedIn();

  // تشغيل التطبيق الفعلي، وتمرير الشاشة الأولى بناءً على حالة تسجيل الدخول
  runApp(KashatatAdminApp(startScreen: isLoggedIn ? const AdminDashboard() : const LoginScreen()));
}

// الكلاس الأساسي للتطبيق (Root Widget)، وهو من نوع StatelessWidget لأن إعداداته ثابتة
class KashatatAdminApp extends StatelessWidget {
  final Widget startScreen; // متغير لتخزين الشاشة التي سيبدأ بها التطبيق

  // المنشئ (Constructor) يستقبل الشاشة الأولى كمعطى إلزامي (required)
  const KashatatAdminApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    // MaterialApp هو الحاوية الرئيسية التي تعطي التطبيق شكل وتصاميم جوجل
    return MaterialApp(
      title: 'KASHATAT Admin', // اسم التطبيق (يظهر في شريط المتصفح أو قائمة المهام)
      debugShowCheckedModeBanner: false, // إخفاء شريط "Debug" الأحمر المزعج من الزاوية

      // إعدادات المظهر العام (Theme) للتطبيق بأكمله
      theme: ThemeData(
        useMaterial3: true, // تفعيل أحدث تصميم من جوجل (Material Design 3)
        brightness: Brightness.dark, // جعل التطبيق بالوضع الليلي (Dark Mode)
        colorSchemeSeed: Colors.blue, // جعل اللون الأزرق هو اللون الأساسي للأزرار والتأثيرات
        scaffoldBackgroundColor: const Color(0xFF121212), // توحيد لون خلفية كل الصفحات

        // توحيد تصميم القائمة الجانبية (NavigationRail) في كل التطبيق
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF1E1E1E), // لون خلفية القائمة
          selectedIconTheme: IconThemeData(color: Colors.blueAccent), // لون الأيقونة المفعلة
          unselectedIconTheme: IconThemeData(color: Colors.grey), // لون الأيقونة غير المفعلة
        ),
      ),
      // تحديد الشاشة الرئيسية التي ستفتح أولاً
      home: startScreen,
    );
  }
}