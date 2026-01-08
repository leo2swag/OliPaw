/*
  文件：models/user_hive_model.dart
  说明：
  - UserProfile 的 Hive 持久化模型
  - 用于将用户资料序列化到本地数据库
  - 使用 Hive TypeAdapter 进行自动序列化/反序列化
*/
import 'package:hive/hive.dart';
import 'types.dart';

part 'user_hive_model.g.dart';

/// UserProfile Hive 模型
///
/// 用于 Hive 数据库的持久化存储
@HiveType(typeId: 1)
class UserHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // "OWNER" or "GUEST"

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? breed;

  @HiveField(4)
  final String? bio;

  @HiveField(5)
  final String? avatarUrl;

  @HiveField(6)
  final String? spiritAnimal;

  UserHiveModel({
    required this.id,
    required this.type,
    required this.name,
    this.breed,
    this.bio,
    this.avatarUrl,
    this.spiritAnimal,
  });

  /// 从 UserProfile 对象转换
  factory UserHiveModel.fromUserProfile(UserProfile user) {
    return UserHiveModel(
      id: user.id,
      type: user.type.name,
      name: user.name,
      breed: user.breed,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      spiritAnimal: user.spiritAnimal,
    );
  }

  /// 转换为 UserProfile 对象
  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      type: type == 'OWNER' ? UserType.owner : UserType.guest,
      name: name,
      breed: breed,
      bio: bio,
      avatarUrl: avatarUrl,
      spiritAnimal: spiritAnimal,
    );
  }
}
