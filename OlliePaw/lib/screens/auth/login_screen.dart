/*
  文件：screens/auth/login_screen.dart
  说明：
  - 用户登录页面
  - 支持邮箱/密码登录
  - 包含表单验证
  - 导航到注册页面

  UI 设计：
  - 简洁的表单设计
  - 实时错误提示
  - 加载状态显示
  - 品牌配色（橙色主题）
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/types.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/theme/app_input_decoration.dart';
import '../../core/theme/app_dimensions.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/password_form_field.dart';
import '../../widgets/common/app_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Create UserProfile based on logged in user
      final authUser = authProvider.authUser;

      // Null check for safety
      if (authUser == null) {
        SnackBarHelper.showError(context, 'Login failed: user data not available');
        return;
      }

      final userProfile = UserProfile(
        id: authUser.uid,
        type: authUser.userType == 'guest' ? UserType.guest : UserType.owner,
        name: authUser.displayName ?? authUser.email.split('@')[0],
        avatarUrl: authUser.photoUrl,
      );

      // Save to AuthProvider
      authProvider.login(userProfile);

      // 登录成功，导航到主页
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // 显示错误消息
      SnackBarHelper.showError(
        context,
        authProvider.errorMessage ?? 'Login failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    size: 80,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: UIDimensions.spacingM),
                  const Text(
                    'OlliePaw',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: UIDimensions.spacingS),
                  const Text(
                    'Welcome back! Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: UIDimensions.spacingXL),

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
                    hintText: 'Enter your password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: UIDimensions.spacingL),

                  // 登录按钮
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return AppButton.primary(
                        label: 'Sign In',
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        isLoading: authProvider.isLoading,
                        fullWidth: true,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 忘记密码（占位，未来实现）
                  TextButton(
                    onPressed: () {
                      SnackBarHelper.showInfo(
                        context,
                        'Password reset coming soon!',
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 分隔线
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 注册按钮
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.allMD, // v3.0: 更柔和的圆角
                      ),
                      side: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFB923C),
                      ),
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
