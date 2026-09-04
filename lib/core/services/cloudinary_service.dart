
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../constants/cloudinary_constants.dart';
import '../errors/app_exceptions.dart';

/// نتيجة عملية الرفع
class CloudinaryUploadResult {
  final String secureUrl;    // الرابط المباشر (HTTPS)
  final String publicId;     // المُعرّف في Cloudinary (للحذف لاحقاً)
  final int width;
  final int height;
  final int bytes;
  final String format;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.width,
    required this.height,
    required this.bytes,
    required this.format,
  });

  /// تحويل استجابة Cloudinary API إلى كائن
  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      secureUrl: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      bytes: json['bytes'] as int,
      format: json['format'] as String,
    );
  }
}

/// خدمة Cloudinary الرئيسية
class CloudinaryService {
  final ImagePicker _imagePicker;

  CloudinaryService({
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker();

  // 📸 اختيار الصورة
  Future<XFile> pickImageFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    return _pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  Future<XFile> pickImageFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    return _pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  Future<XFile> _pickImage({
    required ImageSource source,
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) {
        throw const ImagePickException('لم يتم اختيار أي صورة');
      }

      final int fileSize = await pickedFile.length();
      if (fileSize > CloudinaryConstants.maxFileSizeBytes) {
        throw FileSizeException(
          actualSize: fileSize,
          maxSize: CloudinaryConstants.maxFileSizeBytes,
        );
      }

      final String? mimeType = lookupMimeType(pickedFile.name);
      final String extension = pickedFile.name.split('.').last.toLowerCase();

      if (!CloudinaryConstants.allowedExtensions.contains(extension)) {
        throw FileTypeException(extension);
      }

      return pickedFile;
    } on ImagePickException {
      rethrow;
    } on FileSizeException {
      rethrow;
    } on FileTypeException {
      rethrow;
    } catch (e) {
      throw ImagePickException('حدث خطأ أثناء اختيار الصورة: $e');
    }
  }

  // ☁️ رفع الصورة إلى Cloudinary
  Future<CloudinaryUploadResult> uploadImage({
    required XFile imageFile,
    required String folder,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final String fileName = imageFile.name;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConstants.uploadUrl),
      );

      request.fields['upload_preset'] = CloudinaryConstants.uploadPreset;

      final byteData = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          byteData,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CloudinaryUploadResult.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const ImageUploadException(
          'خطأ في إعدادات Cloudinary. تحقق من Cloud Name و Upload Preset',
          code: 'AUTH_ERROR',
        );
      } else {
        throw ImageUploadException(
          'فشل الرفع: رمز الحالة ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ImageUploadException) rethrow;
      throw ImageUploadException('حدث خطأ أثناء رفع الصورة: $e');
    }
  }

  // 🔄 اختيار + رفع في خطوة واحدة
  Future<CloudinaryUploadResult> pickAndUpload({
    required String folder,
    ImageSource source = ImageSource.gallery,
    void Function(double progress)? onProgress,
  }) async {
    final XFile imageFile;

    if (source == ImageSource.camera) {
      imageFile = await pickImageFromCamera();
    } else {
      imageFile = await pickImageFromGallery();
    }

    return uploadImage(
      imageFile: imageFile,
      folder: folder,
      onProgress: onProgress,
    );
  }

  void dispose() {
    //
  }
}
