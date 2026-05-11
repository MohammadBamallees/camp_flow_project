import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// كلاس الخدمة المسؤول عن عمليات المصادقة (Auth)
class AuthService {
  // إنشاء نسخة (Instance) من Firebase Auth للتعامل مع واجهة برمجة التطبيقات الخاصة بجوجل
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // دالة لحفظ حالة الجلسة (Session) محلياً في ذاكرة الهاتف
  // نستخدمها لكي يظل المستخدم مسجل دخوله حتى لو أغلق التطبيق
  Future<void> saveSession(bool isLoggedIn) async {
    // الحصول على نسخة من SharedPreferences (مخزن البيانات البسيط في الهاتف)
    final prefs = await SharedPreferences.getInstance();
    // حفظ قيمة منطقية (صح أو خطأ) تحت مفتاح 'isLoggedIn'
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // دالة (Static) للتحقق من حالة الدخول عند تشغيل التطبيق أول مرة
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // جلب القيمة المخزنة؛ إذا كانت فارغة (Null) نعتبرها خطأ (false)
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // دالة إنشاء حساب جديد (Admin Register)
  Future<String?> register(String email, String password) async {
    try {
      // محاولة إنشاء مستخدم جديد في قاعدة بيانات Firebase باستخدام الإيميل والباسورد
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // في حال النجاح، نحفظ الجلسة في الهاتف كـ "مسجل دخول"
      await saveSession(true);
      return null; // إرجاع null تعني أن العملية نجحت ولا توجد أخطاء
    } catch (e) {
      // في حال حدوث خطأ (مثل: الإيميل موجود مسبقاً)، نرجع نص الخطأ
      return e.toString();
    }
  }

  // دالة تسجيل الدخول (Admin Login)
  Future<String?> login(String email, String password) async {
    try {
      // إرسال البيانات لـ Firebase للتأكد من صحتها
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // حفظ الجلسة محلياً لضمان بقاء المستخدم مسجلاً
      await saveSession(true);
      return null; // نجاح
    } catch (e) {
      // إرجاع رسالة الخطأ (مثل: كلمة المرور خاطئة)
      return e.toString();
    }
  }

  // دالة تسجيل الخروج (Logout)
  Future<void> logout() async {
    // الخروج من سيرفرات Firebase
    await _auth.signOut();
    // تحديث الجلسة في الهاتف إلى "غير مسجل دخول"
    await saveSession(false);
  }
}