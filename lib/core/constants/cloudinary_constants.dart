/// ثوابت إعدادات Cloudinary
/// ─────────────────────────────────────────────
/// يرجى استبدال YOUR_CLOUD_NAME و YOUR_UPLOAD_PRESET بمعلومات حسابك
class CloudinaryConstants {
  CloudinaryConstants._(); // لمنع إنشاء instance

  /// اسم السحابة الخاص بك من Cloudinary Dashboard
  static const String cloudName = 'fc6sdrlz'; // تم إصلاح الحرف السري!

  /// اسم الـ Upload Preset (Unsigned) الذي أنشأته
  static const String uploadPreset = 'flutter_upload'; // تم التحديث بنجاح

  /// رابط الرفع الأساسي — لا تُعدّل
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// المجلدات في Cloudinary لتنظيم الصور
  static const String medicineFolderPath = 'health_app/medicines';
  static const String diseaseFolderPath = 'health_app/diseases';
  static const String articleFolderPath = 'health_app/articles';
  static const String firstAidFolderPath = 'health_app/first_aid';
  static const String profileFolderPath = 'health_app/profiles';

  /// الحد الأقصى لحجم الصورة (5 ميجابايت)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// الامتدادات المسموحة
  static const List<String> allowedExtensions = [
    'jpg', 'jpeg', 'png', 'webp',
  ];
}
