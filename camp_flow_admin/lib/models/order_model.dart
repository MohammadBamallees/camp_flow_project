// تعريف كلاس (Model) يمثل هيكل "الطلب" في التطبيق
class OrderModel {
  final String id;              // المعرف الفريد للطلب (يأتي من Firestore)
  final String customerName;    // اسم العميل الذي قام بالطلب
  final String customerAddress; // عنوان العميل أو موقعه
  final List<dynamic> items;    // قائمة المنتجات المطلوبة (تخزن كـ List)
  final double totalPrice;      // السعر الإجمالي للطلب
  final String status;          // حالة الطلب (قيد الانتظار، مقبول، ملغي)

  // (Constructor) المنشئ: يستخدم لإنشاء كائن جديد من هذا الكلاس وإعطائه قيم أولية
  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.items,
    required this.totalPrice,
    required this.status,
  });

  // (Factory Method): وظيفتها تحويل البيانات القادمة من Firebase (Map) إلى كائن (Object) يفهمه التطبيق
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id, // نأخذ الـ ID الخاص بالمستند من Firestore
      customerName: map['customerName'] ?? '', // إذا كان الاسم فارغاً نضع نصاً فارغاً (لتجنب الـ Null)
      customerAddress: map['customerAddress'] ?? '',
      items: map['items'] ?? [],
      // تحويل القيمة إلى double لضمان عدم حدوث خطأ برمجي إذا كان الرقم صحيحاً (int)
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending', // الحالة الافتراضية هي قيد الانتظار
    );
  }

  // (Method): وظيفتها تحويل بيانات الكائن إلى (Map) لكي نتمكن من إرسالها وحفظها في Firebase
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerAddress': customerAddress,
      'items': items,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}