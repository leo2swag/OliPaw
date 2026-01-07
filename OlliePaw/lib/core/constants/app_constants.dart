/*
  文件：core/constants/app_constants.dart
  说明：
  - 应用全局常量
  - 消除硬编码值，便于统一管理

  优化（v2.5 - Firebase 准备）：
  - 提取所有硬编码值
  - 添加 Firestore 集合名常量
  - 统一默认值管理
*/

import '../../models/types.dart';

/// 应用常量
///
/// 所有硬编码值的统一管理
class AppConstants {
  AppConstants._(); // 防止实例化

  // ==================== 默认值 ====================

  /// 默认宠物类型
  static const PetType defaultPetType = PetType.DOG;

  /// 默认品种
  static const String defaultBreed = 'Mixed Breed';

  /// 默认头像 URL
  static const String defaultAvatarUrl = 'https://picsum.photos/200';

  /// 默认宠物年龄（天）
  static const int defaultPetAgeDays = 365;

  /// 默认宠物简介
  static const String defaultPetBio = 'Just living my best life! 🐾';

  /// 默认出生日期（相对于现在）
  static String get defaultBirthDate {
    final date = DateTime.now().subtract(const Duration(days: defaultPetAgeDays));
    return date.toIso8601String().split('T')[0];
  }

  // ==================== Treats 货币系统 ====================

  /// 初始 Treats 余额
  /// 推荐: 使用 GameBalance.initialTreats
  static const int initialTreats = 50;

  /// AI 助手费用
  static const int aiAssistCost = 5;

  /// Treats 交易历史最大保留数
  static const int maxTransactionHistory = 100;

  /// Treats 最小值
  static const int minTreats = 0;

  /// Treats 最大值（防止溢出）
  static const int maxTreats = 999999;

  // ==================== 签到系统 ====================

  /// 签到历史最大保留天数
  static const int maxCheckInHistoryDays = 30;

  /// 连续签到重置时间（小时）
  static const int checkInResetHours = 24;

  /// 最大连续签到天数（用于奖励上限）
  static const int maxConsecutiveDays = 365;

  // ==================== 数据验证限制 ====================

  /// 名字最小长度
  static const int minNameLength = 1;

  /// 名字最大长度
  static const int maxNameLength = 50;

  /// 简介最大长度
  static const int maxBioLength = 200;

  /// 帖子内容最大长度
  static const int maxPostContentLength = 500;

  /// 评论最大长度
  static const int maxCommentLength = 200;

  /// 疫苗名称最大长度
  static const int maxVaccineNameLength = 100;

  /// 兽医名称最大长度
  static const int maxVeterinarianLength = 100;

  // ==================== 媒体限制 ====================

  /// 图片最大宽度（像素）
  static const int maxImageWidth = 1920;

  /// 图片最大高度（像素）
  static const int maxImageHeight = 1920;

  /// 图片质量（0-100）
  static const int imageQuality = 85;

  /// 视频最大时长（秒）
  static const int maxVideoDurationSeconds = 60;

  /// 相册最大图片数
  static const int maxGalleryPhotos = 100;

