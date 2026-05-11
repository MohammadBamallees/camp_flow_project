import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_dashboard.dart';

// تعريف شاشة تسجيل الدخول كـ StatefulWidget لأن الواجهة تتغير (تغيير الأوضاع، إظهار التحميل)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // تعريف وحدات التحكم للنصوص لاستخراج ما يكتبه المستخدم في الحقول
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretKeyController = TextEditingController(); // خاص بالرمز السري للأدمن

  final AuthService _authService = AuthService(); // استدعاء خدمة المصادقة
  bool _isLoginMode = true; // متغير للتبديل بين واجهة (تسجيل الدخول) و (إنشاء حساب)
  bool _isLoading = false; // متغير لإظهار مؤشر التحميل أثناء انتظار الرد من السيرفر

  // الرمز السري المطلوب للسماح بإنشاء حساب أدمن جديد (طبقة حماية إضافية)
  final String _correctSecretKey = "KASHATAT_2026";

  // الدالة الأساسية لإرسال البيانات (Submit)
  void _submit() async {
    setState(() => _isLoading = true); // بدء التحميل وتحديث الواجهة

    String email = _emailController.text.trim(); // أخذ الإيميل وحذف الفراغات الزائدة
    String password = _passwordController.text.trim();
    String enteredKey = _secretKeyController.text.trim();

    String? error; // متغير لتخزين رسالة الخطأ إن وجدت

    if (_isLoginMode) {
      // إذا كان المستخدم في وضع "تسجيل الدخول"
      error = await _authService.login(email, password);
    } else {
      // إذا كان المستخدم في وضع "إنشاء حساب جديد"
      // التحقق أولاً: هل الرمز السري الذي أدخله يطابق الرمز الصحيح؟
      if (enteredKey != _correctSecretKey) {
        error = "الرمز السري غير صحيح! لا يمكنك إنشاء حساب أدمن.";
      } else {
        error = await _authService.register(email, password);
      }
    }

    setState(() => _isLoading = false); // إيقاف التحميل بعد انتهاء العملية

    if (error == null) {
      // إذا لم يكن هناك خطأ (نجاح العملية)
      if (mounted) { // التأكد أن الشاشة لا تزال موجودة قبل الانتقال
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
    } else {
      // في حالة الفشل: إظهار رسالة الخطأ في أسفل الشاشة (SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400, // تحديد عرض ثابت يناسب متصفحات الويب وشاشات الكمبيوتر
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // لون خلفية البطاقة (رمادي غامق)
            borderRadius: BorderRadius.circular(16), // حواف منحنية
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // جعل العمود يأخذ أقل مساحة ممكنة (حسب المحتوى)
            children: [
              const Icon(Icons.lock_person, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                _isLoginMode ? "KASHATAT ADMIN LOGIN" : "CREATE ADMIN ACCOUNT",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              // حقل إدخال البريد الإلكتروني
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              // حقل إدخال كلمة المرور مع خاصية obscureText لإخفاء الحروف
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              ),

              // ميزة ذكية: يظهر حقل الرمز السري "فقط" إذا كان المستخدم يحاول إنشاء حساب
              if (!_isLoginMode) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _secretKeyController,
                  decoration: const InputDecoration(
                    labelText: "Secret Admin Key",
                    hintText: "أدخل رمز التفويض",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              // عرض مؤشر التحميل أو زر الإرسال حسب الحالة
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text(_isLoginMode ? "Login" : "Register"),
              ),
              // زر للتبديل بين وضعي الدخول والتسجيل
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(_isLoginMode ? "Don't have an account? Register" : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}