import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Register',
      ),
      body: SafeArea(
        child: authProvider.isLoading
            ? const LoadingIndicator(message: 'Creating account...')
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: AppTextStyles.headline2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join the ${AppConstants.appName} team',
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.inactive,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (authProvider.error != null)
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
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person, color: AppColors.inactive),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number (Optional)',
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone, color: AppColors.inactive),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: !_isPasswordVisible,
                          prefixIcon: const Icon(Icons.lock, color: AppColors.inactive),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.inactive,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          obscureText: !_isConfirmPasswordVisible,
                          prefixIcon: const Icon(Icons.lock, color: AppColors.inactive),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.inactive,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Register',
                          onPressed: _register,
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

