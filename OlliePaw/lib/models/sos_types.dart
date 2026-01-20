/*
  文件：models/sos_types.dart
  说明：
  - SOS 紧急寻宠系统数据模型
  - 社区广播系统数据模型
  - 线索上报数据模型

  功能：
  - 宠物走失紧急广播
  - GPS 定位与范围扩散
  - 悬赏系统 (Treats + 真实货币)
  - 线索收集与验证
  - 社区广播（危险预警、社交活动、闲置交换）
*/

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// SOS 状态
enum SOSStatus {
  active,    // 寻找中
  resolved,  // 已找到
  expired,   // 已过期
  cancelled, // 已取消
}

/// SOS 优先级
enum SOSPriority {
  emergency, // 紧急（刚走失）
  urgent,    // 加急（超过2小时）
  normal,    // 普通
}

/// 广播类型
enum BroadcastType {
  sos,         // 🔴 紧急寻宠
  danger,      // 🔴 危险预警（老鼠药、碎玻璃等）
  social,      // 🟢 社交活动（遛狗组局、宠物聚会）
  marketplace, // 🟡 闲置市场（免费赠送、拼车等）
}

/// BroadcastType 扩展 - 统一所有类型相关的映射逻辑
///
/// 消除 broadcast_create_screen.dart 和其他文件中的重复 switch 语句
extension BroadcastTypeExtension on BroadcastType {
  /// 类型对应的颜色
  Color get color {
    switch (this) {
      case BroadcastType.sos:
        return AppColors.error;
      case BroadcastType.danger:
        return AppColors.warning;
      case BroadcastType.social:
        return AppColors.success;
      case BroadcastType.marketplace:
        return AppColors.warning;
    }
  }

  /// 类型对应的图标
  String get icon {
    switch (this) {
      case BroadcastType.sos:
        return '🔴';
      case BroadcastType.danger:
        return '⚠️';
      case BroadcastType.social:
        return '🟢';
      case BroadcastType.marketplace:
        return '🟡';
    }
  }

  /// 类型对应的显示名称
  String get displayName {
    switch (this) {
      case BroadcastType.sos:
        return '紧急寻宠';
      case BroadcastType.danger:
        return '危险预警';
      case BroadcastType.social:
        return '社交活动';
      case BroadcastType.marketplace:
        return '闲置市场';
    }
  }

  /// 类型对应的描述
  String get description {
    switch (this) {
      case BroadcastType.sos:
        return '紧急寻找走失的宠物';
      case BroadcastType.danger:
        return '发布安全警告（毒物、玻璃等）';
      case BroadcastType.social:
        return '组织遛狗聚会、宠物派对';
      case BroadcastType.marketplace:
        return '分享闲置物品、店铺优惠';
    }
  }

  /// 类型对应的 Treats 费用
  int get cost {
    switch (this) {
      case BroadcastType.sos:
      case BroadcastType.danger:
        return 0; // 免费
      case BroadcastType.social:
      case BroadcastType.marketplace:
        return 50; // 50 Treats
    }
  }
}

