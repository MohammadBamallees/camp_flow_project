import 'package:cloud_firestore/cloud_firestore.dart'; // المكتبة الأساسية للتعامل مع قاعدة بيانات Firebase Firestore
import '../models/product_model.dart'; // استيراد موديل المنتج لتحويل البيانات
import '../models/user_model.dart'; // استيراد موديل المستخدم

class DatabaseService {
  // إنشاء نسخة (Instance) من Firestore للوصول إلى المجموعات (Collections) والوثائق (Documents)
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. إدارة ملف المستخدم (User Profile) ---

  // دالة لحفظ أو تحديث بيانات المستخدم في مجموعة 'users'
  Future<void> saveUserData(UserModel user) async {
    // doc(user.uid) تضمن أن لكل مستخدم وثيقة واحدة فقط معرفة بـ UID الخاص به
    // set(user.toMap()) تحول كائن المستخدم إلى الخريطة (Map) التي يفهمها Firestore
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // دالة لجلب بيانات المستخدم من السيرفر باستخدام المعرف (UID)
  Future<UserModel?> getUserData(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      // تحويل البيانات الخام القادمة من Firestore إلى كائن UserModel ليسهل التعامل معه في الواجهات
      return UserModel.fromMap(doc.data()!);
    }
    return null; // إرجاع فارغ إذا لم يجد المستخدم (مثلاً عند أول دخول له)
  }

  // --- 2. إدارة المنتجات (Products) ---

  // دالة لجلب المنتجات بنظام "البث المباشر" (Stream)
  // تمكن التطبيق من تحديث قائمة المنتجات عند العميل فوراً بمجرد تعديلها في لوحة التحكم
  Stream<List<Product>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc.data(), doc.id)).toList());
  }

  // --- 3. إدارة الطلبات (Orders) ---

  // دالة لإرسال طلب شراء جديد إلى مجموعة 'orders'
  Future<void> placeOrder(String uid, List<Product> cartItems, double total) async {
    await _db.collection('orders').add({
      'userId': uid, // ربط الطلب بالمستخدم الذي قام بالشراء
      'items': cartItems.map((p) => p.toMap()).toList(), // تحويل قائمة المنتجات في السلة إلى Map
      'totalPrice': total, // السعر الإجمالي
      'status': 'Processing', // الحالة الابتدائية للطلب (قيد المعالجة)
      'createdAt': FieldValue.serverTimestamp(), // تسجيل وقت الطلب بدقة بناءً على توقيت السيرفر
    });
  }

  // دالة لجلب طلبات مستخدم معين فقط ومراقبة تحديثاتها (تتبع الطلب)
  Stream<QuerySnapshot> streamUserOrders(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid) // تصفية (Filter) لجلب طلبات هذا العميل فقط
        .orderBy('createdAt', descending: true) // ترتيب الطلبات من الأحدث إلى الأقدم
        .snapshots();
  }
}