/*
  文件：core/constants/app_emojis.dart
  说明：
  - 应用表情符号常量
  - 统一管理所有表情符号
  - 增强应用的温暖和友好感

  v3.0 新增 - 温暖UI设计：
  - 为不同功能和情绪提供表情符号
  - 使UI更加生动、有趣、亲切
  - 方便在整个应用中保持一致的表情符号使用

  使用示例：
  ```dart
  // 在空状态中使用
  Text(
    '${AppEmojis.emptyBox} No posts yet',
    style: TextStyle(fontSize: 16),
  )

  // 在按钮中使用
  AppButton.primary(
    label: '${AppEmojis.paw} Add Pet',
    onPressed: _handleAddPet,
  )

  // 在心情选择器中使用
  final moods = [
    {'emoji': AppEmojis.happy, 'name': 'Happy'},
    {'emoji': AppEmojis.excited, 'name': 'Excited'},
  ]
  ```
*/

/// 应用表情符号常量
///
/// 统一管理所有表情符号，便于复用和维护
class AppEmojis {
  // 防止实例化
  AppEmojis._();

  // ==========================================================================
  // 宠物相关
  // ==========================================================================

  /// 爪印 - 通用宠物图标
  static const String paw = '🐾';

  /// 狗
  static const String dog = '🐕';

  /// 猫
  static const String cat = '🐱';

  /// 兔子
  static const String rabbit = '🐰';

  /// 仓鼠
  static const String hamster = '🐹';

  /// 鸟
  static const String bird = '🐦';

  /// 鱼
  static const String fish = '🐠';

  // ==========================================================================
  // 心情表情（用于心情选择器）
  // ==========================================================================

  /// 开心
  static const String happy = '😊';

  /// 兴奋
  static const String excited = '🤩';

  /// 平静
  static const String calm = '😌';

  /// 玩耍
  static const String playful = '😄';

  /// 困倦
  static const String sleepy = '😴';

  /// 精力充沛
  static const String energetic = '🤗';

  /// 爱心
  static const String love = '🥰';

  /// 自然/户外
  static const String nature = '🌿';

  /// 焦虑
  static const String anxious = '😰';

  /// 生病
  static const String sick = '🤒';

  // ==========================================================================
  // 活动相关
  // ==========================================================================

  /// 快照/拍照
  static const String camera = '📸';

  /// 散步
  static const String walk = '🚶';

  /// 玩耍/玩具
  static const String play = '🎾';

  /// 睡觉
  static const String sleep = '💤';

  /// 吃饭
  static const String meal = '🍖';

  /// 洗澡
  static const String bath = '🛁';

  /// 训练
  static const String training = '🎓';

  // ==========================================================================
  // 健康相关
  // ==========================================================================

  /// 健康/心跳
  static const String health = '❤️';

  /// 体重
  static const String weight = '⚖️';

  /// 疫苗/注射器
  static const String vaccine = '💉';

  /// 药物
  static const String medicine = '💊';

  /// 医生/医院
  static const String doctor = '👨‍⚕️';

  /// 体温计
  static const String thermometer = '🌡️';

  // ==========================================================================
  // 里程碑/庆祝
  // ==========================================================================

  /// 生日/庆祝
  static const String birthday = '🎂';

  /// 礼物
  static const String gift = '🎁';

  /// 奖杯/成就
  static const String trophy = '🏆';

  /// 星星/特殊
  static const String star = '⭐';

  /// 彩虹/美好
  static const String rainbow = '🌈';

  /// 派对/庆祝
  static const String party = '🎉';

  /// 火花/兴奋
  static const String sparkles = '✨';

  // ==========================================================================
  // 空状态/状态指示
  // ==========================================================================

  /// 空盒子
  static const String emptyBox = '📭';

  /// 搜索/放大镜
  static const String search = '🔍';

  /// 加号/添加
  static const String add = '➕';

  /// 警告
  static const String warning = '⚠️';

  /// 信息
  static const String info = 'ℹ️';

  /// 成功/勾选
  static const String success = '✅';

  /// 错误/叉号
  static const String error = '❌';

  /// 时钟/时间
  static const String clock = '⏰';

  // ==========================================================================
  // 自然/天气（用于背景装饰）
  // ==========================================================================

  /// 太阳
  static const String sun = '☀️';

  /// 云
  static const String cloud = '☁️';

  /// 月亮
  static const String moon = '🌙';

  /// 树
  static const String tree = '🌳';

  /// 花
  static const String flower = '🌸';

  /// 叶子
  static const String leaf = '🍃';

  /// 草地
  static const String grass = '🌱';

  // ==========================================================================
  // 食物（用于喂食记录）
  // ==========================================================================

  /// 狗粮碗
  static const String foodBowl = '🥣';

  /// 骨头
  static const String bone = '🦴';

  /// 肉
  static const String meat = '🍖';

  /// 鱼（食物）
  static const String fishFood = '🐟';

  /// 水
  static const String water = '💧';

  /// 零食
  static const String treat = '🍪';

  // ==========================================================================
  // 社交/互动
  // ==========================================================================

  /// 点赞/喜欢
  static const String like = '👍';

  /// 心（喜爱）
  static const String heart = '❤️';

  /// 评论/对话
  static const String comment = '💬';

  /// 分享
  static const String share = '🔗';

  /// 火（热门）
  static const String fire = '🔥';

  // ==========================================================================
  // 导航/菜单
  // ==========================================================================

  /// 首页
  static const String home = '🏠';

  /// 探索
  static const String explore = '🧭';

  /// 个人资料
  static const String profile = '👤';

  /// 设置
  static const String settings = '⚙️';

  /// 通知/铃铛
  static const String notification = '🔔';

  // ==========================================================================
  // 表情组合（用于特殊场景）
  // ==========================================================================

  /// 宠物生日
  static const String petBirthday = '🐾🎂';

  /// 宠物爱心
  static const String petLove = '🐾❤️';

  /// 健康检查
  static const String healthCheck = '❤️👨‍⚕️';

  /// 玩耍时间
  static const String playTime = '🎾😄';

  /// 散步时间
  static const String walkTime = '🚶🐕';

  /// 睡眠时间
  static const String sleepTime = '💤😴';
}

// ==========================================================================
// 辅助工具函数
// ==========================================================================

/// 表情符号样式辅助类
///
/// 提供便捷的方法来创建带表情符号的文本样式
class EmojiHelper {
  EmojiHelper._();

  /// 创建带表情符号的文本
  ///
  /// [emoji] 表情符号
  /// [text] 文本内容
  /// [emojiSize] 表情符号大小（可选）
  /// [spacing] 表情符号和文本之间的间距（可选）
  static String withEmoji(String emoji, String text, {String spacing = ' '}) {
    return '$emoji$spacing$text';
  }

  /// 创建表情符号前缀文本
  ///
  /// 常用于按钮、标题等
  static String prefix(String emoji, String text) {
    return withEmoji(emoji, text, spacing: ' ');
  }

  /// 创建表情符号后缀文本
  ///
  /// 常用于列表项、标签等
  static String suffix(String text, String emoji) {
    return '$text $emoji';
  }
}
