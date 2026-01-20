/*
  文件：models/types.dart
  说明：
  - 定义应用所用的基础数据结构（枚举与模型类），包括：
    用户类型、宠物类型、帖子分类、挑战、用户档案、疫苗、体重记录、宠物、帖子、聊天消息、时刻
  - 这些类型贯穿各个模块（screens/providers/widgets），用于状态管理与渲染
  - 所有模型类都包含序列化方法（toJson/fromJson），为未来数据库迁移做准备

  架构说明：
  - 枚举类型：定义固定的数据类型分类
  - 模型类：定义数据结构，包含字段定义和构造函数
  - 序列化：支持 JSON 转换，便于数据持久化和网络传输
*/

// ============================================================================
// 枚举定义 (Enums)
// ============================================================================

/// 用户类型枚举
/// 定义应用中不同角色的用户类型，用于权限控制和功能展示
///
/// 使用场景：
/// - 控制用户可访问的功能（例如：只有 OWNER 可以编辑宠物信息）
/// - 展示不同的用户界面（例如：GUEST 显示简化版个人页）
/// - 路由权限控制（例如：MERCHANT 可访问商家后台）
enum UserType {
  /// 宠物主人 - 拥有完整功能权限，可创建和管理宠物档案
  owner,

  /// 访客用户 - 只读权限，可浏览内容但不能发布或管理宠物
  guest,

  /// 商家账号 - 预留功能，未来用于商家发布产品和广告
  merchant,
}

/// 宠物类型枚举
/// 定义宠物的物种分类，用于数据分类和展示
///
/// 使用场景：
/// - 筛选和搜索特定类型的宠物
/// - 展示对应的图标和UI样式
/// - 统计分析（例如：狗类宠物占比）
enum PetType {
  /// 犬科 - 狗狗
  dog,

  /// 猫科 - 猫咪
  cat,

  /// 其他 - 兔子、仓鼠、鸟类等其他宠物
  other,
}

/// 帖子分类枚举
/// 定义动态帖子的内容类型，用于内容组织和筛选
///
/// 使用场景：
/// - Feed 流中的内容筛选（例如：只看"散步"类动态）
/// - 统计分析宠物活动类型
/// - 推荐算法（例如：推荐相似分类的内容）
enum PostCategory {
  /// 快照 - 日常照片、随拍
  snapshot,

  /// 睡觉 - 休息、打盹相关的内容
  sleepy,

  /// 散步 - 户外活动、遛弯
  walk,

  /// 玩耍 - 游戏、玩具、互动
  play,
}

// ============================================================================
// 挑战系统 (Challenge System)
// ============================================================================

/// 挑战模型类
/// 表示每日挑战或活动任务，用户完成后可获得奖励（Treats）
///
/// 使用场景：
/// - 首页展示每日挑战卡片
/// - 追踪用户完成进度
/// - 奖励系统（完成挑战获得 Treats 货币）
///
/// 字段说明：
/// - id: 唯一标识符，用于数据库索引
/// - title: 挑战标题（例如："The Boop Shot"）
/// - description: 详细说明（例如："拍摄宠物鼻子的特写照片"）
/// - reward: 完成奖励的 Treats 数量
/// - icon: 展示图标的 emoji 字符（例如："🐽"）
/// - color: UI 颜色标识（例如："pink"），前端根据此值映射具体颜色
/// - completed: 是否已完成
class Challenge {
  /// 挑战唯一ID
  final String id;

  /// 挑战标题
  final String title;

  /// 挑战描述
  final String description;

  /// 完成奖励（Treats数量）
  final int reward;

  /// 图标emoji
  final String icon;

  /// 颜色标识（例如 "pink", "blue"）
  /// 前端根据此字符串映射到具体颜色值
  final String color;

  /// 是否已完成
  final bool completed;

  /// 构造函数 - 创建挑战实例
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.icon,
    required this.color,
    required this.completed,
  });

  /// 序列化为 JSON 格式
  /// 用于数据库存储或网络传输
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'icon': icon,
      'color': color,
      'completed': completed,
    };
  }

  /// 从 JSON 反序列化
  /// 用于从数据库读取或接收网络数据
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: json['reward'] as int,
      icon: json['icon'] as String,
      color: json['color'] as String,
      completed: json['completed'] as bool,
    );
  }

  /// 复制实例并修改部分字段
  /// 用于状态更新（例如：标记为已完成）
  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? reward,
    String? icon,
    String? color,
    bool? completed,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      completed: completed ?? this.completed,
    );
  }
}

