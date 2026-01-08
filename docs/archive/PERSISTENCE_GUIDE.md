# 数据持久化实施指南 (Data Persistence Implementation Guide)

本文档提供完整的数据持久化实施方案，使用 Hive（本地数据库）和 SharedPreferences（轻量级键值存储）。

---

## 📋 目录

1. [依赖配置](#1-依赖配置)
2. [Hive 数据模型](#2-hive-数据模型)
3. [持久化服务实现](#3-持久化服务实现)
4. [Provider 集成](#4-provider-集成)
5. [使用示例](#5-使用示例)

---

## 1. 依赖配置

### 1.1 添加依赖到 pubspec.yaml

```yaml
dependencies:
  # 现有依赖...

  # 数据持久化
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1

dev_dependencies:
  # 现有依赖...

  # Hive 代码生成
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

### 1.2 安装依赖

```bash
cd OlliePaw
flutter pub get
```

---

## 2. Hive 数据模型

### 2.1 创建 Pet 模型适配器

**文件**: `lib/models/pet_hive_model.dart`

```dart
import 'package:hive/hive.dart';
import 'types.dart';

part 'pet_hive_model.g.dart';

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

  PetHiveModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.avatarUrl,
    required this.bio,
  });

  // 从 Pet 转换
  factory PetHiveModel.fromPet(Pet pet) {
    return PetHiveModel(
      id: pet.id,
      name: pet.name,
      breed: pet.breed,
      birthDate: pet.birthDate,
      avatarUrl: pet.avatarUrl,
      bio: pet.bio,
    );
  }

  // 转换为 Pet
  Pet toPet() {
    return Pet(
      id: id,
      name: name,
      type: PetType.DOG, // 默认值
      breed: breed,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      bio: bio,
      vaccines: [], // 从其他存储加载
      weightHistory: [],
      gallery: [],
    );
  }
}
```

### 2.2 创建 UserProfile 模型适配器

**文件**: `lib/models/user_hive_model.dart`

```dart
import 'package:hive/hive.dart';
import 'types.dart';

part 'user_hive_model.g.dart';

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

  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      type: type == 'OWNER' ? UserType.OWNER : UserType.GUEST,
      name: name,
      breed: breed,
      bio: bio,
      avatarUrl: avatarUrl,
      spiritAnimal: spiritAnimal,
    );
  }
}
```

### 2.3 生成适配器代码

```bash
flutter pub run build_runner build
```

这将生成 `pet_hive_model.g.dart` 和 `user_hive_model.g.dart` 文件。

---

## 3. 持久化服务实现

### 3.1 创建持久化服务

**文件**: `lib/services/persistence_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_hive_model.dart';
import '../models/user_hive_model.dart';
import '../models/types.dart';

/// 数据持久化服务
///
/// 职责：
/// - Hive: 存储复杂对象（Pet, UserProfile）
/// - SharedPreferences: 存储简单值（Treats, 签到日期）
class PersistenceService {
  // Hive Box 名称
  static const String _petBoxName = 'pets';
  static const String _userBoxName = 'users';

  // SharedPreferences 键
  static const String _treatsKey = 'treats';
  static const String _lastCheckInKey = 'last_checkin';
  static const String _consecutiveDaysKey = 'consecutive_days';
  static const String _currentPetIdKey = 'current_pet_id';
  static const String _currentUserIdKey = 'current_user_id';

  // Hive Boxes
  late Box<PetHiveModel> _petBox;
  late Box<UserHiveModel> _userBox;

  // SharedPreferences
  late SharedPreferences _prefs;

  // ==========================================================================
  // 初始化
  // ==========================================================================

