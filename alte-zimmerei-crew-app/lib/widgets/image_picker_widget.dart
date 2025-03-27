import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ImagePickerWidget extends StatelessWidget {
  final String label;
  final File? image;
  final Function(File) onImagePicked;
  final double height;
  final double width;
  final bool isCircular;
  final String? imageUrl;

  const ImagePickerWidget({
    Key? key,
    required this.label,
    this.image,
    required this.onImagePicked,
    this.height = 150.0,
    this.width = double.infinity,
    this.isCircular = false,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(isCircular ? height / 2 : 8),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isCircular ? height / 2 : 8),
        child: Image.file(
          image!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isCircular ? height / 2 : 8),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_a_photo,
            color: AppColors.inactive,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select image',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inactive,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Gallery', style: AppTextStyles.subtitle2),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (pickedFile != null) {
                    onImagePicked(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Camera', style: AppTextStyles.subtitle2),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (pickedFile != null) {
                    onImagePicked(File(pickedFile.path));
                  }
                },
              ),
              if (image != null || (imageUrl != null && imageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: Text('Remove', style: AppTextStyles.subtitle2.copyWith(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    onImagePicked(File(''));
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

