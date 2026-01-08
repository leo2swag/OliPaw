/*
  文件：models/pet_hive_model.dart
  说明：
  - Pet 的 Hive 持久化模型
  - 用于将 Pet 对象序列化到本地数据库
  - 使用 Hive TypeAdapter 进行自动序列化/反序列化

  优化（v2.5 - Firebase 准备）：
  - 添加 type 字段，避免硬编码为 DOG
  - 添加 vaccines, weightHistory, gallery 的 JSON 序列化
  - 修复数据丢失问题
  - 添加 Firebase 元数据字段（createdAt, updatedAt, isDeleted）
*/
import 'dart:convert';
import 'package:hive/hive.dart';
import 'types.dart';

part 'pet_hive_model.g.dart';

/// Pet Hive 模型
///
/// 用于 Hive 数据库的持久化存储
@HiveType(typeId: 0)
class PetHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed;

  @HiveField(3)
  final String birthDate;

  @HiveField(4)
  final String avatarUrl;

  @HiveField(5)
  final String bio;

  /// 宠物类型（DOG, CAT, OTHER）
  @HiveField(6)
  final String type;

  /// 疫苗记录（JSON 序列化）
  @HiveField(7)
  final List<String> vaccinesJson;

  /// 体重历史（JSON 序列化）
  @HiveField(8)
  final List<String> weightHistoryJson;

  /// 相册 URL 列表
  @HiveField(9)
  final List<String> gallery;

  /// 创建时间（ISO8601 字符串）
  @HiveField(10)
  final String? createdAt;

  /// 最后更新时间（ISO8601 字符串）
  @HiveField(11)
  final String? updatedAt;

  /// 软删除标记
  @HiveField(12)
  final bool isDeleted;

  /// 所属用户ID（Firebase Auth UID）
  @HiveField(13)
  final String userId;

  PetHiveModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.avatarUrl,
    required this.bio,
    required this.type,
    this.vaccinesJson = const [],
    this.weightHistoryJson = const [],
    this.gallery = const [],
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    required this.userId,
  });

  /// 从 Pet 对象转换
  factory PetHiveModel.fromPet(Pet pet) {
    return PetHiveModel(
      id: pet.id,
      name: pet.name,
      breed: pet.breed,
      birthDate: pet.birthDate,
      avatarUrl: pet.avatarUrl,
      bio: pet.bio,
      type: pet.type.name,
      vaccinesJson: pet.vaccines
          .map((v) => jsonEncode(v.toJson()))
          .toList(),
      weightHistoryJson: pet.weightHistory
          .map((w) => jsonEncode(w.toJson()))
          .toList(),
      gallery: pet.gallery, // gallery 已经是 List<String>
      createdAt: pet.createdAt?.toIso8601String(),
      updatedAt: pet.updatedAt?.toIso8601String(),
      isDeleted: pet.isDeleted,
      userId: pet.userId,
    );
  }

  /// 转换为 Pet 对象
  Pet toPet() {
    return Pet(
      id: id,
      name: name,
      type: PetType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => PetType.dog,
      ),
      breed: breed,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      bio: bio,
      vaccines: vaccinesJson
          .map((json) => Vaccine.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList(),
      weightHistory: weightHistoryJson
          .map((json) => WeightRecord.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList(),
      gallery: gallery, // gallery 已经是 List<String>
      userId: userId,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      isDeleted: isDeleted,
    );
  }
}
