import 'package:flutter/material.dart';
import '../models/product_model.dart';

// استخدام ChangeNotifier يجعل الكلاس قادراً على تنبيه الواجهات (UI) عند حدوث أي تغيير
class CartProvider with ChangeNotifier {
  // قائمة خاصة (Private) لتخزين المنتجات المضافة للسلة، تبدأ فارغة
  final List<Product> _items = [];

  // "Getter" للسماح للواجهات بقراءة محتويات السلة دون القدرة على تعديلها مباشرة
  List<Product> get items => _items;

  // دالة ذكية لحساب إجمالي السعر باستخدام fold
  // تبدأ من الصفر (0) وتجمع سعر كل منتج في القائمة على المجموع (sum)
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);

  // دالة لإضافة منتج جديد للسلة
  void addToCart(Product product) {
    _items.add(product); // إضافة المنتج للقائمة الخاصة
    notifyListeners();   // "تنبيه المستمعين": تخبر فلاتر بإعادة بناء الشاشات التي تعرض السلة لتظهر البيانات الجديدة
  }

  // دالة لحذف منتج معين من السلة
  void removeFromCart(Product product) {
    _items.remove(product); // حذف المنتج من القائمة
    notifyListeners();      // تحديث الواجهة فوراً بعد الحذف
  }

  // دالة لإفراغ السلة بالكامل (تستخدم عادة بعد إتمام عملية الشراء بنجاح)
  void clearCart() {
    _items.clear();    // حذف كل العناصر
    notifyListeners(); // إشعار التطبيق بأن السلة أصبحت فارغة
  }
}