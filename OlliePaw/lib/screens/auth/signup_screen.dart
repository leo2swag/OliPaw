/*
  文件：screens/auth/signup_screen.dart
  说明：
  - 用户注册页面
  - 支持邮箱/密码注册
  - 包含表单验证
  - 自动登录新用户

  UI 设计：
  - 简洁的表单设计
  - 密码强度提示
  - 实时错误提示
  - 加载状态显示
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/types.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/theme/app_input_decoration.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/password_form_field.dart';
import '../../widgets/common/app_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // User type selection - default to PET_OWNER
  String _selectedUserType = 'OWNER';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      userType: _selectedUserType,
    );

    if (!mounted) return;

    if (success) {
      // Create UserProfile based on user type
      final authUser = authProvider.authUser;

      // Null check for safety
      if (authUser == null) {
        SnackBarHelper.showError(context, 'Sign up failed: user data not available');
        return;
      }

      final userProfile = UserProfile(
        id: authUser.uid,
        type: _selectedUserType == 'guest' ? UserType.guest : UserType.owner,
        name: authUser.displayName ?? authUser.email.split('@')[0],
        avatarUrl: authUser.photoUrl,
      );

      // Save to AuthProvider
      authProvider.login(userProfile);

      // 注册成功，导航到主页
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 显示错误消息
      SnackBarHelper.showError(
        context,
        authProvider.errorMessage ?? 'Sign up failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/品牌区域
                  const Icon(
                    Icons.pets,
                    size: 64,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: UIDimensions.spacingM),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the OlliePaw community',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 用户类型选择
                  const Text(
                    'I am a...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedUserType = 'OWNER'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedUserType == 'OWNER'
                                  ? AppColors.lightOrangeBg
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: _selectedUserType == 'OWNER'
                                    ? AppColors.primaryOrange
                                    : AppColors.border,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(UIDimensions.radiusS),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 32,
                                  color: _selectedUserType == 'OWNER'
                                      ? AppColors.primaryOrange
                                      : AppColors.textMedium,
                                ),
                                const SizedBox(height: UIDimensions.spacingS),
                                Text(
                                  'Pet Owner',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedUserType == 'OWNER'
                                        ? AppColors.primaryOrange
                                        : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: UIDimensions.spacingXS),
                                const Text(
                                  'Share your pet\'s life',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedUserType = 'GUEST'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedUserType == 'GUEST'
                                  ? AppColors.lightOrangeBg
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: _selectedUserType == 'GUEST'
                                    ? AppColors.primaryOrange
                                    : AppColors.border,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(UIDimensions.radiusS),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '👻',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: _selectedUserType == 'GUEST'
                                        ? AppColors.primaryOrange
                                        : AppColors.textMedium,
                                  ),
                                ),
                                const SizedBox(height: UIDimensions.spacingS),
                                Text(
                                  'Guest',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedUserType == 'GUEST'
                                        ? AppColors.primaryOrange
                                        : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: UIDimensions.spacingXS),
                                const Text(
                                  'Explore and browse',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIDimensions.spacingL),

                  // 名字输入
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: AppInputDecoration.standard(
                      labelText: 'Display Name',
                      hintText: 'What should we call you?',
                      prefixIcon: Icons.person_outline,
                    ),
                    validator: AppConstants.validateName,
                  ),
                  const SizedBox(height: UIDimensions.spacingM),

                  // 邮箱输入
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: AppInputDecoration.standard(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    validator: AppConstants.validateEmail,
                  ),
                  const SizedBox(height: UIDimensions.spacingM),

                  // 密码输入
                  PasswordFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'At least 6 characters',
                    validator: AppConstants.validatePassword,
                  ),
                  const SizedBox(height: UIDimensions.spacingM),

                  // 确认密码输入
                  PasswordFormField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    validator: (value) => AppConstants.validateConfirmPassword(value, _passwordController.text),
                  ),
                  const SizedBox(height: UIDimensions.spacingL),

                  // 注册按钮
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return AppButton.primary(
                        label: 'Create Account',
                        onPressed: authProvider.isLoading ? null : _handleSignUp,
                        isLoading: authProvider.isLoading,
                        fullWidth: true,
                      );
                    },
                  ),
                  const SizedBox(height: UIDimensions.spacingM),

                  // 服务条款提示
                  const Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
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
