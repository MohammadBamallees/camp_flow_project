// تعريف الكلاس الخاص ببيانات المستخدم (العميل)
class UserModel {
  // تعريف الخصائص الأساسية للمستخدم كمتغيرات نهائية (final) لضمان استقرار البيانات
  final String uid;          // المعرف الفريد للمستخدم القادم من Firebase Auth
  final String name;         // اسم العميل
  final String address;      // عنوان السكن أو التوصيل
  final String phone;        // رقم الجوال للتواصل
  final String profileImage; // رابط الصورة الشخصية المخزن كنص (URL)

  // المنشئ (Constructor): لإنشاء كائن مستخدم جديد
  // لاحظ استخدام 'this.profileImage = ""' كقيمة افتراضية إذا لم يرفع العميل صورة
  UserModel({
    required this.uid,
    required this.name,
    required this.address,
    required this.phone,
    this.profileImage = "",
  });

  // دالة تحويل الكائن (Object) إلى خريطة بيانات (Map)
  // نستخدمها عند التسجيل أو تحديث الملف الشخصي لإرسال البيانات إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'phone': phone,
      'profileImage': profileImage,
    };
  }

  // محول بيانات (Factory Constructor): لتحويل البيانات القادمة من Firestore إلى كائن UserModel
  // نستخدم الـ factory لتمكين معالجة البيانات والتعامل مع القيم الفارغة (Null Safety)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      // استخدام المعامل '??' لضمان وضع نص فارغ إذا كانت القيمة مفقودة في قاعدة البيانات
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }
}