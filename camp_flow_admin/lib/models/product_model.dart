// تعريف كلاس يمثل هيكل "المنتج" داخل التطبيق
class Product {
  final String id;           // المعرف الفريد للمنتج
  final String name;         // اسم المنتج
  final double price;        // سعر المنتج (نوع double للأرقام العشرية)
  final String description;  // وصف المنتج وتفاصيله
  final String imageUrl;    // رابط صورة المنتج المخزنة في السيرفر
  final String category;     // القسم الرئيسي (مثل: أدوات تخييم)
  final String subCategory;  // القسم الفرعي (مثل: حقائب)

  // المنشئ (Constructor): لإنشاء كائن جديد وتعبئة بياناته
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.subCategory,
  });

  // 1. (Factory Method): لتحويل البيانات القادمة من Firestore (تطبيق الموبايل)
  // تأخذ الخريطة (Map) والمعرف (ID) وتحولهم إلى كائن Product
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? 'No Name', // وضع قيمة افتراضية في حال كان الاسم فارغاً
      price: _parsePrice(data['price']), // استخدام دالة المعالجة للتأكد من نوع الرقم
      description: data['description'] ?? '',
      // التأكد من جلب الصورة سواء كان الحقل اسمه imageUrl أو image
      imageUrl: data['imageUrl'] ?? data['image'] ?? '',
      category: data['category'] ?? 'General',
      subCategory: data['subCategory'] ?? '',
    );
  }

  // 2. (Factory Method): لتحويل البيانات القادمة من ماب عادي (تستخدم غالباً في الويب/الأدمن)
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

  // دالة مساعدة (Helper Function): وظيفتها "تنظيف" وتحويل البيانات القادمة للسعر
  // صممت لتكون ذكية وتتعامل مع (النصوص، الأرقام الصحيحة، أو القيم الفارغة)
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0; // إذا كان فارغاً نرجع صفر
    if (price is num) return price.toDouble(); // إذا كان رقماً نحوله لـ double
    if (price is String) return double.tryParse(price) ?? 0.0; // إذا كان نصاً نحاول تحويله لرقم
    return 0.0;
  }

  // 3. (Method): تحويل الكائن إلى خريطة (Map) بصيغة JSON قبل رفعه لقاعدة البيانات
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