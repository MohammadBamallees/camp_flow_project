import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// استخدام StatefulWidget لأن الشاشة تتغير حالتها (تبديل بين دخول وتسجيل، وإظهار مؤشر التحميل)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // إنشاء نسخة من خدمة التحقق (AuthService) للتعامل مع Firebase
  final AuthService _authService = AuthService();

  // المتحكمات (Controllers) لسحب النصوص التي يكتبها المستخدم في الحقول
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // متغير للتحكم في ظهور دائرة التحميل أثناء الاتصال بالسيرفر
  bool _isLogin = true;    // متغير للتبديل بين وضع "تسجيل الدخول" و "إنشاء حساب جديد"

  // الدالة المسؤولة عن معالجة الضغط على الزر الرئيسي
  void _handleSubmit() async {
    // التأكد من أن الحقول ليست فارغة قبل إرسال الطلب
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true); // ابدأ التحميل

    dynamic result;
    if (_isLogin) {
      // استدعاء دالة تسجيل الدخول بالإيميل والباسوورد
      result = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      // استدعاء دالة إنشاء حساب جديد
      result = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (mounted) setState(() => _isLoading = false); // أوقف التحميل بعد انتهاء العملية

    // إذا كانت النتيجة فارغة (null)، فهذا يعني وجود خطأ في البيانات أو الشبكة
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isLogin ? 'خطأ في الدخول، تأكد من بياناتك' : 'فشل إنشاء الحساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // لون الخلفية الأسود (Dark Theme)
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView( // يسمح بالتمرير إذا ظهرت لوحة المفاتيح لمنع تداخل العناصر
            child: Column(
              children: [
                // الجزء العلوي: الشعار (Icon) واسم التطبيق
                const Icon(Icons.waves, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text(
                  'KASHATAT',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 60),

                // حقل إدخال البريد الإلكتروني
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'email address',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A), // لون رمادي غامق للحقل
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  ),
                ),
                const SizedBox(height: 15),

                // حقل إدخال كلمة المرور
                TextField(
                  controller: _passwordController,
                  obscureText: true, // لإخفاء الحروف أثناء الكتابة (نجوم)
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  ),
                ),
                const SizedBox(height: 40),

                // زر الدخول/التسجيل الرئيسي (ElevatedButton)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit, // تعطيل الزر أثناء التحميل
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A80F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? 'Log in' : 'Sign Up', style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                // زر التبديل بين وضعي الدخول وإنشاء الحساب
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Log in",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),

                const SizedBox(height: 30),
                const Text('OR', style: TextStyle(color: Colors.grey)), // فاصل نصي
                const SizedBox(height: 20),

                // زر تسجيل الدخول عبر جوجل (تصميم دائري)
                InkWell(
                  onTap: () => _authService.signInWithGoogle(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Image.network(
                      'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                      height: 25,
                      // في حال فشل تحميل الصورة من الإنترنت يعرض حرف G
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'G',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}