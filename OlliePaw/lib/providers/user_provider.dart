/*
  文件：providers/user_provider.dart
  说明：
  - 用户认证状态管理
  - 从原 AppState 拆分出来的用户相关功能
  - 负责登录、登出、用户信息管理

  职责：
  - 用户认证状态（登录/登出）
  - 当前用户信息存储
  - 启动流程控制
  - 数据持久化（v2.2）

  使用示例：
  ```dart
  // 读取登录状态
  final isLoggedIn = context.watch<UserProvider>().isLoggedIn;

  // 执行登录
  context.read<UserProvider>().login(userProfile);

  // 登出
  context.read<UserProvider>().logout();
  ```
*/

import 'package:flutter/material.dart';
import '../models/types.dart';
import '../services/persistence_service.dart';

/// 用户认证状态管理
///
/// 管理用户登录状态和用户信息
class UserProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  UserProvider(this._persistence) {
    _loadFromStorage();
  }
  // ==========================================================================
  // 私有状态字段
  // ==========================================================================

  /// 启动页是否已完成
  bool _splashFinished = false;

  /// 当前登录的用户档案
  UserProfile? _currentUser;

  // ==========================================================================
  // 公开访问器
  // ==========================================================================

  /// 获取启动页完成状态
  bool get splashFinished => _splashFinished;

  /// 获取当前登录用户
  UserProfile? get currentUser => _currentUser;

  /// 检查用户是否已登录
  bool get isLoggedIn => _currentUser != null;

  // ==========================================================================
  // 私有方法
  // ==========================================================================

  /// 从本地存储加载用户数据
  Future<void> _loadFromStorage() async {
    final userId = _persistence.getCurrentUserId();
    if (userId != null) {
      _currentUser = _persistence.getUser(userId);
      _splashFinished = true; // 已登录用户跳过启动页
      notifyListeners();
    }
  }

  // ==========================================================================
  // 状态修改方法
  // ==========================================================================

  /// 标记启动页已完成
  void finishSplash() {
    _splashFinished = true;
    notifyListeners();
  }

  /// 用户登录
  ///
  /// 参数：
  /// - profile: 用户档案对象
  ///
  /// 效果：
  /// - 设置当前用户
  /// - 保存到本地存储
  /// - 标记启动页完成（跳过启动页）
  /// - 触发 UI 更新
  void login(UserProfile profile) {
    _currentUser = profile;
    _splashFinished = true; // 登录成功后跳过启动页
    _persistence.saveUser(profile);
    _persistence.saveCurrentUserId(profile.id);
    notifyListeners();
  }

  /// 用户登出
  ///
  /// 效果：
  /// - 清空当前用户
  /// - 清除本地存储
  /// - 保持启动页完成状态（避免重新显示splash）
  /// - 触发 UI 更新
  Future<void> logout() async {
    _currentUser = null;
    // DON'T reset _splashFinished - we want to go to LoginScreen, not SplashScreen
    // _splashFinished stays true so routing goes directly to LoginScreen
    await _persistence.logout();
    notifyListeners();
  }

  /// 更新用户信息
  ///
  /// 参数：
  /// - profile: 新的用户档案
  ///
  /// 用途：编辑用户资料后更新
  void updateUser(UserProfile profile) {
    _currentUser = profile;
    _persistence.saveUser(profile);
    notifyListeners();
  }
}
