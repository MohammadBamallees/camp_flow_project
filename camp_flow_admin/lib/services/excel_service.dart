import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

// كلاس الخدمة المسؤول عن التعامل مع ملفات الإكسل
class ExcelService {
  // دالة لاختيار الملف ورفعه (Static لكي نتمكن من استدعائها بدون إنشاء كائن)
  static Future<void> pickAndUploadExcel(BuildContext context) async {
    try {
      // 1. استخدام مكتبة FilePicker لفتح نافذة اختيار الملفات من جهاز المستخدم
      // حددنا النوع (custom) والامتداد (xlsx) فقط لضمان اختيار ملف إكسل صحيح
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      // إذا قام المستخدم باختيار ملف بالفعل (ولم يغلق النافذة)
      if (result != null) {
        // قراءة محتوى الملف كـ Bytes (بيانات ثنائية)
        var bytes = result.files.first.bytes;
        if (bytes == null) return;

        // 2. استخدام مكتبة Excel لفك تشفير هذه البيانات وتحويلها لجداول مفهومة برمجياً
        var excel = Excel.decodeBytes(bytes);
        // مرجع لمجلد "products" في قاعدة بيانات Firebase
        final CollectionReference products =
        FirebaseFirestore.instance.collection('products');

        int count = 0; // عداد لحساب عدد المنتجات التي تم رفعها بنجاح

        // الدوران على كل الجداول (Sheets) الموجودة داخل ملف الإكسل
        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows; // جلب كل الصفوف في الجدول الحالي

          // 3. تخطي الصف الأول (Index 0) لأنه عادة يحتوي على العناوين (Name, Price...)
          // والبدء بالدوران من الصف الثاني (Index 1) الذي يحتوي البيانات الفعلية
          for (int i = 1; i < rows.length; i++) {
            var row = rows[i];

            // فحص أمني: إذا كان الصف فارغاً أو اسم المنتج (أول خلية) فارغاً، نتخطى هذا الصف
            if (row.isEmpty || row[0] == null || row[0]?.value == null) continue;

            // 4. قراءة البيانات من الخلايا حسب ترتيب الأعمدة المتفق عليه
            // العمود A=0، B=1، وهكذا...
            String name        = _getCellValue(row[0]); // الاسم
            String priceStr    = _getCellValue(row[1]); // السعر (كنص أولاً)
            String description = _getCellValue(row[2]); // الوصف
            String imageUrl    = _getCellValue(row[3]); // رابط الصورة
            String category    = _getCellValue(row[4]); // القسم الرئيسي
            String subCategory = _getCellValue(row[5]); // القسم الفرعي

            // 5. إنشاء وثيقة جديدة في Firebase والحصول على معرف (ID) تلقائي لها
            final docRef = products.doc();

            // تحويل البيانات القادمة من الإكسل إلى كائن من نوع Product
            final product = Product(
              id: docRef.id,
              name: name,
              price: double.tryParse(priceStr) ?? 0.0, // محاولة تحويل السعر لرقم
              imageUrl: imageUrl,
              category: category,
              subCategory: subCategory,
              description: description,
            );

            // 6. رفع بيانات المنتج بصيغة Map إلى Firestore
            await docRef.set(product.toMap());
            count++; // زيادة العداد بعد كل عملية رفع ناجحة
          }
        }

        // 7. إظهار رسالة نجاح منبثقة (SnackBar) للمدير تخبره بالعدد النهائي
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم رفع $count منتج بنجاح إلى متجر كشتات!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // في حال حدوث أي خطأ (مثلاً الملف تالف)، إظهار رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء الرفع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // دالة مساعدة وظيفتها استلام الخلية والتأكد أنها ليست Null وتحويل محتواها لنص نظيف (Trim)
  static String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }
}