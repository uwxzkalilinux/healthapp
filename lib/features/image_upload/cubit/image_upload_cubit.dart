
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/errors/app_exceptions.dart';
import 'image_upload_state.dart';

class ImageUploadCubit extends Cubit<ImageUploadState> {
  final CloudinaryService _cloudinaryService;
  final FirebaseFirestore _firestore;

  ImageUploadCubit({
    required CloudinaryService cloudinaryService,
    FirebaseFirestore? firestore,
  })  : _cloudinaryService = cloudinaryService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ImageUploadInitial());

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile file;
      if (source == ImageSource.camera) {
        file = await _cloudinaryService.pickImageFromCamera();
      } else {
        file = await _cloudinaryService.pickImageFromGallery();
      }
      emit(ImagePicked(file));
    } on ImagePickException catch (e) {
      if (e.message.contains('لم يتم اختيار')) {
        emit(const ImageUploadInitial());
      } else {
        emit(ImageUploadFailure(errorMessage: e.message));
      }
    } on FileSizeException catch (e) {
      emit(ImageUploadFailure(errorMessage: e.message));
    } on FileTypeException catch (e) {
      emit(ImageUploadFailure(errorMessage: e.message));
    } catch (e) {
      emit(ImageUploadFailure(errorMessage: 'خطأ غير متوقع: $e'));
    }
  }

  Future<void> uploadPickedImage({required String folder}) async {
    final currentState = state;
    if (currentState is! ImagePicked) {
      emit(const ImageUploadFailure(
        errorMessage: 'يرجى اختيار صورة أولاً',
      ));
      return;
    }
    await _uploadFile(file: currentState.imageFile, folder: folder);
  }

  Future<void> pickAndUpload({
    required String folder,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile file;
      if (source == ImageSource.camera) {
        file = await _cloudinaryService.pickImageFromCamera();
      } else {
        file = await _cloudinaryService.pickImageFromGallery();
      }
      await _uploadFile(file: file, folder: folder);
    } on ImagePickException catch (e) {
      if (e.message.contains('لم يتم اختيار')) return;
      emit(ImageUploadFailure(errorMessage: e.message));
    } on FileSizeException catch (e) {
      emit(ImageUploadFailure(errorMessage: e.message));
    } on FileTypeException catch (e) {
      emit(ImageUploadFailure(errorMessage: e.message));
    }
  }

  Future<void> saveImageUrlToFirestore({
    required String collection,
    required String documentId,
    String fieldName = 'imageURL',
  }) async {
    final currentState = state;
    if (currentState is! ImageUploadSuccess) {
      emit(const ImageUploadFailure(
        errorMessage: 'لا يوجد رابط صورة للحفظ. ارفع الصورة أولاً',
      ));
      return;
    }
    try {
      await _firestore.collection(collection).doc(documentId).update({
        fieldName: currentState.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      emit(ImageUploadFailure(
        errorMessage: 'فشل حفظ الرابط في قاعدة البيانات: ${e.message}',
        imageFile: currentState.localFile,
      ));
    }
  }

  Future<String?> pickUploadAndSave({
    required String folder,
    required String collection,
    required String documentId,
    String fieldName = 'imageURL',
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile file;
      if (source == ImageSource.camera) {
        file = await _cloudinaryService.pickImageFromCamera();
      } else {
        file = await _cloudinaryService.pickImageFromGallery();
      }

      emit(ImageUploading(imageFile: file, progress: 0));

      final result = await _cloudinaryService.uploadImage(
        imageFile: file,
        folder: folder,
        onProgress: (progress) {
          emit(ImageUploading(imageFile: file, progress: progress));
        },
      );

      await _firestore.collection(collection).doc(documentId).update({
        fieldName: result.secureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      emit(ImageUploadSuccess(
        imageUrl: result.secureUrl,
        publicId: result.publicId,
        localFile: file,
      ));

      return result.secureUrl;
    } on ImagePickException catch (e) {
      if (!e.message.contains('لم يتم اختيار')) {
        emit(ImageUploadFailure(errorMessage: e.message));
      }
      return null;
    } on ImageUploadException catch (e) {
      emit(ImageUploadFailure(errorMessage: e.message));
      return null;
    } on FirebaseException catch (e) {
      emit(ImageUploadFailure(
        errorMessage: 'تم رفع الصورة لكن فشل الحفظ: ${e.message}',
      ));
      return null;
    }
  }

  Future<void> retry({required String folder}) async {
    final currentState = state;
    if (currentState is ImageUploadFailure && currentState.imageFile != null) {
      await _uploadFile(file: currentState.imageFile!, folder: folder);
    }
  }

  void reset() {
    emit(const ImageUploadInitial());
  }

  Future<void> _uploadFile({
    required XFile file,
    required String folder,
  }) async {
    try {
      emit(ImageUploading(imageFile: file, progress: 0));
      final result = await _cloudinaryService.uploadImage(
        imageFile: file,
        folder: folder,
        onProgress: (progress) {
          emit(ImageUploading(imageFile: file, progress: progress));
        },
      );
      emit(ImageUploadSuccess(
        imageUrl: result.secureUrl,
        publicId: result.publicId,
        localFile: file,
      ));
    } on ImageUploadException catch (e) {
      emit(ImageUploadFailure(
        errorMessage: e.message,
        imageFile: file,
      ));
    } catch (e) {
      emit(ImageUploadFailure(
        errorMessage: 'خطأ غير متوقع: $e',
        imageFile: file,
      ));
    }
  }
}
