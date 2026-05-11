import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';

// تعريف كلاس لوحة التحكم كـ StatefulWidget لأن الواجهة تتغير عند التنقل بين التبويبات
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // متغير لتخزين رقم الصفحة الحالية (0 للمنتجات، 1 للطلبات)
  int _selectedIndex = 0;

  // قائمة تحتوي على الصفحات (Widgets) التي سيتم عرضها في المحتوى الرئيسي
  final List<Widget> _screens = [
    const ProductsScreen(), // الشاشة الأولى: إدارة المنتجات
    const OrdersScreen(),   // الشاشة الثانية: إدارة الطلبات
  ];

  // دالة تسجيل الخروج
  void _logout() async {
    await AuthService().logout(); // استدعاء خدمة تسجيل الخروج من Firebase
    if (mounted) {
      // الانتقال لصفحة تسجيل الدخول وحذف سجل التنقل السابق (لحماية الأمان)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام Row لترتيب القائمة الجانبية بجانب المحتوى الرئيسي أفقياً
      body: Row(
        children: [
          // NavigationRail: شريط التنقل الجانبي الاحترافي لوجهات الإدارة
          NavigationRail(
            extended: true, // لإظهار الأيقونة مع النص بجانبها
            selectedIndex: _selectedIndex, // تحديد أي عنصر هو المختار حالياً
            // وظيفة يتم تنفيذها عند الضغط على عنصر في القائمة
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index; // تحديث الحالة لإعادة بناء الواجهة بالصفحة الجديدة
              });
            },
            // الجزء العلوي من القائمة (شعار التطبيق)
            leading: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.admin_panel_settings, size: 50, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text('KASHATAT', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
              ],
            ),
            // تعريف الوجهات (الأزرار) الموجودة في القائمة
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined), // أيقونة المنتجات
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_outlined), // أيقونة الطلبات
                selectedIcon: Icon(Icons.local_shipping),
                label: Text('Orders'),
              ),
            ],
            // الجزء السفلي من القائمة (زر تسجيل الخروج)
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: _logout, // استدعاء دالة تسجيل الخروج
                    tooltip: 'Logout',
                  ),
                ),
              ),
            ),
          ),
          // فاصل رأسي رفيع بين القائمة والمحتوى
          const VerticalDivider(thickness: 1, width: 1),

          // Expanded: تجعل المحتوى الرئيسي يأخذ باقي مساحة الشاشة المتوفرة
          Expanded(
            // عرض الصفحة المختارة بناءً على الرقم المخزن في _selectedIndex
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}