/*
  文件：core/result.dart
  说明：
  - Result 类型定义（用于错误处理）
  - 提供类型安全的成功/失败结果包装
  - 替代异常抛出，让错误处理更显式

  使用示例：
  ```dart
  // 在 Service 层返回 Result
  Future<Result<String>> generateCaption() async {
    try {
      final response = await _api.generate();
      return Success(response.text);
    } on NetworkException {
      return Failure('No internet connection');
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  // 在 UI 层处理 Result
  final result = await service.generateCaption();
  result.when(
    success: (caption) {
      setState(() => _text = caption);
    },
    failure: (message) {
      showErrorSnackBar(message);
    },
  );
  ```
*/

/// Result 类型基类
///
/// 表示一个操作的结果，可能是成功或失败
sealed class Result<T> {
  const Result();

  /// 成功时执行 success 回调，失败时执行 failure 回调
  ///
  /// 参数：
  /// - success: 成功时的回调，接收成功数据
  /// - failure: 失败时的回调，接收错误消息
  void when({
    required void Function(T data) success,
    required void Function(String message) failure,
  }) {
    switch (this) {
      case Success(:final data):
        success(data);
      case Failure(:final message):
        failure(message);
    }
  }

  /// 将 Result 映射为另一个类型
  ///
  /// 参数：
  /// - transform: 转换函数
  ///
  /// 返回值：新的 Result<R>
  ///
  /// 示例：
  /// ```dart
  /// Result<String> result = Success('100');
  /// Result<int> intResult = result.map((s) => int.parse(s));
  /// ```
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final message, :final exception) => Failure(message, exception),
    };
  }

  /// 获取数据或返回 null
  ///
  /// 返回值：
  /// - Success: 返回数据
  /// - Failure: 返回 null
  T? get dataOrNull {
    return switch (this) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  /// 获取数据或提供默认值
  ///
  /// 参数：
  /// - defaultValue: 失败时的默认值
  ///
  /// 返回值：数据或默认值
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(:final data) => data,
      Failure() => defaultValue,
    };
  }

  /// 检查是否为成功
  bool get isSuccess => this is Success<T>;

  /// 检查是否为失败
  bool get isFailure => this is Failure<T>;
}

/// 成功结果
///
/// 包含操作成功后的数据
class Success<T> extends Result<T> {
  /// 成功数据
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// 失败结果
///
/// 包含错误消息和可选的异常对象
class Failure<T> extends Result<T> {
  /// 错误消息（用户友好的描述）
  final String message;

  /// 原始异常对象（可选，用于调试）
  final Exception? exception;

  const Failure(this.message, [this.exception]);

  @override
  String toString() => 'Failure(message: $message, exception: $exception)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          exception == other.exception;

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Result 扩展方法
extension ResultExtensions<T> on Future<Result<T>> {
  /// 异步版本的 when
  ///
  /// 参数：
  /// - success: 成功时的异步回调
  /// - failure: 失败时的异步回调
  Future<void> whenAsync({
    required Future<void> Function(T data) success,
    required Future<void> Function(String message) failure,
  }) async {
    final result = await this;
    result.when(
      success: (data) async => await success(data),
      failure: (message) async => await failure(message),
    );
  }
}

/// 常用错误消息
class ErrorMessages {
  ErrorMessages._();

  // 网络错误
  static const String noInternet = 'No internet connection. Please check your network and try again.';
  static const String timeout = 'Request timed out. Please try again.';
  static const String serverError = 'Server error. Please try again later.';

  // API 错误
  static const String apiKeyMissing = 'API key not configured. Please contact support.';
  static const String rateLimitExceeded = 'Too many requests. Please try again later.';
  static const String invalidResponse = 'Invalid response from server.';

  // 用户输入错误
  static const String emptyInput = 'Please enter some content.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPassword = 'Password must be at least 6 characters.';

  // 权限错误
  static const String unauthorized = 'You are not authorized to perform this action.';
  static const String insufficientTreats = 'Not enough Treats! Please check in daily or complete challenges to earn more.';

  // 数据错误
  static const String dataNotFound = 'Data not found.';
  static const String saveFailed = 'Failed to save data. Please try again.';

  /// 生成通用错误消息
  ///
  /// 参数：
  /// - error: 异常对象
  ///
  /// 返回值：用户友好的错误消息
  static String fromException(dynamic error) {
    if (error == null) return 'An unknown error occurred.';

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') || errorString.contains('network')) {
      return noInternet;
    }

    if (errorString.contains('timeout')) {
      return timeout;
    }

    if (errorString.contains('429')) {
      return rateLimitExceeded;
    }

    if (errorString.contains('500') || errorString.contains('502')) {
      return serverError;
    }

    return 'An error occurred: ${error.toString()}';
  }
}
