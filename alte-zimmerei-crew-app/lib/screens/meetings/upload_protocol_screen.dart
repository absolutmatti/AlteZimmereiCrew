import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/meeting_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class UploadProtocolScreen extends StatefulWidget {
  final String meetingId;
  
  const UploadProtocolScreen({
    Key? key,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<UploadProtocolScreen> createState() => _UploadProtocolScreenState();
}

class _UploadProtocolScreenState extends State<UploadProtocolScreen> {
  File? _protocolFile;
  String _fileName = '';
  bool _isUploading = false;
  
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      
      if (result != null) {
        setState(() {
          _protocolFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _uploadProtocol() async {
    if (_protocolFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
      await meetingProvider.uploadProtocol(widget.meetingId, _protocolFile!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Protocol uploaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload protocol: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Upload Protocol',
      ),
      body: _isUploading
          ? const LoadingIndicator(message: 'Uploading protocol...')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Meeting Protocol',
                    style: AppTextStyles.headline2,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Select a PDF, DOC, DOCX, or TXT file to upload as the meeting protocol.',
                    style: AppTextStyles.bodyText1,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // File Selection
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _protocolFile != null ? AppColors.primary : AppColors.divider,
                          width: 2,
                          style: BorderStyle.dashed,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _protocolFile != null ? Icons.description : Icons.upload_file,
                            size: 48,
                            color: _protocolFile != null ? AppColors.primary : AppColors.inactive,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _protocolFile != null ? _fileName : 'Tap to select file',
                            style: AppTextStyles.subtitle1.copyWith(
                              color: _protocolFile != null ? AppColors.primary : AppColors.inactive,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_protocolFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change file',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Upload Button
                  CustomButton(
                    text: 'Upload Protocol',
                    onPressed: _uploadProtocol,
                    isLoading: _isUploading,
                    icon: Icons.upload,
                  ),
                ],
              ),
            ),
    );
  }
}

