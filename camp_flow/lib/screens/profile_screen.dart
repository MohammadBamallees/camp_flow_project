import 'dart:convert'; // مكتبة لتحويل الصور من بايتات إلى نصوص مشفرة (Base64) والعكس
import 'dart:typed_data'; // للتعامل مع بيانات الصورة كقائمة من الأرقام الثنائية في الذاكرة
import 'package:firebase_auth/firebase_auth.dart'; // للتحقق من هوية المستخدم المسجل حالياً
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // مكتبة تسمح بفتح معرض الصور أو الكاميرا
import '../models/user_model.dart'; // الموديل الخاص ببيانات المستخدم
import '../services/database_service.dart'; // خدمة التعامل مع Firestore
import '../services/auth_service.dart'; // خدمة تسجيل الدخول والخروج

// الشاشة StatefulWidget لأنها تتحدث عند اختيار صورة أو تحميل البيانات
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // تعريف متحكمات النصوص (Controllers) لسحب ما يكتبه المستخدم في الحقول
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = false; // متغير للتحكم في ظهور دائرة التحميل أثناء الحفظ
  String _base64Image = ""; // متغير لتخزين نص الصورة المشفر (بدلاً من رابط URL)

  @override
  void initState() {
    super.initState();
    _loadUserData(); // بمجرد فتح الشاشة، نقوم بجلب بيانات المستخدم لعرضها
  }

  // دالة لجلب بيانات المستخدم الحالية من السيرفر
  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // البحث عن بيانات المستخدم في Firestore باستخدام الـ UID الخاص به
      final userData = await _db.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          // تعبئة الحقول بالبيانات القادمة من السيرفر
          _nameController.text = userData.name;
          _addressController.text = userData.address;
          _phoneController.text = userData.phone;
          _base64Image = userData.profileImage; // وضع نص الصورة في المتجر المحلي للشاشة
        });
      }
    }
  }

  // دالة لاختيار صورة من معرض الهاتف
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // اختيار صورة مع تقليل جودتها لضمان عدم تجاوز حجم النص المسموح في Firestore
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (image != null) {
      // تحويل ملف الصورة إلى بايتات (Bytes)
      Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        // تشفير البايتات إلى نص (Base64) ليتم تخزينه كـ String
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  // دالة لحذف الصورة من الواجهة فقط (قبل ضغط حفظ)
  void _removeImage() {
    setState(() {
      _base64Image = "";
    });
  }

  // دالة حفظ التعديلات النهائية للسيرفر
  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true); // إظهار مؤشر التحميل

    // إنشاء كائن مستخدم جديد يحتوي على البيانات المحدثة من الحقول
    UserModel newUser = UserModel(
      uid: user.uid,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      profileImage: _base64Image, // حفظ نص الصورة المشفر
    );

    // إرسال الكائن لخدمة قاعدة البيانات لحفظه في Firestore
    await _db.saveUserData(newUser);
    setState(() => _isLoading = false); // إخفاء مؤشر التحميل

    if (mounted) {
      // إظهار رسالة نجاح والرجوع للشاشة الرئيسية
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully'))
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // لون أسود فخم متناسق مع التطبيق
      appBar: AppBar(
        title: const Text('Profile Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // للسماح بالتمرير عند ظهور لوحة المفاتيح
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Center(
              child: Stack( // وضع أيقونات الإضافة والحذف فوق دائرة الصورة
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4A80F0), width: 2), // إطار أزرق حول الصورة
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1A1A1A),
                      // فك تشفير النص Base64 وتحويله لصورة تعرض في الذاكرة
                      backgroundImage: _base64Image.isNotEmpty
                          ? MemoryImage(base64Decode(_base64Image))
                          : null,
                      // أيقونة كاميرا تظهر فقط إذا كانت الصورة فارغة
                      child: _base64Image.isEmpty
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                  // زر "الزائد" لإضافة صورة جديدة
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  // زر "السلة" لحذف الصورة (يظهر فقط إذا كانت هناك صورة معروضة)
                  if (_base64Image.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // استخدام دالة مخصصة لبناء حقول الإدخال (الاسم، العنوان، الهاتف)
            _buildTextField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(_addressController, 'Delivery Address', Icons.location_on_outlined),
            const SizedBox(height: 15),
            _buildTextField(_phoneController, 'Phone Number', Icons.phone_android_outlined, type: TextInputType.phone),
            const SizedBox(height: 40),

            // زر حفظ التغييرات
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A80F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // زر تسجيل الخروج من التطبيق
            TextButton(
              onPressed: () async {
                await AuthService().signOut(); // استدعاء دالة الخروج من Firebase
                if (mounted) Navigator.popUntil(context, (route) => route.isFirst); // العودة لأول شاشة في التطبيق
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة (Widget) لتصميم حقول النص بشكل موحد وتقليل تكرار الكود
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type, // تحديد نوع لوحة المفاتيح (نص أو أرقام)
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey), // أيقونة في بداية الحقل
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1A1A), // لون خلفية الحقل
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}