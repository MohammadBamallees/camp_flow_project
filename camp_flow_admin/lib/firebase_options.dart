// هذا التعليق يخبرك أن هذا الملف تم إنشاؤه آلياً بواسطة أداة (FlutterFire CLI)
// ignore_for_file: type=lint
// السطر السابق يخبر محرر الأكواد بتجاهل أي تحذيرات تتعلق بتنسيق الكود هنا

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// كلاس يحتوي على الإعدادات الافتراضية لربط التطبيق بـ Firebase
class DefaultFirebaseOptions {

  // دالة (Getter) تقوم بتحديد نوع المنصة التي يعمل عليها التطبيق حالياً (ويب، أندرويد، آيفون)
  // وبناءً عليها تعطي التطبيق مفاتيح الربط المناسبة
  static FirebaseOptions get currentPlatform {

    // إذا كان التطبيق يعمل حالياً على متصفح "الويب"
    if (kIsWeb) {
      return web; // قم بإرجاع الإعدادات الخاصة بالويب (الموجودة في الأسفل)
    }

    // إذا لم يكن ويب، سيقوم بفحص باقي المنصات
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      // التطبيق سيرمي خطأ (Error) إذا حاولنا تشغيله على أندرويد
      // لأنك لم تقم بتهيئة Firebase للأندرويد في هذا المشروع حتى الآن
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
      // نفس الشيء، سيرمي خطأ إذا حاولنا تشغيله على آيفون
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // هذا الكائن (Object) يحتوي على كل مفاتيح الربط السرية الخاصة بمشروعك (Campflow) لنسخة الويب
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDKE6b_G4_Gx7P584xGPGRwWoz7vWDki8I', // مفتاح الـ API للاتصال بـ Google
    appId: '1:526206242809:web:469ec75c29b63ceb9e7728', // المعرف الخاص بتطبيق الويب داخل مشروعك
    messagingSenderId: '526206242809', // معرف لإرسال الإشعارات
    projectId: 'campflow-d0f0a', // اسم أو معرف مشروعك في منصة Firebase
    authDomain: 'campflow-d0f0a.firebaseapp.com', // النطاق الخاص بعمليات تسجيل الدخول
    storageBucket: 'campflow-d0f0a.firebasestorage.app', // رابط مساحة التخزين (لرفع الصور والإكسل)
    measurementId: 'G-MCZXRZRBYY', // معرف خاص بتحليلات جوجل (Google Analytics)
  );
}