  /// 初始化持久化服务
  ///
  /// 必须在 runApp 之前调用
  Future<void> initialize() async {
    // 初始化 Hive
    await Hive.initFlutter();

    // 注册适配器
    Hive.registerAdapter(PetHiveModelAdapter());
    Hive.registerAdapter(UserHiveModelAdapter());

    // 打开 boxes
    _petBox = await Hive.openBox<PetHiveModel>(_petBoxName);
    _userBox = await Hive.openBox<UserHiveModel>(_userBoxName);

    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // ==========================================================================
  // Pet 操作
  // ==========================================================================

  /// 保存宠物
  Future<void> savePet(Pet pet) async {
    final model = PetHiveModel.fromPet(pet);
    await _petBox.put(pet.id, model);
  }

  /// 获取宠物
  Pet? getPet(String id) {
    final model = _petBox.get(id);
    return model?.toPet();
  }

  /// 获取所有宠物
  List<Pet> getAllPets() {
    return _petBox.values.map((model) => model.toPet()).toList();
  }

  /// 删除宠物
  Future<void> deletePet(String id) async {
    await _petBox.delete(id);
  }

  /// 保存当前宠物 ID
  Future<void> saveCurrentPetId(String id) async {
    await _prefs.setString(_currentPetIdKey, id);
  }

  /// 获取当前宠物 ID
  String? getCurrentPetId() {
    return _prefs.getString(_currentPetIdKey);
  }

  // ==========================================================================
  // User 操作
  // ==========================================================================

  /// 保存用户
  Future<void> saveUser(UserProfile user) async {
    final model = UserHiveModel.fromUserProfile(user);
    await _userBox.put(user.id, model);
  }

  /// 获取用户
  UserProfile? getUser(String id) {
    final model = _userBox.get(id);
    return model?.toUserProfile();
  }

  /// 保存当前用户 ID
  Future<void> saveCurrentUserId(String id) async {
    await _prefs.setString(_currentUserIdKey, id);
  }

  /// 获取当前用户 ID
  String? getCurrentUserId() {
    return _prefs.getString(_currentUserIdKey);
  }

  /// 登出（清除当前用户）
  Future<void> logout() async {
    await _prefs.remove(_currentUserIdKey);
    await _prefs.remove(_currentPetIdKey);
  }

  // ==========================================================================
  // Currency 操作
  // ==========================================================================

  /// 保存 Treats
  Future<void> saveTreats(int treats) async {
    await _prefs.setInt(_treatsKey, treats);
  }

  /// 获取 Treats
  int getTreats() {
    return _prefs.getInt(_treatsKey) ?? 50; // 默认 50
  }

  // ==========================================================================
  // CheckIn 操作
  // ==========================================================================

  /// 保存签到日期
  Future<void> saveLastCheckIn(String date) async {
    await _prefs.setString(_lastCheckInKey, date);
  }

  /// 获取签到日期
  String? getLastCheckIn() {
    return _prefs.getString(_lastCheckInKey);
  }

  /// 保存连续签到天数
  Future<void> saveConsecutiveDays(int days) async {
    await _prefs.setInt(_consecutiveDaysKey, days);
  }

  /// 获取连续签到天数
  int getConsecutiveDays() {
    return _prefs.getInt(_consecutiveDaysKey) ?? 0;
  }

  // ==========================================================================
  // 清理
  // ==========================================================================

  /// 清除所有数据（用于测试或重置）
  Future<void> clearAll() async {
    await _petBox.clear();
    await _userBox.clear();
    await _prefs.clear();
  }
}
```

---

## 4. Provider 集成

### 4.1 更新 UserProvider

在 `lib/providers/user_provider.dart` 中添加持久化支持：

```dart
class UserProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  UserProvider(this._persistence) {
    _loadFromStorage();
  }

  // 从存储加载用户数据
  Future<void> _loadFromStorage() async {
    final userId = _persistence.getCurrentUserId();
    if (userId != null) {
      _currentUser = _persistence.getUser(userId);
      _splashFinished = true; // 已登录用户跳过启动页
      notifyListeners();
    }
  }

