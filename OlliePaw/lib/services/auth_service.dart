/*
  文件：services/auth_service.dart
  说明：
  - 用户认证服务
  - 当前实现：Mock 认证（用于开发和测试）
  - 未来实现：Firebase Authentication

  功能：
  - 用户注册（邮箱/密码）
  - 用户登录（邮箱/密码）
  - 用户登出
  - 获取当前用户
  - 监听认证状态变化

  架构说明：
  - 使用 Stream 发送认证状态变化
  - 使用 SharedPreferences 持久化登录状态
  - 为 Firebase 迁移做好准备（接口兼容）
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户认证结果
class AuthUser {
  /// 用户唯一ID
  final String uid;

  /// 用户邮箱
  final String email;

  /// 用户显示名称
  final String? displayName;

  /// 用户头像URL
  final String? photoUrl;

  /// 用户类型（OWNER/GUEST）
  final String? userType;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.userType,
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'userType': userType,
    };
  }

  /// 从 JSON 反序列化
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      userType: json['userType'] as String?,
    );
  }
}

/// 认证异常
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

/// 认证服务
///
/// Mock 实现，用于开发阶段
/// 未来可以替换为 FirebaseAuth
class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 认证状态流控制器
  final _authStateController = StreamController<AuthUser?>.broadcast();

  // 当前用户
  AuthUser? _currentUser;

  // SharedPreferences 实例
  SharedPreferences? _prefs;

  // 存储键
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _mockUsersKey = 'mock_users'; // 模拟用户数据库

  /// 初始化服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCurrentUser();
  }

  /// 认证状态流
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  /// 当前用户
  AuthUser? get currentUser => _currentUser;

  /// 是否已登录
  bool get isLoggedIn => _currentUser != null;

  /// 加载当前用户
  Future<void> _loadCurrentUser() async {
    final isLoggedIn = _prefs?.getBool(_isLoggedInKey) ?? false;
    if (!isLoggedIn) {
      _currentUser = null;
      _authStateController.add(null);
      return;
    }

    final userJson = _prefs?.getString(_currentUserKey);
    if (userJson != null) {
      try {
        // 简单的 JSON 解析（实际项目中使用 dart:convert）
        final parts = userJson.split('|');
        if (parts.length >= 2) {
          _currentUser = AuthUser(
            uid: parts[0],
            email: parts[1],
            displayName: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
            photoUrl: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
            userType: parts.length > 4 && parts[4].isNotEmpty ? parts[4] : 'OWNER',
          );
          _authStateController.add(_currentUser);
        }
      } catch (e) {
        debugPrint('[AuthService] Error loading user: $e');
        _currentUser = null;
        _authStateController.add(null);
      }
    }
  }

  /// 保存当前用户
  Future<void> _saveCurrentUser(AuthUser? user) async {
    if (user == null) {
      await _prefs?.setBool(_isLoggedInKey, false);
      await _prefs?.remove(_currentUserKey);
    } else {
      await _prefs?.setBool(_isLoggedInKey, true);
      final userJson = '${user.uid}|${user.email}|${user.displayName ?? ''}|${user.photoUrl ?? ''}|${user.userType ?? 'OWNER'}';
      await _prefs?.setString(_currentUserKey, userJson);
    }
  }

  /// 用户注册
  ///
  /// Mock 实现：生成唯一 UID，存储到 SharedPreferences
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? userType,
  }) async {
    // 验证输入
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('invalid-email', 'Invalid email address');
    }

    if (password.length < 6) {
      throw const AuthException('weak-password', 'Password must be at least 6 characters');
    }

    // 检查邮箱是否已注册（Mock 实现）
    final existingUsers = _prefs?.getStringList(_mockUsersKey) ?? [];
    if (existingUsers.any((u) => u.contains(email))) {
      throw const AuthException('email-already-in-use', 'Email is already registered');
    }

    // 生成唯一 UID（Mock 实现：使用时间戳）
    final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // 创建用户
    final user = AuthUser(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@')[0],
      photoUrl: null,
      userType: userType ?? 'OWNER',
    );

    // 保存到 Mock 数据库 (包含用户类型)
    existingUsers.add('$uid|$email|$password|${userType ?? 'OWNER'}'); // 实际项目中密码应该加密
    await _prefs?.setStringList(_mockUsersKey, existingUsers);

    // 设置为当前用户
    _currentUser = user;
    await _saveCurrentUser(user);
    _authStateController.add(user);

    debugPrint('[AuthService] User registered: ${user.email} (uid: ${user.uid}, type: ${user.userType})');
    return user;
  }

  /// 用户登录
  ///
  /// Mock 实现：验证邮箱和密码
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 验证输入
    if (email.isEmpty || !email.contains('@')) {
      throw const AuthException('invalid-email', 'Invalid email address');
    }

    if (password.isEmpty) {
      throw const AuthException('wrong-password', 'Password cannot be empty');
    }

    // 查找用户（Mock 实现）
    final existingUsers = _prefs?.getStringList(_mockUsersKey) ?? [];
    final userRecord = existingUsers.firstWhere(
      (u) => u.contains(email) && u.contains(password),
      orElse: () => '',
    );

    if (userRecord.isEmpty) {
      throw const AuthException('user-not-found', 'Invalid email or password');
    }

    // 解析用户信息
    final parts = userRecord.split('|');
    final user = AuthUser(
      uid: parts[0],
      email: parts[1],
      displayName: email.split('@')[0],
      photoUrl: null,
      userType: parts.length > 3 ? parts[3] : 'OWNER', // Get user type from stored record
    );

    // 设置为当前用户
    _currentUser = user;
    await _saveCurrentUser(user);
    _authStateController.add(user);

    debugPrint('[AuthService] User logged in: ${user.email} (uid: ${user.uid})');
    return user;
  }

  /// 用户登出
  Future<void> signOut() async {
    _currentUser = null;
    await _saveCurrentUser(null);
    _authStateController.add(null);
    debugPrint('[AuthService] User logged out');
  }

  /// 删除账户（Mock 实现）
  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw const AuthException('no-current-user', 'No user is currently signed in');
    }

    // 从 Mock 数据库删除
    final existingUsers = _prefs?.getStringList(_mockUsersKey) ?? [];
    existingUsers.removeWhere((u) => u.startsWith(_currentUser!.uid));
    await _prefs?.setStringList(_mockUsersKey, existingUsers);

    // 登出
    await signOut();
    debugPrint('[AuthService] Account deleted');
  }

  /// 更新用户信息
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('no-current-user', 'No user is currently signed in');
    }

    _currentUser = AuthUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
    );

    await _saveCurrentUser(_currentUser);
    _authStateController.add(_currentUser);
    debugPrint('[AuthService] Profile updated');
  }

  /// 释放资源
  void dispose() {
    _authStateController.close();
  }
}
