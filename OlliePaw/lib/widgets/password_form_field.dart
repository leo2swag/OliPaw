/*
  文件：widgets/password_form_field.dart
  说明：
  - 可复用的密码输入组件
  - 内置密码可见性切换
  - 统一的样式和行为
  - 消除重复的密码输入逻辑

  使用场景：
  - 登录页面密码输入
  - 注册页面密码输入
  - 修改密码页面

  用途：
  - 减少代码重复
  - 统一密码输入体验
  - 简化密码字段实现

  使用示例：
  ```dart
  PasswordFormField(
    controller: _passwordController,
    labelText: 'Password',
    hintText: 'Enter your password',
    validator: AppConstants.validatePassword,
  )
  ```
*/

import 'package:flutter/material.dart';
import '../core/theme/app_input_decoration.dart';

/// 密码输入组件
///
/// 提供标准的密码输入字段，带有可见性切换功能
class PasswordFormField extends StatefulWidget {
  /// 文本控制器
  final TextEditingController controller;

  /// 标签文字
  final String labelText;

  /// 提示文字
  final String? hintText;

  /// 验证器
  final String? Function(String?)? validator;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: AppInputDecoration.standard(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
}
