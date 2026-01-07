/*
  文件：providers/pet_provider.dart
  说明：
  - 宠物档案状态管理
  - 从原 AppState 拆分出来的宠物相关功能
  - 负责当前宠物信息、宠物切换、档案编辑

  职责：
  - 当前宠物信息管理
  - 宠物档案切换
  - 宠物信息更新
  - 数据持久化（v2.2）

  使用示例：
  ```dart
  // 读取当前宠物
  final pet = context.watch<PetProvider>().currentPet;

  // 切换宠物
  context.read<PetProvider>().switchPet(newPet);

  // 更新宠物信息
  context.read<PetProvider>().updatePet(updatedPet);
  ```
*/

import 'package:flutter/material.dart';
import '../models/types.dart';
import '../utils/mock_data.dart';
import '../services/persistence_service.dart';

/// 宠物档案状态管理
///
/// 管理当前激活的宠物档案和宠物列表
class PetProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  PetProvider(this._persistence) {
    _loadFromStorage();
  }
  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// 当前宠物档案
  ///
  /// 初始值为 Mock 数据（Barnaby - Golden Retriever）
  Pet _currentPet = MockData.initialPet;

  /// 用户拥有的所有宠物列表（未来扩展）
  List<Pet> _pets = [MockData.initialPet];

  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 获取当前宠物档案
  Pet get currentPet => _currentPet;

  /// 获取所有宠物列表
  List<Pet> get pets => List.unmodifiable(_pets);

  // ==========================================================================
  // 私有方法
  // ==========================================================================

  /// 从本地存储加载宠物数据
  Future<void> _loadFromStorage() async {
    final petId = _persistence.getCurrentPetId();
    if (petId != null) {
      final pet = _persistence.getPet(petId);
      if (pet != null) {
        _currentPet = pet;
      }
    }
    // 始终通知监听器，确保初始状态被传播
    notifyListeners();
  }

  // ==========================================================================
  // 状态修改方法
  // ==========================================================================

  /// 根据用户登录信息初始化宠物档案
  ///
  /// 参数：
  /// - userProfile: 用户档案对象
  ///
  /// 逻辑：
  /// - OWNER 类型：根据用户信息创建宠物档案
  /// - GUEST 类型：使用 Mock 数据
  void initializePetFromUser(UserProfile userProfile) {
    if (userProfile.type == UserType.OWNER) {
      // 根据用户信息创建宠物档案
      _currentPet = Pet(
        id: userProfile.id,
        name: userProfile.name.split(' ')[0], // 提取名字部分
        type: PetType.DOG, // 默认为狗
        breed: 'Mixed Breed', // 默认品种
        birthDate: DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String()
            .split('T')[0],
        avatarUrl: userProfile.avatarUrl ?? '',
        bio: 'A lovely pet! 🐾',
        vaccines: [],
        weightHistory: [],
        gallery: [],
        userId: userProfile.id, // 使用用户 ID 作为宠物所有者
      );
    } else {
      // GUEST 用户使用 Mock 数据
      _currentPet = MockData.initialPet;
    }
    notifyListeners();
  }

  /// 切换当前宠物
  ///
  /// 参数：
  /// - pet: 要切换到的宠物
  ///
  /// 用途：多宠物管理时切换激活宠物
  void switchPet(Pet pet) {
    _currentPet = pet;
    _persistence.saveCurrentPetId(pet.id);
    notifyListeners();
  }

  /// 更新当前宠物信息
  ///
  /// 参数：
  /// - pet: 更新后的宠物档案
  ///
  /// 用途：
  /// - 编辑宠物资料后保存
  /// - 更新宠物头像
  /// - 修改宠物基本信息
  void updatePet(Pet pet) {
    _currentPet = pet;

    // 同时更新宠物列表中的对应项
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
    }

    // 保存到本地存储
    _persistence.savePet(pet);
    notifyListeners();
  }

  /// 更新宠物档案（简化版：只更新名称和简介）
  ///
  /// 参数：
  /// - name: 宠物名称
  /// - bio: 宠物简介
  ///
  /// 使用场景：
  /// - 设置页面快速更新名称和简介
  void updatePetProfile(String name, String bio) {
    _currentPet = Pet(
      id: _currentPet.id,
      name: name,
      type: _currentPet.type,
      breed: _currentPet.breed,
      birthDate: _currentPet.birthDate,
      avatarUrl: _currentPet.avatarUrl,
      bio: bio,
      vaccines: _currentPet.vaccines,
      weightHistory: _currentPet.weightHistory,
      gallery: _currentPet.gallery,
      userId: _currentPet.userId, // 保持原有的 userId
    );

    // 同时更新宠物列表中的对应项
    final index = _pets.indexWhere((p) => p.id == _currentPet.id);
    if (index != -1) {
      _pets[index] = _currentPet;
    }

    // 保存到本地存储
    _persistence.savePet(_currentPet);
    notifyListeners();
  }

  /// 添加新宠物（未来功能）
  ///
  /// 参数：
  /// - pet: 新宠物档案
  ///
  /// 用途：支持用户添加多只宠物
  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  /// 删除宠物（未来功能）
  ///
  /// 参数：
  /// - petId: 要删除的宠物 ID
  ///
  /// 注意：不能删除当前激活的宠物
  void removePet(String petId) {
    if (_currentPet.id == petId) {
      throw Exception('Cannot remove current active pet');
    }

    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  /// 重置为默认宠物
  ///
  /// 用途：登出时恢复初始状态
  void reset() {
    _currentPet = MockData.initialPet;
    _pets = [MockData.initialPet];
    notifyListeners();
  }
}
