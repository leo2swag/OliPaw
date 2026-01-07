/*
  文件：core/exceptions/gemini_exceptions.dart
  说明：
  - Gemini AI 服务相关的自定义异常
  - 提供更精确的错误类型和友好的错误信息

  优化（v2.5）：
  - 细化错误类型，便于处理不同情况
  - 提供用户友好的错误消息
*/

/// Gemini 服务异常基类
abstract class GeminiException implements Exception {
  /// 错误消息
  final String message;

  /// 用户友好的错误描述
  final String userMessage;

  const GeminiException(this.message, this.userMessage);

  @override
  String toString() => 'GeminiException: $message';
}

/// API Key 未配置异常
class GeminiApiKeyMissingException extends GeminiException {
  const GeminiApiKeyMissingException()
      : super(
          'GEMINI_API_KEY is not configured in .env file',
          'AI service is not configured. Please contact support.',
        );
}

/// 网络错误异常
class GeminiNetworkException extends GeminiException {
  GeminiNetworkException([String? details])
      : super(
          'Network error: ${details ?? 'Failed to connect to AI service'}',
          'Network error. Please check your connection and try again.',
        );
}

/// API 错误异常
class GeminiApiException extends GeminiException {
  final int? statusCode;

  GeminiApiException(String message, [this.statusCode])
      : super(
          'API error${statusCode != null ? ' ($statusCode)' : ''}: $message',
          'AI service error. Please try again later.',
        );
}

/// 空响应异常
class GeminiEmptyResponseException extends GeminiException {
  const GeminiEmptyResponseException()
      : super(
          'Gemini returned an empty response',
          'No response received. Please try again.',
        );
}

/// 内容过滤异常（内容被安全过滤器拦截）
class GeminiContentFilteredException extends GeminiException {
  const GeminiContentFilteredException()
      : super(
          'Content was blocked by safety filters',
          'Your request was blocked for safety reasons. Please try different wording.',
        );
}

/// 超时异常
class GeminiTimeoutException extends GeminiException {
  const GeminiTimeoutException()
      : super(
          'Request timed out',
          'Request took too long. Please try again.',
        );
}

/// 配额超限异常
class GeminiQuotaExceededException extends GeminiException {
  const GeminiQuotaExceededException()
      : super(
          'API quota exceeded',
          'Service quota exceeded. Please try again later.',
        );
}