/// 位置数据
class LocationData {
  final double latitude;   // 纬度
  final double longitude;  // 经度
  final String? addressName; // 人类可读地址（如"中央公园"）
  final String city;       // 城市
  final DateTime timestamp; // 记录时间

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.addressName,
    required this.city,
    required this.timestamp,
  });

  /// 从 JSON 创建
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressName: json['addressName'] as String?,
      city: json['city'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'addressName': addressName,
      'city': city,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 计算与另一个位置的距离（公里）
  /// 使用 Haversine 公式
  double distanceTo(LocationData other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  @override
  String toString() {
    return addressName ?? '$city (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
  }
}

/// SOS 寻宠帖子
class SOSPost {
  final String id;
  final String petId;          // 宠物 ID
  final String ownerId;        // 主人 ID
  final String ownerName;      // 主人名字
  final String ownerAvatar;    // 主人头像

  // 宠物信息（从 Pet model 缓存）
  final String petName;
  final String petBreed;
  final String petPhotoUrl;
  final List<String> petCharacteristics; // 特征（如：白色爪子、项圈、胎记）

  // 位置信息
  final LocationData lastSeenLocation;
  final DateTime lastSeenTime;
  final double searchRadiusKm; // 搜索半径（3km -> 10km）

  // 悬赏
  final int treatsReward;          // Treats 悬赏
  final String? realMoneyReward;   // 真实货币悬赏（未来功能）

  // 状态
  final SOSStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime expiresAt;        // 自动过期时间（48小时）

  // 互动数据
  final int viewCount;             // 浏览次数
  final List<String> clueIds;      // 线索 ID 列表

  // Firebase 元数据
  final DateTime updatedAt;
  final bool isDeleted;

  const SOSPost({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatar,
    required this.petName,
    required this.petBreed,
    required this.petPhotoUrl,
    required this.petCharacteristics,
    required this.lastSeenLocation,
    required this.lastSeenTime,
    this.searchRadiusKm = 3.0,
    required this.treatsReward,
    this.realMoneyReward,
    this.status = SOSStatus.active,
    required this.createdAt,
    this.resolvedAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.clueIds = const [],
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// 从 JSON 创建
  factory SOSPost.fromJson(Map<String, dynamic> json) {
    return SOSPost(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      ownerAvatar: json['ownerAvatar'] as String,
      petName: json['petName'] as String,
      petBreed: json['petBreed'] as String,
      petPhotoUrl: json['petPhotoUrl'] as String,
      petCharacteristics: List<String>.from(json['petCharacteristics'] as List),
      lastSeenLocation: LocationData.fromJson(json['lastSeenLocation'] as Map<String, dynamic>),
      lastSeenTime: DateTime.parse(json['lastSeenTime'] as String),
      searchRadiusKm: (json['searchRadiusKm'] as num?)?.toDouble() ?? 3.0,
      treatsReward: json['treatsReward'] as int,
      realMoneyReward: json['realMoneyReward'] as String?,
      status: SOSStatus.values.firstWhere(
        (e) => e.toString() == 'SOSStatus.${json['status']}',
        orElse: () => SOSStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      clueIds: List<String>.from(json['clueIds'] as List? ?? []),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'petName': petName,
      'petBreed': petBreed,
      'petPhotoUrl': petPhotoUrl,
      'petCharacteristics': petCharacteristics,
      'lastSeenLocation': lastSeenLocation.toJson(),
      'lastSeenTime': lastSeenTime.toIso8601String(),
      'searchRadiusKm': searchRadiusKm,
      'treatsReward': treatsReward,
      'realMoneyReward': realMoneyReward,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewCount': viewCount,
      'clueIds': clueIds,
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// 复制并修改
  SOSPost copyWith({
    String? id,
    String? petId,
    String? ownerId,
    String? ownerName,
    String? ownerAvatar,
    String? petName,
    String? petBreed,
    String? petPhotoUrl,
    List<String>? petCharacteristics,
    LocationData? lastSeenLocation,
    DateTime? lastSeenTime,
    double? searchRadiusKm,
    int? treatsReward,
    String? realMoneyReward,
    SOSStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    DateTime? expiresAt,
    int? viewCount,
    List<String>? clueIds,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return SOSPost(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
      petPhotoUrl: petPhotoUrl ?? this.petPhotoUrl,
      petCharacteristics: petCharacteristics ?? this.petCharacteristics,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      lastSeenTime: lastSeenTime ?? this.lastSeenTime,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      treatsReward: treatsReward ?? this.treatsReward,
      realMoneyReward: realMoneyReward ?? this.realMoneyReward,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      clueIds: clueIds ?? this.clueIds,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 是否可以扩大搜索范围
  bool get canExpandRadius {
    // 2小时后且当前半径为3km
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;
    return hoursSinceCreation >= 2 && searchRadiusKm < 10;
  }

  /// 获取优先级
  SOSPriority get priority {
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;
    if (hoursSinceCreation < 2) return SOSPriority.emergency;
    if (hoursSinceCreation < 12) return SOSPriority.urgent;
    return SOSPriority.normal;
  }
}

/// 线索上报
class ClueReport {
  final String id;
  final String sosPostId;      // SOS 帖子 ID
  final String reporterId;     // 上报人 ID
  final String reporterName;   // 上报人名字

  // 线索详情
  final String description;    // 描述
  final String? photoUrl;      // 照片 URL（可选）
  final LocationData location; // 发现位置
  final DateTime timestamp;    // 上报时间

  // 验证状态
  final bool verifiedByOwner;  // 主人已验证
  final bool helpful;          // 是否有帮助

  const ClueReport({
    required this.id,
    required this.sosPostId,
    required this.reporterId,
    required this.reporterName,
    required this.description,
    this.photoUrl,
    required this.location,
    required this.timestamp,
    this.verifiedByOwner = false,
    this.helpful = false,
  });

  /// 从 JSON 创建
  factory ClueReport.fromJson(Map<String, dynamic> json) {
    return ClueReport(
      id: json['id'] as String,
      sosPostId: json['sosPostId'] as String,
      reporterId: json['reporterId'] as String,
      reporterName: json['reporterName'] as String,
      description: json['description'] as String,
      photoUrl: json['photoUrl'] as String?,
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      verifiedByOwner: json['verifiedByOwner'] as bool? ?? false,
      helpful: json['helpful'] as bool? ?? false,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sosPostId': sosPostId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'description': description,
      'photoUrl': photoUrl,
      'location': location.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'verifiedByOwner': verifiedByOwner,
      'helpful': helpful,
    };
  }

  /// 复制并修改
  ClueReport copyWith({
    String? id,
    String? sosPostId,
    String? reporterId,
    String? reporterName,
    String? description,
    String? photoUrl,
    LocationData? location,
    DateTime? timestamp,
    bool? verifiedByOwner,
    bool? helpful,
  }) {
    return ClueReport(
      id: id ?? this.id,
      sosPostId: sosPostId ?? this.sosPostId,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      verifiedByOwner: verifiedByOwner ?? this.verifiedByOwner,
      helpful: helpful ?? this.helpful,
    );
  }
}

/// 社区广播
class CommunityBroadcast {
  final String id;
  final BroadcastType type;    // 广播类型
  final String authorId;       // 发布人 ID
  final String authorName;     // 发布人名字
  final String authorAvatar;   // 发布人头像

  // 内容
  final String title;          // 标题
  final String content;        // 内容
  final String? imageUrl;      // 图片 URL（可选）

  // 位置与范围
  final LocationData location; // 发布位置
  final double rangeKm;        // 广播半径（公里）

  // 过期时间
  final DateTime createdAt;
  final DateTime expiresAt;    // 自动删除时间（1-24小时）

  // 费用与互动
  final int treatsCost;        // Treats 费用（SOS 免费，社交/市场 50）
  final int likeCount;         // 点赞数
  final int responseCount;     // 回复数

  const CommunityBroadcast({
    required this.id,
    required this.type,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.location,
    required this.rangeKm,
    required this.createdAt,
    required this.expiresAt,
    this.treatsCost = 0,
    this.likeCount = 0,
    this.responseCount = 0,
  });

  /// 从 JSON 创建
  factory CommunityBroadcast.fromJson(Map<String, dynamic> json) {
    return CommunityBroadcast(
      id: json['id'] as String,
      type: BroadcastType.values.firstWhere(
        (e) => e.toString() == 'BroadcastType.${json['type']}',
        orElse: () => BroadcastType.social,
      ),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      rangeKm: (json['rangeKm'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      treatsCost: json['treatsCost'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      responseCount: json['responseCount'] as int? ?? 0,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'location': location.toJson(),
      'rangeKm': rangeKm,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'treatsCost': treatsCost,
      'likeCount': likeCount,
      'responseCount': responseCount,
    };
  }

  /// 复制并修改
  CommunityBroadcast copyWith({
    String? id,
    BroadcastType? type,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? title,
    String? content,
    String? imageUrl,
    LocationData? location,
    double? rangeKm,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? treatsCost,
    int? likeCount,
    int? responseCount,
  }) {
    return CommunityBroadcast(
      id: id ?? this.id,
      type: type ?? this.type,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      rangeKm: rangeKm ?? this.rangeKm,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      treatsCost: treatsCost ?? this.treatsCost,
      likeCount: likeCount ?? this.likeCount,
      responseCount: responseCount ?? this.responseCount,
    );
  }

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 获取类型图标 - 使用 BroadcastTypeExtension
  String get typeIcon => type.icon;

  /// 获取类型名称 - 使用 BroadcastTypeExtension
  String get typeName => type.displayName;

  /// 获取类型颜色 - 使用 BroadcastTypeExtension
  Color get typeColor => type.color;
}
