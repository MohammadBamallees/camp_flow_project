import 'package:firebase_auth/firebase_auth.dart'; // المكتبة الأساسية للتعامل مع نظام التحقق في فايربيز
import 'package:google_sign_in/google_sign_in.dart'; // المكتبة الخاصة بالدخول عبر حسابات جوجل

class AuthService {
  // إنشاء نسخ (Instances) من الخدمات لاستخدام وظائفها داخل الكلاس
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream (بث مباشر) لمراقبة حالة المستخدم:
  // هذه الدالة تخبر التطبيق فوراً إذا كان المستخدم "داخل" أو "خارج" الحساب
  Stream<User?> get userStream => _auth.authStateChanges();

  // --- 1. تسجيل الدخول بالبريد الإلكتروني والباسوورد ---
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // إرسال البيانات لفايربيز والانتظار (await) للتحقق منها
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user; // إرجاع بيانات المستخدم في حال النجاح
    } catch (e) {
      return null; // إرجاع null في حال حدوث خطأ (مثل باسوورد خاطئ)
    }
  }

  // --- 2. إنشاء حساب جديد بالبريد الإلكتروني ---
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      // إنشاء مستخدم جديد في قاعدة بيانات فايربيز
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      return null; // إرجاع null في حال فشل الإنشاء (مثل إيميل مستخدم سابقاً)
    }
  }

  // --- 3. تسجيل الدخول باستخدام جوجل (Google Sign In) ---
  Future<User?> signInWithGoogle() async {
    try {
      // أ. فتح نافذة اختيار حسابات جوجل الموجودة في الهاتف
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // المستخدم أغلق النافذة دون اختيار حساب

      // ب. طلب بيانات المصادقة (Tokens) من جوجل
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ج. تحويل بيانات جوجل إلى "هوية" (Credential) يفهمها نظام فايربيز
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // د. تسجيل الدخول النهائي في فايربيز باستخدام هوية جوجل
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  // --- 4. تسجيل الخروج ---
  Future<void> signOut() async {
    // تسجيل الخروج من جوجل أولاً لضمان عدم الدخول التلقائي في المرة القادمة
    await _googleSignIn.signOut();
    // تسجيل الخروج من فايربيز
    await _auth.signOut();
  }
}