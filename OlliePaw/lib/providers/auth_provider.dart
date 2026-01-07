/*
  文件：providers/auth_provider.dart
  说明：
  - 认证状态管理 Provider
  - 包装 AuthService，提供 UI 可观察的认证状态
  - 处理登录、注册、登出操作

  架构说明：
  - 使用 ChangeNotifier 通知 UI 更新
  - 监听 AuthService 的认证状态流
  - 提供加载状态和错误处理
*/

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// 认证状态枚举
enum AuthStatus {
  /// 未初始化
  uninitialized,

  /// 未登录
  unauthenticated,

  /// 已登录
  authenticated,

  /// 加载中
  loading,
}

/// 认证 Provider
///
/// 管理用户认证状态，包装 AuthService
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  /// 当前认证状态
  AuthStatus _status = AuthStatus.uninitialized;

  /// 当前用户
  AuthUser? _currentUser;

  /// 错误消息
  String? _errorMessage;

  /// 是否正在加载
  bool _isLoading = false;

  /// Stream subscription for auth state changes
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthProvider(this._authService) {
    _init();
  }

  // ==================== Getters ====================

  /// 认证状态
  AuthStatus get status => _status;

  /// 当前用户
  AuthUser? get currentUser => _currentUser;

  /// 用户ID（简写）
  String? get uid => _currentUser?.uid;

  /// 用户邮箱
  String? get email => _currentUser?.email;

  /// 用户显示名称
  String? get displayName => _currentUser?.displayName;

  /// 用户类型
  String? get userType => _currentUser?.userType;

  /// 是否已登录
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  // ==================== 初始化 ====================

  /// 初始化
  Future<void> _init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // 初始化 AuthService
      await _authService.initialize();

      // 监听认证状态变化 - 存储订阅以便后续取消
      _authSubscription = _authService.authStateChanges.listen((user) {
        _currentUser = user;
        _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
        notifyListeners();
      });

      // 设置初始状态
      _currentUser = _authService.currentUser;
      _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ==================== 用户操作 ====================

  /// 用户注册
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
    String? userType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 用户登录
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 用户登出
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除账户
  Future<bool> deleteAccount() async {
    _setLoading(true);

    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 更新用户信息
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user is currently signed in';
      return false;
    }

    _setLoading(true);

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      _currentUser = _authService.currentUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _setLoading(false);
      return false;
    }
  }

  // ==================== 辅助方法 ====================

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 清除错误消息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 将 AuthException 转换为用户友好的错误消息
  String _getErrorMessage(AuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'user-not-found':
        return 'Invalid email or password';
      case 'wrong-password':
        return 'Invalid email or password';
      default:
        return e.message;
    }
  }

  @override
  void dispose() {
    // 取消认证状态流订阅，防止内存泄漏
    _authSubscription?.cancel();
    // AuthService 由 main.dart 管理生命周期，这里不需要 dispose
    super.dispose();
  }
}
