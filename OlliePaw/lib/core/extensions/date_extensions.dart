/*
  文件：core/extensions/date_extensions.dart
  说明：
  - DateTime 扩展方法
  - 提供统一的日期格式化
  - 消除代码重复（原本在多个文件中重复使用 DateFormat）

  优化（v2.5）：
  - 消除 DateFormat 重复代码
  - 提供语义化的方法名
  - 便于全局修改日期格式

  使用示例：
  ```dart
  // 替代：DateFormat('MMM d').format(date)
  Text(DateTime.now().toShortDate())

  // 替代：DateFormat('MMM d, yyyy').format(date)
  Text(selectedDate.toLongDate())

  // 替代：DateFormat('MMM yyyy').format(date)
  Text(DateTime.now().toMonthYear())
  ```
*/

import 'package:intl/intl.dart';

/// DateTime 扩展方法
///
/// 提供常用的日期格式化方法
extension DateFormatting on DateTime {
  /// 短日期格式：MMM d
  ///
  /// 示例：Jan 15, Mar 8
  ///
  /// 使用场景：图表 X 轴、日历简略显示
  String toShortDate() => DateFormat('MMM d').format(this);

  /// 长日期格式：MMM d, yyyy
  ///
  /// 示例：Jan 15, 2025, Mar 8, 2024
  ///
  /// 使用场景：帖子时间戳、详细日期显示
  String toLongDate() => DateFormat('MMM d, yyyy').format(this);

  /// 月份年份格式：MMM yyyy
  ///
  /// 示例：Jan 2025, Mar 2024
  ///
  /// 使用场景：月份选择器、统计图表标题
  String toMonthYear() => DateFormat('MMM yyyy').format(this);

  /// 时间格式：HH:mm
  ///
  /// 示例：14:30, 09:15
  ///
  /// 使用场景：时间选择器、时间戳
  String toTime() => DateFormat('HH:mm').format(this);

  /// 完整日期时间格式：MMM d, yyyy HH:mm
  ///
  /// 示例：Jan 15, 2025 14:30
  ///
  /// 使用场景：详细时间戳
  String toFullDateTime() => DateFormat('MMM d, yyyy HH:mm').format(this);

  /// 相对时间格式（友好显示）
  ///
  /// 示例：
  /// - 刚刚（1 分钟内）
  /// - 5 分钟前
  /// - 2 小时前
  /// - 昨天
  /// - 3 天前
  /// - Jan 15（超过 7 天）
  ///
  /// 使用场景：社交媒体时间戳、评论时间
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else {
      return toShortDate();
    }
  }

  /// 检查是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 检查是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 检查是否是本周
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(weekStart) && isBefore(now.add(const Duration(days: 1)));
  }

  /// 检查是否是本月
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// 检查是否是本年
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// 获取当天开始时间（00:00:00）
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// 获取当天结束时间（23:59:59）
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// 获取当周开始时间（周一 00:00:00）
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// 获取当月开始时间（1号 00:00:00）
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// 获取当年开始时间（1月1日 00:00:00）
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  // ============================================================================
  // 年龄计算方法
  // ============================================================================

  /// 计算从此日期到现在的年龄
  ///
  /// 返回格式：
  /// - 小于60天："{天数}d" (例如：45d)
  /// - 小于1年："{月数}m" (例如：8m)
  /// - 大于1年："{年数}y {月数}m" (例如：2y 3m)
  ///
  /// 使用场景：宠物年龄显示
  ///
  /// 示例：
  /// ```dart
  /// final birthDate = DateTime(2023, 1, 15);
  /// print(birthDate.calculateAge()); // "1y 11m"
  /// ```
  String calculateAge() {
    final difference = DateTime.now().difference(this);
    if (difference.inDays < 60) {
      return "${difference.inDays}d";
    }
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    return years > 0 ? "${years}y ${months}m" : "${months}m";
  }

  /// 计算从此日期到目标日期的年龄
  ///
  /// 参数：
  /// - [targetDate] 目标日期
  ///
  /// 返回格式：
  /// - 小于60天："Age: {天数}d" (例如：Age: 45d)
  /// - 小于1年："Age: {月数}m" (例如：Age: 8m)
  /// - 大于1年："Age: {年数}y {月数}m" (例如：Age: 2y 3m)
  ///
  /// 使用场景：历史体重记录的年龄标注
  ///
  /// 示例：
  /// ```dart
  /// final birthDate = DateTime(2023, 1, 15);
  /// final recordDate = DateTime(2024, 6, 1);
  /// print(birthDate.calculateAgeAt(recordDate)); // "Age: 1y 4m"
  /// ```
  String calculateAgeAt(DateTime targetDate) {
    final difference = targetDate.difference(this);
    if (difference.inDays < 60) {
      return "Age: ${difference.inDays}d";
    }
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    return years > 0 ? "Age: ${years}y ${months}m" : "Age: ${months}m";
  }
}
