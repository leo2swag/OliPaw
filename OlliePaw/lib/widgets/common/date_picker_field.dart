/*
  文件：widgets/common/date_picker_field.dart
  说明：
  - 统一的日期选择器字段组件
  - 可点击打开日期选择器
  - 支持自定义图标和颜色

  使用示例：
  ```dart
  DatePickerField(
    label: '接种日期',
    date: _selectedDate,
    icon: LucideIcons.calendar,
    iconColor: AppColors.primaryOrange,
    onTap: () => _selectDate(),
  )
  ```

  v3.0 - 代码整合
*/

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'form_field_label.dart';

/// 日期选择器字段组件
///
/// 提供统一的日期选择器样式和交互
class DatePickerField extends StatelessWidget {
  /// 字段标签
  final String label;

  /// 当前选中的日期
  final DateTime date;

  /// 左侧图标
  final IconData icon;

  /// 图标颜色
  final Color iconColor;

  /// 点击回调
  final VoidCallback onTap;

  /// 日期格式（默认 yyyy-MM-dd）
  final String dateFormat;

  /// 是否为必填字段
  final bool required;

  const DatePickerField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.icon = LucideIcons.calendar,
    this.iconColor = AppColors.primaryOrange,
    this.dateFormat = 'yyyy-MM-dd',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat(dateFormat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        FormFieldLabel(label: label, required: required),

        // 日期显示容器（可点击）
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.allMD,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              border: Border.all(color: AppColors.grey200),
              borderRadius: AppRadius.allMD,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  formatter.format(date),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