// ============================================================================
// 用户系统 (User System)
// ============================================================================

/// 用户档案模型类
/// 表示应用用户的基本信息
///
/// 使用场景：
/// - 用户认证和登录
/// - 个人资料展示
/// - 权限控制（根据 UserType）
///
/// 设计说明：
/// - OWNER 类型：breed、bio、avatarUrl 用于展示宠物主人信息
/// - GUEST 类型：spiritAnimal 用于访客的个性化标识
/// - 可空字段使用 ? 标记，支持部分信息未填写的情况
class UserProfile {
  /// 用户唯一ID
  final String id;

  /// 用户类型（OWNER/GUEST/MERCHANT）
  final UserType type;

  /// 用户名或昵称
  final String name;

  /// 头像URL（可选）
  final String? avatarUrl;

  /// 品种信息（可选，主要用于 OWNER 类型）
  final String? breed;

  /// 个人简介（可选）
  final String? bio;

  /// 精神动物（可选，主要用于 GUEST 类型的个性化展示）
  final String? spiritAnimal;

  /// 构造函数 - 创建用户档案实例
  UserProfile({
    required this.id,
    required this.type,
    required this.name,
    this.avatarUrl,
    this.breed,
    this.bio,
    this.spiritAnimal,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name, // 枚举转字符串
      'name': name,
      'avatarUrl': avatarUrl,
      'breed': breed,
      'bio': bio,
      'spiritAnimal': spiritAnimal,
    };
  }

  /// 从 JSON 反序列化
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      type: UserType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      breed: json['breed'] as String?,
      bio: json['bio'] as String?,
      spiritAnimal: json['spiritAnimal'] as String?,
    );
  }

  /// 复制实例并修改部分字段
  UserProfile copyWith({
    String? id,
    UserType? type,
    String? name,
    String? avatarUrl,
    String? breed,
    String? bio,
    String? spiritAnimal,
  }) {
    return UserProfile(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      breed: breed ?? this.breed,
      bio: bio ?? this.bio,
      spiritAnimal: spiritAnimal ?? this.spiritAnimal,
    );
  }
}

// ============================================================================
// 健康记录系统 (Health Records System)
// ============================================================================

/// 疫苗记录模型类
/// 记录宠物的疫苗接种历史和到期提醒
///
/// 使用场景：
/// - 健康页面展示疫苗接种历史
/// - 到期提醒功能（dueDate 临近时发送通知）
/// - 兽医档案管理
///
/// 字段说明：
/// - dateAdministered: 接种日期（格式："YYYY-MM-DD"）
/// - dueDate: 下次接种到期日期（格式："YYYY-MM-DD"）
/// - veterinarian: 接种兽医姓名
class Vaccine {
  /// 疫苗记录唯一ID
  final String id;

  /// 疫苗名称（例如："Rabies", "DHPP"）
  final String name;

  /// 接种日期（格式：YYYY-MM-DD）
  final String dateAdministered;

  /// 下次接种到期日期（格式：YYYY-MM-DD）
  final String dueDate;

  /// 接种兽医姓名
  final String veterinarian;

  /// 构造函数 - 创建疫苗记录实例
  Vaccine({
    required this.id,
    required this.name,
    required this.dateAdministered,
    required this.dueDate,
    required this.veterinarian,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateAdministered': dateAdministered,
      'dueDate': dueDate,
      'veterinarian': veterinarian,
    };
  }

  /// 从 JSON 反序列化
  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['id'] as String,
      name: json['name'] as String,
      dateAdministered: json['dateAdministered'] as String,
      dueDate: json['dueDate'] as String,
      veterinarian: json['veterinarian'] as String,
    );
  }

  /// 复制实例并修改部分字段
  Vaccine copyWith({
    String? id,
    String? name,
    String? dateAdministered,
    String? dueDate,
    String? veterinarian,
  }) {
    return Vaccine(
      id: id ?? this.id,
      name: name ?? this.name,
      dateAdministered: dateAdministered ?? this.dateAdministered,
      dueDate: dueDate ?? this.dueDate,
      veterinarian: veterinarian ?? this.veterinarian,
    );
  }
}

