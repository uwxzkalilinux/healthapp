import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/article.dart';
import '../../../../core/services/article_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';
import '../../../../core/constants/cloudinary_constants.dart';

class AddArticlePage extends StatefulWidget {
  final Article? articleToEdit;
  const AddArticlePage({super.key, this.articleToEdit});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  bool _isLoading = false;
  String _coverImageUrl = '';
  Uint8List? _coverImageBytes;

  // Content images
  final List<String> _contentImageUrls = [];
  final List<Uint8List> _contentImageBytesNew = [];

  @override
  void initState() {
    super.initState();
    if (widget.articleToEdit != null) {
      _titleController.text = widget.articleToEdit!.title;
      _summaryController.text = widget.articleToEdit!.summary;
      _contentController.text = widget.articleToEdit!.content;
      _authorController.text = widget.articleToEdit!.author;
      _coverImageUrl = widget.articleToEdit!.imageUrl;
      _contentImageUrls.addAll(widget.articleToEdit!.contentImages);
    } else {
      _authorController.text = 'فريق التحرير الطبي';
    }
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _coverImageBytes = bytes;
      });
    }
  }

  Future<void> _pickContentImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _contentImageBytesNew.add(bytes);
      });
    }
  }

  Future<String?> _uploadBytes(Uint8List bytes) async {
    try {
      final mimeType = lookupMimeType('', headerBytes: bytes) ?? 'image/jpeg';
      final dio = Dio();

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.${mimeType.split('/').last}',
          contentType: MediaType.parse(mimeType),
        ),
        'upload_preset': CloudinaryConstants.uploadPreset,
      });

      final response = await dio.post(CloudinaryConstants.uploadUrl, data: formData);
      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  void _removeExistingContentImage(int index) {
    setState(() {
      _contentImageUrls.removeAt(index);
    });
  }

  void _removeNewContentImage(int index) {
    setState(() {
      _contentImageBytesNew.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_coverImageUrl.isEmpty && _coverImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة غلاف للمقال')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload cover image
      String coverUrl = _coverImageUrl;
      if (_coverImageBytes != null) {
        final uploadedUrl = await _uploadBytes(_coverImageBytes!);
        if (uploadedUrl != null) coverUrl = uploadedUrl;
      }

      // Upload new content images
      final List<String> allContentImages = List.from(_contentImageUrls);
      for (final bytes in _contentImageBytesNew) {
        final url = await _uploadBytes(bytes);
        if (url != null) allContentImages.add(url);
      }

      final article = Article(
        id: widget.articleToEdit?.id ?? '',
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        author: _authorController.text.trim(),
        imageUrl: coverUrl,
        createdAt: widget.articleToEdit?.createdAt ?? DateTime.now(),
        contentImages: allContentImages,
      );

      if (widget.articleToEdit == null) {
        await ArticleService().addArticle(article);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر المقال بنجاح')));
      } else {
        await ArticleService().updateArticle(article);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل المقال بنجاح')));
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.articleToEdit != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل المقال' : 'نشر مقال جديد'),
          backgroundColor: AppTheme.mintBackground,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cover image
              const Text('صورة الغلاف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                  ),
                  child: _coverImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(_coverImageBytes!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : _coverImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(_coverImageUrl, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: AppTheme.primaryTeal.withOpacity(0.6)),
                                const SizedBox(height: 8),
                                const Text('اضغط لاختيار صورة الغلاف', style: TextStyle(color: AppTheme.primaryTeal)),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 24),
              _buildTextField(_titleController, 'عنوان المقال'),
              _buildTextField(_authorController, 'الكاتب (المصدر)'),
              _buildTextField(_summaryController, 'ملخص قصير', maxLines: 2),
              _buildTextField(_contentController, 'المحتوى الكامل للمقال', maxLines: 12),

              // Content images section
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('صور داخل المقال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                  TextButton.icon(
                    onPressed: _pickContentImage,
                    icon: const Icon(Icons.add_a_photo, size: 18, color: AppTheme.primaryTeal),
                    label: const Text('إضافة صورة', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Existing uploaded images
              if (_contentImageUrls.isNotEmpty || _contentImageBytesNew.isNotEmpty)
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Already uploaded images
                      ..._contentImageUrls.asMap().entries.map((entry) {
                        return _buildImageThumb(
                          child: Image.network(entry.value, fit: BoxFit.cover, width: 130, height: 130),
                          onRemove: () => _removeExistingContentImage(entry.key),
                        );
                      }),
                      // Newly picked images (not yet uploaded)
                      ..._contentImageBytesNew.asMap().entries.map((entry) {
                        return _buildImageThumb(
                          child: Image.memory(entry.value, fit: BoxFit.cover, width: 130, height: 130),
                          onRemove: () => _removeNewContentImage(entry.key),
                          isNew: true,
                        );
                      }),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text('لا توجد صور إضافية، اضغط "إضافة صورة" لإضافة صور داخل المقال', 
                      style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
                  ),
                ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('جاري الرفع...', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      )
                    : Text(isEdit ? 'حفظ التعديلات' : 'نشر المقال', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumb({required Widget child, required VoidCallback onRemove, bool isNew = false}) {
    return Container(
      width: 130,
      height: 130,
      margin: const EdgeInsets.only(left: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 130, height: 130, child: child),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (isNew)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('جديدة', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}
