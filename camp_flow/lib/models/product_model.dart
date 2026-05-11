// تعريف الكلاس الذي يمثل هيكل المنتج في التطبيق
class Product {
  // تعريف الخصائص الأساسية للمنتج كمتغيرات نهائية (final) لا تتغير بعد التخصيص
  final String id;           // المعرف الفريد للمنتج في قاعدة البيانات
  final String name;         // اسم المنتج
  final double price;        // سعر المنتج (رقم عشري)
  final String description;  // وصف تفصيلي للمنتج
  final String imageUrl;     // رابط الصورة الخاص بالمنتج
  final String category;     // القسم الرئيسي (مثلاً: أدوات تخييم)
  final String subCategory;  // القسم الفرعي (مثلاً: خيام)

  // المنشئ (Constructor): يستخدم لإنشاء كائن جديد وتعبئة كل البيانات المطلوبة
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.subCategory,
  });

  // محول بيانات (Factory Constructor): لتحويل البيانات القادمة من Firebase Firestore
  // نستخدم factory لأنه يسمح لنا بمعالجة البيانات قبل بناء الكائن الفعلي
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id, // المعرف يأتي من معرف الوثيقة (Document ID) وليس من داخل الحقول
      name: data['name'] ?? 'No Name', // إذا كان الاسم فارغاً نضع قيمة افتراضية
      price: _parsePrice(data['price']), // استدعاء دالة المعالجة الذكية للسعر
      description: data['description'] ?? '', // التعامل مع الوصف إذا كان فارغاً
      // فحص وجود الصورة تحت مفتاح imageUrl أو image لزيادة مرونة الكود
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      category: data['category'] ?? 'General', // القسم الافتراضي
      subCategory: data['subCategory'] ?? '',
    );
  }

  // محول بيانات (Factory Constructor): يستخدم في جزء الويب أو الأدمن للتعامل مع الماب العادي
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: _parsePrice(map['price']),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
    );
  }

  // دالة مساعدة (Private Method) وظيفتها ضمان تحويل السعر إلى رقم عشري (double) مهما كان نوعه
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0; // إذا كان السعر غير موجود نرجعه صفر
    if (price is num) return price.toDouble(); // إذا كان رقماً (int أو double) نحوله لـ double
    if (price is String) {
      // إذا كان نصاً، نقوم بتنظيفه من أي رموز غير رقمية (مثل $ أو العملة) باستخدام RegExp
      String cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
      // محاولة تحويل النص النظيف إلى رقم، وإذا فشل نرجعه صفر
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0; // أي نوع بيانات آخر غير متوقع يرجع صفر
  }

  // دالة تحويل الكائن البرمجي إلى خريطة بيانات (Map) لرفعه إلى Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'subCategory': subCategory,
    };
  }
}