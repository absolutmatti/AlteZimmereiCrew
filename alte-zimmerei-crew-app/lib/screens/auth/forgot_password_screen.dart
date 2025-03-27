import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<AuthProvider>(context, listen: false)
          .resetPassword(_emailController.text.trim());
      setState(() {
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Forgot Password',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Password',
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive a password reset link',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.inactive,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isSuccess)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Password reset link has been sent to your email',
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (authProvider.error != null && !_isSuccess)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email, color: AppColors.inactive),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Reset Password',
                    onPressed: _resetPassword,
                    isLoading: authProvider.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

