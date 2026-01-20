/*
  文件：utils/date_picker_helper.dart
  说明：
  - 统一的日期选择器工具类
  - 提供一致的样式和行为
  - 消除日期选择器重复代码

  用途：
  - 简化 showDatePicker 调用
  - 统一主题样式
  - 便于全局修改日期选择器外观

  更新于：v2.8 - 代码整合优化
  - 消除 add_vaccine_dialog 和 add_weight_dialog 中的重复代码
  - 使用 AppColors 确保一致性
*/

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// 日期选择器辅助工具类
///
/// 提供统一的日期选择器样式和行为
class DatePickerHelper {
  // 防止实例化
  DatePickerHelper._();

  /// 显示日期选择器
  ///
  /// [context] 上下文
  /// [initialDate] 初始日期
  /// [firstDate] 可选择的最早日期
  /// [lastDate] 可选择的最晚日期
  /// [primaryColor] 主题色（可选，默认使用 primaryOrange）
  ///
  /// 返回：用户选择的日期，如果取消则返回 null
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    Color? primaryColor,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor ?? AppColors.primaryOrange,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// 显示日期选择器（橙色主题）
  ///
  /// 便捷方法，使用 primaryOrange 作为主题色
  /// 常用于：疫苗接种日期、通用日期选择
  static Future<DateTime?> showOrange(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return show(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      primaryColor: AppColors.primaryOrange,
    );
  }

  /// 显示日期选择器（蓝色主题）
  ///
  /// 便捷方法，使用蓝色作为主题色
  /// 常用于：体重记录日期
  static Future<DateTime?> showBlue(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return show(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      primaryColor: AppColors.info,
    );
  }

  /// 显示日期选择器（青色主题）
  ///
  /// 便捷方法，使用青色作为主题色
  /// 常用于：到期提醒日期、未来日期选择
  static Future<DateTime?> showTeal(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return show(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      primaryColor: AppColors.success,
    );
  }

  /// 显示日期选择器（绿色主题）
  ///
  /// 便捷方法，使用绿色作为主题色
  /// 常用于：健康记录、成功相关日期
  static Future<DateTime?> showGreen(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return show(
      context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      primaryColor: AppColors.success,
    );
  }
}
