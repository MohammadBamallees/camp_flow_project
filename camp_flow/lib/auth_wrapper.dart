import 'package:firebase_auth/firebase_auth.dart'; // استيراد مكتبة التحقق من الهوية
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // استيراد شاشة الدخول
import 'screens/home_screen.dart'; // استيراد الشاشة الرئيسية

// استخدام StatelessWidget لأن هذه الشاشة لا تخزن بيانات، بل تراقب حالة البث فقط
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. StreamBuilder: أداة تراقب تدفق البيانات (Stream) وتحدث الواجهة فوراً عند تغيرها
    return StreamBuilder<User?>(
      // 2. authStateChanges: قناة بث من Firebase تخبرنا بحالة المستخدم (مسجل دخول أو لا)
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // أ. إذا كانت البيانات لا تزال في طريقها من السيرفر، نعرض مؤشر تحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // ب. إذا كان الـ snapshot يحتوي على بيانات (hasData)، يعني المستخدم مسجل دخول سابقاً
        if (snapshot.hasData) {
          return const HomeScreen(); // نوجهه فوراً لداخل التطبيق
        }

        // ج. إذا لم تكن هناك بيانات، يعني المستخدم غير مسجل أو قام بتسجيل الخروج
        return const LoginScreen(); // نوجهه لصفحة الدخول
      },
    );
  }
}