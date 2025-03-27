import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/shift_model.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';

class RequestShiftChangeScreen extends StatefulWidget {
  final ShiftModel shift;
  
  const RequestShiftChangeScreen({
    Key? key,
    required this.shift,
  }) : super(key: key);

  @override
  State<RequestShiftChangeScreen> createState() => _RequestShiftChangeScreenState();
}

class _RequestShiftChangeScreenState extends State<RequestShiftChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  Future<void> _requestShiftChange() async {
    if (!_formKey.currentState!.validate()) return;
    
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    
    try {
      await shiftProvider.requestShiftChange(widget.shift.id, _reasonController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shift change requested successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request shift change: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Request Shift Change',
      ),
      body: shiftProvider.isLoading
          ? const LoadingIndicator(message: 'Submitting request...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Shift Change',
                      style: AppTextStyles.headline2,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Please provide a reason for requesting a change for your shift on ${widget.shift.eventName}.',
                      style: AppTextStyles.bodyText1,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reason
                    CustomTextField(
                      controller: _reasonController,
                      label: 'Reason',
                      hint: 'Enter reason for shift change',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    CustomButton(
                      text: 'Submit Request',
                      onPressed: _requestShiftChange,
                      isLoading: shiftProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

