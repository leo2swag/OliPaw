/*
  文件：utils/date_utils.dart
  说明：
  - 日期相关工具函数
  - 提取自 profile_screen.dart 的重复逻辑
  - 统一的年龄计算和日期格式化

  使用示例：
  ```dart
  // 计算年龄
  String age = AppDateUtils.calculateAge('2021-05-10');
  // 返回: "3y 7m" 或 "8m" 或 "45d"

  // 计算特定日期时的年龄
  String ageAtPost = AppDateUtils.calculateAgeAtDate('2021-05-10', '2023-10-25');
  // 返回: "Age: 2y 5m"

  // 获取今天的日期字符串
  String today = AppDateUtils.getTodayString();
  // 返回: "2024-12-28"

  // 格式化日期
  String formatted = AppDateUtils.formatDate(DateTime.now());
  // 返回: "2024-12-28"
  ```

  替换位置：
  - profile_screen.dart - _calculateAge (lines 43-53)
  - profile_screen.dart - _calculateAgeAtDate (lines 55-65)
*/

/// 日期相关工具类
///
/// 提供日期计算和格式化的通用方法
/// 所有日期字符串统一使用 ISO 8601 格式（YYYY-MM-DD）
class AppDateUtils {
  /// 计算年龄
  ///
  /// 根据出生日期计算当前年龄或到指定日期的年龄
  ///
  /// 参数：
  /// - birthDate: 出生日期字符串（格式：YYYY-MM-DD）
  /// - referenceDate: 参考日期（默认为当前时间）
  ///
  /// 返回格式：
  /// - "Xd" (X 天) - 小于 60 天
  /// - "Xm" (X 月) - 小于 1 年
  /// - "Xy Xm" (X 年 X 月) - 1 年以上
  /// - "N/A" - 日期解析失败
  ///
  /// 示例：
  /// ```dart
  /// calculateAge('2024-01-15') // 返回 "11m"（假设现在是 12 月）
  /// calculateAge('2021-05-10') // 返回 "3y 7m"
  /// calculateAge('2024-12-01') // 返回 "27d"
  /// ```
  static String calculateAge(String birthDate, {DateTime? referenceDate}) {
    try {
      final birth = DateTime.parse(birthDate);
      final reference = referenceDate ?? DateTime.now();
      final difference = reference.difference(birth);

      // 小于 60 天：显示天数
      if (difference.inDays < 60) {
        return "${difference.inDays}d";
      }

      // 计算年和月
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();

      // 1 年以上：显示年和月
      if (years > 0) {
        return "${years}y ${months}m";
      } else {
        // 小于 1 年：只显示月
        return "${months}m";
      }
    } catch (e) {
      return "N/A";
    }
  }

  /// 计算特定日期时的年龄
  ///
  /// 用于时间轴等场景，显示"在某个日期时的年龄"
  /// 返回值带 "Age: " 前缀
  ///
  /// 参数：
  /// - birthDate: 出生日期字符串（格式：YYYY-MM-DD）
  /// - targetDate: 目标日期字符串（格式：YYYY-MM-DD）
  ///
  /// 返回格式：
  /// - "Age: Xd" (X 天) - 小于 60 天
  /// - "Age: Xm" (X 月) - 小于 1 年
  /// - "Age: Xy Xm" (X 年 X 月) - 1 年以上
  /// - "" (空字符串) - 日期解析失败
  ///
  /// 示例：
  /// ```dart
  /// calculateAgeAtDate('2021-05-10', '2023-10-25') // 返回 "Age: 2y 5m"
  /// calculateAgeAtDate('2024-11-01', '2024-12-15') // 返回 "Age: 44d"
  /// ```
  static String calculateAgeAtDate(String birthDate, String targetDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final target = DateTime.parse(targetDate);
      final difference = target.difference(birth);

      // 小于 60 天：显示天数
      if (difference.inDays < 60) {
        return "Age: ${difference.inDays}d";
      }

      // 计算年和月
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();

      // 1 年以上：显示年和月
      if (years > 0) {
        return "Age: ${years}y ${months}m";
      } else {
        // 小于 1 年：只显示月
        return "Age: ${months}m";
      }
    } catch (e) {
      return "";
    }
  }

  /// 获取今天的日期字符串
  ///
  /// 返回格式：YYYY-MM-DD
  ///
  /// 用途：
  /// - 签到日期判断
  /// - 创建帖子时的日期标记
  /// - 日期比较
  ///
  /// 示例：
  /// ```dart
  /// getTodayString() // 返回 "2024-12-28"
  /// ```
  static String getTodayString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// 格式化日期为字符串
  ///
  /// 将 DateTime 对象格式化为 YYYY-MM-DD 字符串
  ///
  /// 参数：
  /// - date: DateTime 对象
  ///
  /// 返回：YYYY-MM-DD 格式的字符串
  ///
  /// 示例：
  /// ```dart
  /// formatDate(DateTime(2024, 12, 28)) // 返回 "2024-12-28"
  /// formatDate(DateTime(2024, 1, 5))   // 返回 "2024-01-05"
  /// ```
  static String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// 检查两个日期是否是同一天
  ///
  /// 参数：
  /// - date1: 第一个日期
  /// - date2: 第二个日期
  ///
  /// 返回：true 表示同一天，false 表示不同天
  ///
  /// 用途：
  /// - 签到日期判断
  /// - 日程冲突检查
  ///
  /// 示例：
  /// ```dart
  /// isSameDay(DateTime(2024, 12, 28), DateTime(2024, 12, 28, 15, 30)) // true
  /// isSameDay(DateTime(2024, 12, 28), DateTime(2024, 12, 29)) // false
  /// ```
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 解析日期字符串
  ///
  /// 安全地解析日期字符串，失败时返回 null
  ///
  /// 参数：
  /// - dateString: 日期字符串（格式：YYYY-MM-DD）
  ///
  /// 返回：DateTime 对象或 null（解析失败时）
  ///
  /// 示例：
  /// ```dart
  /// parseDate('2024-12-28') // 返回 DateTime 对象
  /// parseDate('invalid')    // 返回 null
  /// ```
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