/// 体重记录模型类
/// 按时间记录宠物体重变化，用于健康追踪
///
/// 使用场景：
/// - 健康页面展示体重趋势图表
/// - 监测宠物健康状况（体重异常波动）
/// - 饮食计划调整参考
///
/// 字段说明：
/// - id: 唯一标识符（用于 Firestore 存储）
/// - date: 记录日期（简化格式如 "Oct", "Nov" 或完整日期 "2024-10-15"）
/// - weight: 体重值（单位：kg）
class WeightRecord {
  /// 记录唯一ID
  final String id;

  /// 记录日期（格式可以是 "Oct" 或 "2024-10-15"）
  final String date;

  /// 体重（单位：kg）
  final double weight;

  /// 构造函数 - 创建体重记录实例
  WeightRecord({
    required this.id,
    required this.date,
    required this.weight,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'weight': weight,
    };
  }

  /// 从 JSON 反序列化
  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      date: json['date'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  /// 复制实例并修改部分字段
  WeightRecord copyWith({
    String? id,
    String? date,
    double? weight,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }
}

// ============================================================================
// 宠物档案系统 (Pet Profile System)
// ============================================================================

/// 宠物档案模型类
/// 完整的宠物信息档案，包含基础信息、健康记录、相册等
///
/// 使用场景：
/// - 个人页面展示宠物详细信息
/// - 健康管理（疫苗、体重追踪）
/// - 社交功能（关注其他宠物）
/// - 相册管理
///
/// 关键字段：
/// - vaccines: 疫苗接种历史列表
/// - weightHistory: 体重变化记录列表
/// - gallery: 相册图片URL列表
/// - isFollowing: 社交功能，标记当前用户是否关注此宠物
///
/// Firebase 元数据（v2.5）：
/// - userId: 所属用户ID（用于权限控制和数据隔离）
/// - createdAt: 创建时间戳
/// - updatedAt: 最后更新时间戳
/// - isDeleted: 软删除标记
class Pet {
  /// 宠物唯一ID
  final String id;

  /// 宠物名字
  final String name;

  /// 宠物类型（DOG/CAT/OTHER）
  final PetType type;

  /// 品种（例如："Golden Retriever", "Scottish Fold"）
  final String breed;

  /// 出生日期（格式：YYYY-MM-DD）
  final String birthDate;

  /// 头像URL
  final String avatarUrl;

  /// 个人简介/签名（例如："Sock thief & Professional napper. 🧦💤"）
  final String bio;

  /// 疫苗接种记录列表
  final List<Vaccine> vaccines;

  /// 体重历史记录列表
  final List<WeightRecord> weightHistory;

  /// 相册图片URL列表
  final List<String> gallery;

  /// 是否已关注（用于社交功能和隐私控制）
  /// 注意：此字段非 final，可动态修改
  bool isFollowing;

  // ==================== Firebase 元数据 ====================

  /// 所属用户ID（Firebase Auth UID）
  /// 用于：
  /// - 权限控制（用户只能编辑自己的宠物）
  /// - 数据隔离（Firestore 安全规则）
  /// - 多用户支持
  final String userId;

  /// 创建时间（Firebase Firestore 时间戳）
  final DateTime? createdAt;

  /// 最后更新时间（Firebase Firestore 时间戳）
  final DateTime? updatedAt;

  /// 软删除标记（用于数据恢复和审计）
  final bool isDeleted;

  /// 构造函数 - 创建宠物档案实例
  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.avatarUrl,
    required this.bio,
    required this.vaccines,
    required this.weightHistory,
    required this.gallery,
    this.isFollowing = false,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'breed': breed,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
      'weightHistory': weightHistory.map((w) => w.toJson()).toList(),
      'gallery': gallery,
      'isFollowing': isFollowing,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// 从 JSON 反序列化
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PetType.values.firstWhere((e) => e.name == json['type']),
      breed: json['breed'] as String,
      birthDate: json['birthDate'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      vaccines: (json['vaccines'] as List<dynamic>)
          .map((v) => Vaccine.fromJson(v as Map<String, dynamic>))
          .toList(),
      weightHistory: (json['weightHistory'] as List<dynamic>)
          .map((w) => WeightRecord.fromJson(w as Map<String, dynamic>))
          .toList(),
      gallery: (json['gallery'] as List<dynamic>).cast<String>(),
      isFollowing: json['isFollowing'] as bool? ?? false,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// 复制实例并修改部分字段
  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    String? breed,
    String? birthDate,
    String? avatarUrl,
    String? bio,
    List<Vaccine>? vaccines,
    List<WeightRecord>? weightHistory,
    List<String>? gallery,
    bool? isFollowing,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      vaccines: vaccines ?? this.vaccines,
      weightHistory: weightHistory ?? this.weightHistory,
      gallery: gallery ?? this.gallery,
      isFollowing: isFollowing ?? this.isFollowing,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

// ============================================================================
// 社交动态系统 (Social Feed System)
// ============================================================================

/// 动态帖子模型类
/// 表示宠物发布的社交动态，类似微博/Instagram 的帖子
///
/// 使用场景：
/// - Feed 流展示（首页、探索页）
/// - 互动功能（点赞、评论计数）
/// - 内容分类和筛选
/// - 广告展示（isAd = true）
///
/// 关键字段：
/// - authorId: 发帖宠物的ID，用于关联宠物档案
/// - likes/comments: 不可变字段，通过 copyWith 或 Firestore 原子操作更新
/// - timestamp: 相对时间（例如："2h ago"）
/// - date: 精确日期（格式：YYYY-MM-DD）
/// - isAd: 标记是否为广告内容
/// - category: 帖子分类（snapshot/sleepy/walk/play）
///
/// Firebase 元数据（v2.5）：
/// - userId: 发帖用户ID（用于权限控制）
/// - createdAt: 创建时间戳
/// - updatedAt: 最后更新时间戳
/// - isDeleted: 软删除标记
///
/// 重要变更（v2.5 - Firebase 准备）：
/// - likes 和 comments 改为 final，防止数据竞争
/// - 使用 Firestore FieldValue.increment() 进行原子更新
class Post {
  /// 帖子唯一ID
  final String id;

  /// 作者（宠物）ID
  final String authorId;

  /// 作者（宠物）名称
  final String authorName;

  /// 作者（宠物）头像URL
  final String authorAvatar;

  /// 帖子文本内容
  final String content;

  /// 配图URL（可选）
  final String? imageUrl;

  /// 点赞数（不可变 - 通过 Firestore FieldValue.increment 更新）
  final int likes;

  /// 评论数（不可变 - 通过 Firestore FieldValue.increment 更新）
  final int comments;

  /// 相对时间戳（例如："2h ago", "5h ago"）
  final String timestamp;

  /// 精确日期（格式：YYYY-MM-DD）
  final String date;

  /// 是否为广告/推广内容
  final bool isAd;

  /// 位置信息（可选，例如："Central Park"）
  final String? location;

  /// 心情/状态（可选，例如："Happy", "Sleepy"）
  final String? mood;

  /// 帖子分类（snapshot/sleepy/walk/play）
  final PostCategory category;

  // ==================== Firebase 元数据 ====================

  /// 发帖用户ID（Firebase Auth UID）
  /// 用于：
  /// - 权限控制（用户只能编辑/删除自己的帖子）
  /// - 数据隔离（Firestore 安全规则）
  /// - Feed 流筛选
  final String userId;

  /// 创建时间（Firebase Firestore 时间戳）
  final DateTime? createdAt;

  /// 最后更新时间（Firebase Firestore 时间戳）
  final DateTime? updatedAt;

  /// 软删除标记（用于数据恢复和审计）
  final bool isDeleted;

  /// 构造函数 - 创建帖子实例
  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
    required this.date,
    this.isAd = false,
    this.location,
    this.mood,
    required this.category,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'timestamp': timestamp,
      'date': date,
      'isAd': isAd,
      'location': location,
      'mood': mood,
      'category': category.name,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// 从 JSON 反序列化
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      timestamp: json['timestamp'] as String,
      date: json['date'] as String,
      isAd: json['isAd'] as bool? ?? false,
      location: json['location'] as String?,
      mood: json['mood'] as String?,
      category: PostCategory.values.firstWhere((e) => e.name == json['category']),
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// 复制实例并修改部分字段
  /// 主要用于更新互动数（likes/comments）
  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    String? timestamp,
    String? date,
    bool? isAd,
    String? location,
    String? mood,
    PostCategory? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
      isAd: isAd ?? this.isAd,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

// ============================================================================
// AI 聊天系统 (AI Chat System)
// ============================================================================

/// 聊天消息模型类
/// 表示 AI 聊天对话中的单条消息
///
/// 使用场景：
/// - AI 助手对话（Gemini API 集成）
/// - 聊天历史记录
/// - 上下文管理（多轮对话）
///
/// 字段说明：
/// - role: 消息角色（"user"=用户, "assistant"=AI, "system"=系统提示）
/// - text: 消息文本内容
class ChatMessage {
  /// 消息角色（"user" / "assistant" / "system"）
  final String role;

  /// 消息文本内容
  final String text;

  /// 构造函数 - 创建聊天消息实例
  ChatMessage({
    required this.role,
    required this.text,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'text': text,
    };
  }

  /// 从 JSON 反序列化
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      text: json['text'] as String,
    );
  }

  /// 复制实例并修改部分字段
  ChatMessage copyWith({
    String? role,
    String? text,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      text: text ?? this.text,
    );
  }
}

// ============================================================================
// 时刻/相册系统 (Moments/Gallery System)
// ============================================================================

/// 时刻模型类
/// 表示照片或视频记录，可以添加到时间轴（Timeline）
///
/// 使用场景：
/// - 相册展示（Moments 标签页）
/// - 时间轴管理（可选择性添加/移除）
/// - 视频/图片分类
///
/// 关键字段：
/// - mediaUrl: 媒体文件URL（照片或视频）
/// - isVideo: 区分照片和视频
/// - isInTimeline: 标记是否已添加到时间轴
///
/// 注意：isInTimeline 为可变字段，支持动态添加/移除时间轴
class Moment {
  /// 时刻唯一ID
  final String id;

  /// 媒体文件URL（图片或视频链接）
  final String mediaUrl;

  /// 记录日期（格式：YYYY-MM-DD）
  final String date;

  /// 是否为视频（false=图片, true=视频）
  final bool isVideo;

  /// 是否已添加到时间轴（可变字段）
  /// 注意：此字段非 final，可动态修改
  bool isInTimeline;

  /// 构造函数 - 创建时刻实例
  Moment({
    required this.id,
    required this.mediaUrl,
    required this.date,
    this.isVideo = false,
    this.isInTimeline = false,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaUrl': mediaUrl,
      'date': date,
      'isVideo': isVideo,
      'isInTimeline': isInTimeline,
    };
  }

  /// 从 JSON 反序列化
  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      id: json['id'] as String,
      mediaUrl: json['mediaUrl'] as String,
      date: json['date'] as String,
      isVideo: json['isVideo'] as bool? ?? false,
      isInTimeline: json['isInTimeline'] as bool? ?? false,
    );
  }

  /// 复制实例并修改部分字段
  /// 主要用于切换时间轴状态
  Moment copyWith({
    String? id,
    String? mediaUrl,
    String? date,
    bool? isVideo,
    bool? isInTimeline,
  }) {
    return Moment(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      date: date ?? this.date,
      isVideo: isVideo ?? this.isVideo,
      isInTimeline: isInTimeline ?? this.isInTimeline,
    );
  }
}

// ============================================================================
// 评论系统 (Comment System)
// ============================================================================

/// 评论模型类
/// 表示帖子下的用户评论
///
/// 使用场景：
/// - 评论列表展示
/// - 评论互动（点赞）
/// - 评论通知
///
/// 字段说明：
/// - authorId: 评论者ID
/// - likes: 评论点赞数（可变）
/// - hasLiked: 当前用户是否已点赞（可变）
class Comment {
  /// 评论唯一ID
  final String id;

  /// 评论者用户ID
  final String authorId;

  /// 评论者名称
  final String authorName;

  /// 评论者头像URL
  final String authorAvatar;

  /// 评论文本内容
  final String content;

  /// 评论时间戳（相对时间，例如："2h ago"）
  final String timestamp;

  /// 点赞数（可变字段）
  int likes;

  /// 当前用户是否已点赞（可变字段）
  bool hasLiked;

  /// 构造函数 - 创建评论实例
  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.hasLiked = false,
  });

  /// 序列化为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'hasLiked': hasLiked,
    };
  }

  /// 从 JSON 反序列化
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
      likes: json['likes'] as int? ?? 0,
      hasLiked: json['hasLiked'] as bool? ?? false,
    );
  }

  /// 复制实例并修改部分字段
  Comment copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? timestamp,
    int? likes,
    bool? hasLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      hasLiked: hasLiked ?? this.hasLiked,
    );
  }
}
