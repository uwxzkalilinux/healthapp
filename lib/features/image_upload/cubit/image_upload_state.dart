import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';

sealed class ImageUploadState extends Equatable {
  const ImageUploadState();

  @override
  List<Object?> get props => [];
}

class ImageUploadInitial extends ImageUploadState {
  const ImageUploadInitial();
}

class ImagePicked extends ImageUploadState {
  final XFile imageFile;

  const ImagePicked(this.imageFile);

  @override
  List<Object?> get props => [imageFile.path];
}

class ImageUploading extends ImageUploadState {
  final XFile imageFile;
  final double progress;

  const ImageUploading({
    required this.imageFile,
    required this.progress,
  });

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [imageFile.path, progress];
}

class ImageUploadSuccess extends ImageUploadState {
  final String imageUrl;
  final String publicId;
  final XFile localFile;

  const ImageUploadSuccess({
    required this.imageUrl,
    required this.publicId,
    required this.localFile,
  });

  @override
  List<Object?> get props => [imageUrl, publicId];
}

class ImageUploadFailure extends ImageUploadState {
  final String errorMessage;
  final XFile? imageFile;

  const ImageUploadFailure({
    required this.errorMessage,
    this.imageFile,
  });

  @override
  List<Object?> get props => [errorMessage, imageFile?.path];
}
