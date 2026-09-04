/// أنواع الأخطاء المخصصة للتطبيق
/// ─────────────────────────────────────────────

/// خطأ عام في رفع الصورة
class ImageUploadException implements Exception {
  final String message;
  final String? code;

  const ImageUploadException(this.message, {this.code});

  @override
  String toString() => 'ImageUploadException: $message (code: $code)';
}

/// خطأ في اختيار الصورة
class ImagePickException implements Exception {
  final String message;

  const ImagePickException(this.message);

  @override
  String toString() => 'ImagePickException: $message';
}

/// خطأ في حجم الملف
class FileSizeException implements Exception {
  final int actualSize;
  final int maxSize;

  const FileSizeException({required this.actualSize, required this.maxSize});

  String get message =>
      'حجم الملف (${(actualSize / 1024 / 1024).toStringAsFixed(1)} MB) '
      'يتجاوز الحد المسموح (${(maxSize / 1024 / 1024).toStringAsFixed(0)} MB)';

  @override
  String toString() => 'FileSizeException: $message';
}

/// خطأ في نوع الملف
class FileTypeException implements Exception {
  final String extension;

  const FileTypeException(this.extension);

  String get message => 'نوع الملف "$extension" غير مدعوم';

  @override
  String toString() => 'FileTypeException: $message';
}
