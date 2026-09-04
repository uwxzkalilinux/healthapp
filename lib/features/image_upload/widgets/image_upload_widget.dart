import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/image_upload_cubit.dart';
import '../cubit/image_upload_state.dart';

class ImageUploadWidget extends StatelessWidget {
  final String folder;
  final String? currentImageUrl;
  final ValueChanged<String>? onImageUploaded;
  final double height;
  final double width;
  final double borderRadius;

  const ImageUploadWidget({
    super.key,
    required this.folder,
    this.currentImageUrl,
    this.onImageUploaded,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageUploadCubit, ImageUploadState>(
      listener: (context, state) {
        if (state is ImageUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('تم رفع الصورة بنجاح'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          onImageUploaded?.call(state.imageUrl);
        }

        if (state is ImageUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: state.imageFile != null
                  ? SnackBarAction(
                      label: 'إعادة',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<ImageUploadCubit>().retry(folder: folder);
                      },
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: _getBorderColor(state),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              color: Colors.grey.shade100,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(context, state),
          ),
        );
      },
    );
  }

  Color _getBorderColor(ImageUploadState state) {
    if (state is ImageUploading) return Colors.blue.shade400;
    if (state is ImageUploadSuccess) return Colors.green.shade400;
    if (state is ImageUploadFailure) return Colors.red.shade400;
    return Colors.grey.shade300;
  }

  Widget _buildContent(BuildContext context, ImageUploadState state) {
    return switch (state) {
      ImageUploading() => _buildUploadingState(state),
      ImageUploadSuccess() => _buildSuccessState(state),
      ImagePicked() => _buildPickedState(context, state),
      ImageUploadFailure() => _buildFailureState(state),
      _ => _buildInitialState(),
    };
  }

  Widget _buildImage(XFile file) {
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    } else {
      return Image.file(io.File(file.path), fit: BoxFit.cover);
    }
  }

  Widget _buildInitialState() {
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: currentImageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => _buildPlaceholder(),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'تغيير الصورة',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'اضغط لإضافة صورة',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG, WEBP — حتى 5 ميجابايت',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPickedState(BuildContext context, ImagePicked state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(state.imageFile),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ImageUploadCubit>().uploadPickedImage(folder: folder);
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('رفع الصورة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState(ImageUploading state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.4,
          child: _buildImage(state.imageFile),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: state.progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade400,
                      ),
                    ),
                    Text(
                      '${state.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'جاري رفع الصورة...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(ImageUploadSuccess state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(state.localFile),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('تم الرفع', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureState(ImageUploadFailure state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade400, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اضغط لإعادة المحاولة',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final cubit = context.read<ImageUploadCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'اختر مصدر الصورة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.photo_library, color: Colors.blue.shade600),
                ),
                title: const Text('المعرض'),
                subtitle: const Text('اختر صورة من معرض الصور'),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickAndUpload(
                    folder: folder,
                    source: ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: Icon(Icons.camera_alt, color: Colors.green.shade600),
                ),
                title: const Text('الكاميرا'),
                subtitle: const Text('التقط صورة جديدة'),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickAndUpload(
                    folder: folder,
                    source: ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
