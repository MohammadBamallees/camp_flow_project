import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/excel_service.dart';

// الكلاس StatelessWidget لأن تحديث البيانات يتم عبر الـ StreamBuilder وليس بتغيير حالة الكلاس يدوياً
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الجزء العلوي: يحتوي على العنوان وزر الرفع من إكسل
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'إدارة المنتجات', // عنوان الصفحة
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              // زر الرفع الجماعي للمنتجات من ملف Excel
              ElevatedButton.icon(
                onPressed: () => ExcelService.pickAndUploadExcel(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('رفع إكسل (Bulk)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // الجزء السفلي: يعرض قائمة المنتجات الموجودة في قاعدة البيانات
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // فتح قناة اتصال حية مع مجموعة (collection) المنتجات في Firestore
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('حدث خطأ ما'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs; // جلب قائمة الوثائق (Documents)

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  // تحويل كل وثيقة قادمة من Firebase إلى كائن (Product Object) ليسهل التعامل معه
                  final data = docs[index].data() as Map<String, dynamic>;
                  final String docId = docs[index].id; // استخراج المعرف الفريد للمنتج
                  final product = Product.fromMap(data, docId);

                  return ListTile(
                    // عرض صورة المنتج في دائرة (CircleAvatar)
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: product.imageUrl.isNotEmpty
                          ? NetworkImage(product.imageUrl)
                          : null,
                      // في حال حدث خطأ في تحميل الصورة من الرابط، نعرض أيقونة افتراضية
                      onBackgroundImageError: (e, s) => debugPrint(e.toString()),
                      child: product.imageUrl.isEmpty
                          ? const Icon(Icons.image, color: Colors.grey)
                          : null,
                    ),
                    title: Text(product.name), // اسم المنتج
                    subtitle: Text('${product.category} - ${product.subCategory}'), // التصنيفات
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      // عند الضغط على أيقونة التعديل، تظهر نافذة الـ Dialog
                      onPressed: () => _showEditDialog(context, product, docId),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // دالة عرض نافذة التعديل (AlertDialog)
  void _showEditDialog(BuildContext context, Product product, String docId) {
    // تجهيز وحدات التحكم بالنصوص وتعبئتها بالبيانات الحالية للمنتج
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final categoryController = TextEditingController(text: product.category);
    final subCategoryController = TextEditingController(text: product.subCategory);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المنتج')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'القسم')),
              TextField(controller: subCategoryController, decoration: const InputDecoration(labelText: 'القسم الفرعي')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              // إرسال البيانات المعدلة إلى Firebase لتحديث المستند المحدد عبر معرفه (docId)
              await FirebaseFirestore.instance.collection('products').doc(docId).update({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'category': categoryController.text,
                'subCategory': subCategoryController.text,
              });
              if (context.mounted) Navigator.pop(context); // إغلاق النافذة بعد النجاح
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}