  /// 支持的图片格式
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
  ];

  /// 支持的视频格式
  static const List<String> supportedVideoFormats = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.wmv',
    '.flv',
    '.webm',
  ];

  // ==================== 日期格式 ====================

  /// 日期格式：2024-01-01
  static const String dateFormat = 'yyyy-MM-dd';

  /// 时间戳格式：2024-01-01 12:00:00
  static const String timestampFormat = 'yyyy-MM-dd HH:mm:ss';

  /// 显示日期格式：Jan 1, 2024
  static const String displayDateFormat = 'MMM d, yyyy';

  /// 短日期格式：Jan 1
  static const String shortDateFormat = 'MMM d';

  // ==================== UI 常量 ====================

  /// Splash 最小显示时间（毫秒）
  static const int minSplashDuration = 2000;

  /// 加载超时时间（毫秒）
  static const int loadingTimeout = 30000;

  /// 防抖延迟（毫秒）
  static const int debounceDelay = 300;

  /// 动画持续时间（毫秒）
  static const int animationDuration = 300;

  /// 长按持续时间（毫秒）
  static const int longPressDuration = 500;

  // ==================== 分页和列表 ====================

  /// 每页帖子数量
  static const int postsPerPage = 20;

  /// 每页评论数量
  static const int commentsPerPage = 50;

  /// 时间线最大帖子数
  static const int maxTimelinePosts = 100;

  /// 搜索结果最大数量
  static const int maxSearchResults = 50;

  // ==================== Firestore 集合名 ====================

  /// 用户集合
  static const String usersCollection = 'users';

  /// 宠物集合
  static const String petsCollection = 'pets';

  /// 帖子集合
  static const String postsCollection = 'posts';

  /// 挑战集合
  static const String challengesCollection = 'challenges';

  /// 聊天集合
  static const String chatsCollection = 'chats';

  // Subcollections

  /// 疫苗记录子集合
  static const String vaccinesSubcollection = 'vaccines';

  /// 体重历史子集合
  static const String weightHistorySubcollection = 'weightHistory';

  /// 相册子集合
  static const String gallerySubcollection = 'gallery';

  /// 货币子集合
  static const String currencySubcollection = 'currency';

  /// 交易历史子集合
  static const String transactionsSubcollection = 'transactions';

  /// 签到子集合
  static const String checkInSubcollection = 'checkin';

  /// 消息子集合
  static const String messagesSubcollection = 'messages';

  /// 设置子集合
  static const String settingsSubcollection = 'settings';

  // ==================== Firebase Storage 路径 ====================

  /// 用户头像存储路径
  static String userAvatarPath(String userId) => 'avatars/users/$userId';

  /// 宠物头像存储路径
  static String petAvatarPath(String petId) => 'avatars/pets/$petId';

  /// 帖子图片存储路径
  static String postImagePath(String postId) => 'posts/$postId';

  /// 相册图片存储路径
  static String galleryImagePath(String petId, String photoId) =>
      'gallery/$petId/$photoId';

  // ==================== 环境变量 Keys ====================

  /// Gemini API Key 环境变量名
  static const String geminiApiKeyEnv = 'GEMINI_API_KEY';

  /// Firebase 配置环境变量前缀
  static const String firebaseConfigPrefix = 'FIREBASE_';

  // ==================== 本地存储 Keys ====================

  /// 当前用户 ID
  static const String currentUserIdKey = 'current_user_id';

  /// 当前宠物 ID
  static const String currentPetIdKey = 'current_pet_id';

  /// Treats 余额
  static const String treatsKey = 'treats';

  /// 最后签到日期
  static const String lastCheckInKey = 'last_checkin';

  /// 连续签到天数
  static const String consecutiveDaysKey = 'consecutive_days';

  /// 首次启动标记
  static const String firstLaunchKey = 'first_launch';

  /// 主题模式
  static const String themeModeKey = 'theme_mode';

  /// 语言设置
  static const String languageKey = 'language';

  // ==================== 错误消息 ====================

  /// 网络错误
  static const String networkError = 'Network error. Please check your connection.';

  /// 服务器错误
  static const String serverError = 'Server error. Please try again later.';

  /// 未找到用户
  static const String userNotFound = 'User not found.';

  /// 未找到宠物
  static const String petNotFound = 'Pet not found.';

  /// 余额不足
  static const String insufficientBalance = 'Insufficient Treats balance.';

  /// 已签到
  static const String alreadyCheckedIn = 'You have already checked in today.';

  /// 无效输入
  static const String invalidInput = 'Invalid input. Please check and try again.';

  /// 权限不足
  static const String permissionDenied = 'Permission denied.';

  // ==================== 成功消息 ====================

  /// 签到成功
  static String checkInSuccess(int reward) =>
      'Check-in successful! You earned $reward Treats 🎉';

  /// 保存成功
  static const String saveSuccess = 'Changes saved successfully.';

  /// 发布成功
  static const String postSuccess = 'Post published successfully!';

  /// 评论成功
  static const String commentSuccess = 'Comment added successfully!';

  // ==================== 验证规则 ====================

  /// 验证名字
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < minNameLength) {
      return 'Name is too short (min $minNameLength character)';
    }
    if (value.length > maxNameLength) {
      return 'Name is too long (max $maxNameLength characters)';
    }
    return null;
  }

  /// 验证简介
  static String? validateBio(String? value) {
    if (value != null && value.length > maxBioLength) {
      return 'Bio is too long (max $maxBioLength characters)';
    }
    return null;
  }

  /// 验证帖子内容
  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Post content cannot be empty';
    }
    if (value.length > maxPostContentLength) {
      return 'Post is too long (max $maxPostContentLength characters)';
    }
    return null;
  }

  /// 验证 Treats 数量
  static bool validateTreatsAmount(int amount) {
    return amount >= minTreats && amount <= maxTreats;
  }

  /// 验证出生日期
  static bool validateBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      final now = DateTime.now();
      // 宠物不能在未来出生，也不能在1900年之前出生
      return date.isBefore(now) && date.isAfter(DateTime(1900));
    } catch (e) {
      return false;
    }
  }

  // ==================== 辅助方法 ====================

  /// 获取今天日期字符串
  static String getTodayString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// 解析日期
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 检查是否是今天
  static bool isToday(String dateString) {
    return dateString == getTodayString();
  }

  /// 验证邮箱格式
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // 简单的邮箱格式验证
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// 验证密码格式
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// 验证确认密码
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// 计算年龄
  static String calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final difference = now.difference(birth);

      if (difference.inDays < 60) {
        return "${difference.inDays}d";
      }

      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();

      return years > 0 ? "${years}y ${months}m" : "${months}m";
    } catch (e) {
      return "N/A";
    }
  }
}
