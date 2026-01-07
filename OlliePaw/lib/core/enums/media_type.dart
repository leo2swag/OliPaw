/*
  文件：core/enums/media_type.dart
  说明：
  - 媒体类型枚举
  - 提供类型安全的媒体类型判断
  - 消除字符串检测代码重复（.endsWith('.mp4') 等）

  优化（v2.5）：
  - 替代重复的 string.endsWith() 检测
  - 支持更多视频和图片格式
  - 类型安全，避免拼写错误

  使用示例：
  ```dart
  // 替代：mediaUrl.endsWith('.mp4')
  if (mediaUrl.mediaType.isVideo) {
    // 显示视频播放器
  }

  // 替代：selectedMedia.path.endsWith('.mp4')
  if (selectedMedia.path.mediaType == MediaType.video) {
    // 处理视频上传
  }
  ```
*/

/// 媒体类型枚举
enum MediaType {
  /// 图片类型
  image,

  /// 视频类型
  video,

  /// 未知类型
  unknown,
}

/// String 扩展方法：媒体类型检测
extension MediaTypeExtension on String {
  /// 获取媒体类型
  ///
  /// 通过文件扩展名判断媒体类型
  ///
  /// 支持的视频格式：
  /// - .mp4, .MP4
  /// - .mov, .MOV
  /// - .avi, .AVI
  /// - .mkv, .MKV
  /// - .wmv, .WMV
  /// - .flv, .FLV
  /// - .webm, .WEBM
  ///
  /// 支持的图片格式：
  /// - .jpg, .jpeg, .JPG, .JPEG
  /// - .png, .PNG
  /// - .gif, .GIF
  /// - .webp, .WEBP
  /// - .bmp, .BMP
  /// - .svg, .SVG
  MediaType get mediaType {
    final lowerPath = toLowerCase();

    // 视频格式检测
    if (lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.avi') ||
        lowerPath.endsWith('.mkv') ||
        lowerPath.endsWith('.wmv') ||
        lowerPath.endsWith('.flv') ||
        lowerPath.endsWith('.webm')) {
      return MediaType.video;
    }

    // 图片格式检测
    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.svg')) {
      return MediaType.image;
    }

    // 未知格式
    return MediaType.unknown;
  }

  /// 检查是否是视频
  ///
  /// 示例：
  /// ```dart
  /// if (filePath.isVideo) {
  ///   // 显示视频播放器
  /// }
  /// ```
  bool get isVideo => mediaType == MediaType.video;

  /// 检查是否是图片
  ///
  /// 示例：
  /// ```dart
  /// if (filePath.isImage) {
  ///   // 显示图片查看器
  /// }
  /// ```
  bool get isImage => mediaType == MediaType.image;

  /// 检查是否是未知格式
  bool get isUnknownMedia => mediaType == MediaType.unknown;
}

/// MediaType 扩展方法
extension MediaTypeHelper on MediaType {
  /// 获取媒体类型的显示名称
  ///
  /// 用于 UI 显示
  String get displayName {
    switch (this) {
      case MediaType.image:
        return '图片';
      case MediaType.video:
        return '视频';
      case MediaType.unknown:
        return '未知';
    }
  }

  /// 获取媒体类型的英文名称
  String get englishName {
    switch (this) {
      case MediaType.image:
        return 'Image';
      case MediaType.video:
        return 'Video';
      case MediaType.unknown:
        return 'Unknown';
    }
  }

  /// 获取媒体类型的图标 emoji
  String get icon {
    switch (this) {
      case MediaType.image:
        return '📸';
      case MediaType.video:
        return '🎥';
      case MediaType.unknown:
        return '❓';
    }
  }

  /// 检查是否支持该媒体类型
  bool get isSupported {
    return this == MediaType.image || this == MediaType.video;
  }
}
