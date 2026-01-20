/*
  文件：widgets/common/form_field_label.dart
  说明：
  - 统一的表单字段标签组件
  - 提供一致的标签样式
  - 可选的必填标记

  使用示例：
  ```dart
  FormFieldLabel(
    label: '疫苗名称',
    required: true,
  )
  ```

  v3.0 - 代码整合
*/

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 表单字段标签组件
///
/// 提供统一的标签样式，支持必填标记
class FormFieldLabel extends StatelessWidget {
  /// 标签文本
  final String label;

  /// 是否为必填字段（显示红色星号）
  final bool required;

  /// 标签颜色（默认灰色）
  final Color? color;

  /// 字体大小（默认 12）
  final double fontSize;

  const FormFieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.color,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.grey500,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
