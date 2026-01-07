/*
  文件：core/models/post_options.dart
  说明：
  - 帖子选项类型定义
  - 心情（Mood）和分类（Category）的类型安全封装
  - 替代 Map<String, String> 提供编译时类型检查

  优化（v2.5）：
  - 类型安全，避免拼写错误
  - 编译时检查，减少运行时错误
  - 便于扩展和维护

  使用示例：
  ```dart
  // 替代：String? selectedMood; selectedMood = 'Happy';
  MoodOption? selectedMood;
  selectedMood = MoodOption.happy;

  // 获取所有选项
  final moods = MoodOption.values;
  ```
*/

/// 心情选项
///
/// 用于创建帖子时选择宠物的心情
class MoodOption {
  /// 心情名称
  final String name;

  /// 心情 emoji
  final String emoji;

  /// 心情值（用于数据存储）
  final String value;

  const MoodOption({
    required this.name,
    required this.emoji,
    required this.value,
  });

  // ==========================================================================
  // 预定义心情选项
  // ==========================================================================

  /// 开心
  static const MoodOption happy = MoodOption(
    name: 'Happy',
    emoji: '😊',
    value: 'happy',
  );

  /// 酷炫
  static const MoodOption sassy = MoodOption(
    name: 'Sassy',
    emoji: '😎',
    value: 'sassy',
  );

  /// 疯狂
  static const MoodOption chaos = MoodOption(
    name: 'Chaos',
    emoji: '🤪',
    value: 'chaos',
  );

  /// 困倦
  static const MoodOption sleepy = MoodOption(
    name: 'Sleepy',
    emoji: '😴',
    value: 'sleepy',
  );

  /// 玩耍
  static const MoodOption playful = MoodOption(
    name: 'Playful',
    emoji: '🎾',
    value: 'playful',
  );

  /// 饥饿
  static const MoodOption hungry = MoodOption(
    name: 'Hungry',
    emoji: '🍖',
    value: 'hungry',
  );

  // ==========================================================================
  // 所有选项列表
  // ==========================================================================

  /// 所有心情选项
  static const List<MoodOption> values = [
    happy,
    sassy,
    chaos,
    sleepy,
    playful,
    hungry,
  ];

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 根据 value 查找心情选项
  ///
  /// 参数：
  /// - value: 心情值
  ///
  /// 返回值：对应的 MoodOption，未找到返回 null
  static MoodOption? fromValue(String value) {
    try {
      return values.firstWhere((mood) => mood.value == value);
    } catch (e) {
      return null;
    }
  }

  /// 根据 name 查找心情选项
  ///
  /// 参数：
  /// - name: 心情名称
  ///
  /// 返回值：对应的 MoodOption，未找到返回 null
  static MoodOption? fromName(String name) {
    try {
      return values.firstWhere((mood) => mood.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 获取显示文本（emoji + name）
  ///
  /// 示例：😊 Happy
  String get displayText => '$emoji $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MoodOption($value)';
}

/// 分类选项
///
/// 用于创建帖子时选择帖子分类
class CategoryOption {
  /// 分类名称
  final String name;

  /// 分类 emoji
  final String emoji;

  /// 分类值（用于数据存储）
  final String value;

  const CategoryOption({
    required this.name,
    required this.emoji,
    required this.value,
  });

  // ==========================================================================
  // 预定义分类选项
  // ==========================================================================

  /// 图片
  static const CategoryOption pics = CategoryOption(
    name: 'Pics',
    emoji: '📸',
    value: 'pics',
  );

  /// 睡觉
  static const CategoryOption sleep = CategoryOption(
    name: 'Sleep',
    emoji: '💤',
    value: 'sleep',
  );

  /// 散步
  static const CategoryOption walk = CategoryOption(
    name: 'Walk',
    emoji: '🌳',
    value: 'walk',
  );

  /// 玩耍
  static const CategoryOption play = CategoryOption(
    name: 'Play',
    emoji: '🎾',
    value: 'play',
  );

  // ==========================================================================
  // 所有选项列表
  // ==========================================================================

  /// 所有分类选项
  static const List<CategoryOption> values = [
    pics,
    sleep,
    walk,
    play,
  ];

  // ==========================================================================
  // 辅助方法
  // ==========================================================================

  /// 根据 value 查找分类选项
  ///
  /// 参数：
  /// - value: 分类值
  ///
  /// 返回值：对应的 CategoryOption，未找到返回 null
  static CategoryOption? fromValue(String value) {
    try {
      return values.firstWhere((category) => category.value == value);
    } catch (e) {
      return null;
    }
  }

  /// 根据 name 查找分类选项
  ///
  /// 参数：
  /// - name: 分类名称
  ///
  /// 返回值：对应的 CategoryOption，未找到返回 null
  static CategoryOption? fromName(String name) {
    try {
      return values.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 获取显示文本（emoji + name）
  ///
  /// 示例：📸 Pics
  String get displayText => '$emoji $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CategoryOption($value)';
}