  void login(UserProfile profile) {
    _currentUser = profile;
    _persistence.saveUser(profile);
    _persistence.saveCurrentUserId(profile.id);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _splashFinished = false;
    _persistence.logout();
    notifyListeners();
  }
}
```

### 4.2 更新 PetProvider

```dart
class PetProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  PetProvider(this._persistence) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final petId = _persistence.getCurrentPetId();
    if (petId != null) {
      final pet = _persistence.getPet(petId);
      if (pet != null) {
        _currentPet = pet;
        notifyListeners();
      }
    }
  }

  void updatePet(Pet pet) {
    _currentPet = pet;
    _persistence.savePet(pet);
    notifyListeners();
  }

  void switchPet(Pet pet) {
    _currentPet = pet;
    _persistence.saveCurrentPetId(pet.id);
    notifyListeners();
  }
}
```

### 4.3 更新 CurrencyProvider

```dart
class CurrencyProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  CurrencyProvider(this._persistence) {
    _treats = _persistence.getTreats();
  }

  void earnTreats(int amount, {String reason = '奖励'}) {
    _treats += amount;
    _persistence.saveTreats(_treats);
    notifyListeners();
  }

  bool spendTreats(int amount) {
    if (_treats >= amount) {
      _treats -= amount;
      _persistence.saveTreats(_treats);
      notifyListeners();
      return true;
    }
    return false;
  }
}
```

### 4.4 更新 CheckInProvider

```dart
class CheckInProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  CheckInProvider(this._persistence) {
    _lastCheckIn = _persistence.getLastCheckIn();
    _consecutiveDays = _persistence.getConsecutiveDays();
  }

  bool checkIn() {
    if (isCheckedIn) return false;

    final today = _getTodayString();
    _lastCheckIn = today;
    _consecutiveDays++;

    _persistence.saveLastCheckIn(today);
    _persistence.saveConsecutiveDays(_consecutiveDays);

    notifyListeners();
    return true;
  }
}
```

### 4.5 更新 main.dart

```dart
void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化持久化服务
  final persistence = PersistenceService();
  await persistence.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(persistence)),
        ChangeNotifierProvider(create: (_) => PetProvider(persistence)),
        ChangeNotifierProvider(create: (_) => CurrencyProvider(persistence)),
        ChangeNotifierProvider(create: (_) => CheckInProvider(persistence)),
      ],
      child: const OlliePawApp(),
    ),
  );
}
```

---

## 5. 使用示例

### 5.1 自动保存用户登录状态

用户登录后数据自动持久化：

```dart
// 用户登录
context.read<UserProvider>().login(userProfile);

// 应用重启后自动恢复登录状态
// UserProvider 会在构造函数中自动加载
```

### 5.2 自动保存 Treats 余额

```dart
// 消费 Treats
context.read<CurrencyProvider>().spendTreats(5);

// 应用重启后余额保持不变
```

### 5.3 自动保存签到记录

```dart
// 签到
final success = context.read<CheckInProvider>().checkIn();

// 应用重启后签到状态保持
```

---

## 📝 实施步骤总结

1. ✅ 添加依赖到 `pubspec.yaml`
2. ✅ 运行 `flutter pub get`
3. ⏳ 创建 Hive 模型文件（`pet_hive_model.dart`, `user_hive_model.dart`）
4. ⏳ 运行 `flutter pub run build_runner build` 生成适配器
5. ⏳ 创建 `persistence_service.dart`
6. ⏳ 更新所有 Providers 添加持久化支持
7. ⏳ 更新 `main.dart` 初始化持久化服务
8. ✅ 测试数据持久化功能

---

## 🎯 预期效果

实施完成后：

- ✅ 用户登录状态跨应用重启保持
- ✅ Treats 余额自动保存
- ✅ 签到记录持久化
- ✅ 宠物档案自动保存
- ✅ 数据加载速度 < 100ms

---

## ⚠️ 注意事项

1. **数据迁移**: 首次启用时需要处理现有用户数据
2. **版本兼容**: Hive 适配器 typeId 不可更改
3. **错误处理**: 存储失败时提供降级方案
4. **隐私**: 敏感数据需要加密（考虑使用 `hive_secure_storage`）

---

**实施优先级**: P0 - 高优先级
**预计工时**: 2-3 小时
**复杂度**: 中等
