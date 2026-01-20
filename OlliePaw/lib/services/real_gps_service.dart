/*
  文件：services/real_gps_service.dart
  说明：
  - 真实 GPS 定位服务（可选功能）
  - 需要安装依赖才能使用

  安装步骤：
  1. 添加到 pubspec.yaml:
     dependencies:
       geolocator: ^10.1.0
       geocoding: ^2.1.1

  2. iOS 配置 (ios/Runner/Info.plist):
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>我们需要您的位置来显示附近的宠物 SOS</string>
     <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
     <string>我们需要您的位置来显示附近的宠物 SOS</string>

  3. Android 配置 (android/app/src/main/AndroidManifest.xml):
     <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
     <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  使用示例：
  ```dart
  final realGPS = RealGPSService();

  // 检查是否可用
  if (await realGPS.isAvailable()) {
    // 获取当前位置
    final location = await realGPS.getCurrentLocation();
    print('${location.latitude}, ${location.longitude}');

    // 获取地址
    final address = await realGPS.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );
    print(address);
  }
  ```

  v2.9 - Pet SOS Feature
*/

/// 真实 GPS 服务接口
///
/// 注意：此文件仅作为文档和接口定义
/// 实际实现需要安装 geolocator 和 geocoding 包
class RealGPSService {
  // Singleton 模式
  static final RealGPSService _instance = RealGPSService._internal();
  factory RealGPSService() => _instance;
  RealGPSService._internal();

  /// 检查 GPS 功能是否可用
  ///
  /// 返回 false，因为依赖未安装
  Future<bool> isAvailable() async {
    return false; // 需要安装 geolocator 包
  }

  /// 检查定位权限
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geolocator/geolocator.dart';
  ///
  /// Future<bool> checkPermission() async {
  ///   LocationPermission permission = await Geolocator.checkPermission();
  ///   if (permission == LocationPermission.denied) {
  ///     permission = await Geolocator.requestPermission();
  ///   }
  ///   return permission != LocationPermission.denied &&
  ///          permission != LocationPermission.deniedForever;
  /// }
  /// ```
  Future<bool> checkPermission() async {
    throw UnimplementedError('需要安装 geolocator 包');
  }

  /// 请求定位权限
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geolocator/geolocator.dart';
  ///
  /// Future<bool> requestPermission() async {
  ///   LocationPermission permission = await Geolocator.requestPermission();
  ///   return permission != LocationPermission.denied &&
  ///          permission != LocationPermission.deniedForever;
  /// }
  /// ```
  Future<bool> requestPermission() async {
    throw UnimplementedError('需要安装 geolocator 包');
  }

  /// 获取当前位置
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geolocator/geolocator.dart';
  ///
  /// Future<Position> getCurrentLocation() async {
  ///   bool hasPermission = await checkPermission();
  ///   if (!hasPermission) {
  ///     hasPermission = await requestPermission();
  ///     if (!hasPermission) {
  ///       throw Exception('定位权限被拒绝');
  ///     }
  ///   }
  ///
  ///   return await Geolocator.getCurrentPosition(
  ///     desiredAccuracy: LocationAccuracy.high,
  ///   );
  /// }
  /// ```
  Future<dynamic> getCurrentLocation() async {
    throw UnimplementedError('需要安装 geolocator 包');
  }

  /// 从坐标获取地址
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geocoding/geocoding.dart';
  ///
  /// Future<String> getAddressFromCoordinates(
  ///   double latitude,
  ///   double longitude,
  /// ) async {
  ///   try {
  ///     List<Placemark> placemarks = await placemarkFromCoordinates(
  ///       latitude,
  ///       longitude,
  ///     );
  ///
  ///     if (placemarks.isNotEmpty) {
  ///       Placemark place = placemarks[0];
  ///       return '${place.street}, ${place.locality}, ${place.administrativeArea}';
  ///     }
  ///     return '未知地址';
  ///   } catch (e) {
  ///     return '未知地址';
  ///   }
  /// }
  /// ```
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    throw UnimplementedError('需要安装 geocoding 包');
  }

  /// 从地址获取坐标
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geocoding/geocoding.dart';
  ///
  /// Future<List<double>?> getCoordinatesFromAddress(String address) async {
  ///   try {
  ///     List<Location> locations = await locationFromAddress(address);
  ///     if (locations.isNotEmpty) {
  ///       return [locations[0].latitude, locations[0].longitude];
  ///     }
  ///     return null;
  ///   } catch (e) {
  ///     return null;
  ///   }
  /// }
  /// ```
  Future<List<double>?> getCoordinatesFromAddress(String address) async {
    throw UnimplementedError('需要安装 geocoding 包');
  }

  /// 监听位置变化
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geolocator/geolocator.dart';
  ///
  /// Stream<Position> watchPosition() {
  ///   return Geolocator.getPositionStream(
  ///     locationSettings: const LocationSettings(
  ///       accuracy: LocationAccuracy.high,
  ///       distanceFilter: 10, // 移动 10 米后更新
  ///     ),
  ///   );
  /// }
  /// ```
  Stream<dynamic> watchPosition() {
    throw UnimplementedError('需要安装 geolocator 包');
  }

  /// 计算两点之间的距离（单位：米）
  ///
  /// 需要实现：
  /// ```dart
  /// import 'package:geolocator/geolocator.dart';
  ///
  /// double calculateDistance(
  ///   double lat1,
  ///   double lon1,
  ///   double lat2,
  ///   double lon2,
  /// ) {
  ///   return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  /// }
  /// ```
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    throw UnimplementedError('需要安装 geolocator 包');
  }
}

// ==========================================================================
// 集成示例
// ==========================================================================

/// 如何在 LocationService 中集成真实 GPS
///
/// 修改 location_service.dart:
/// ```dart
/// import 'real_gps_service.dart';
///
/// class LocationService {
///   final RealGPSService _realGPS = RealGPSService();
///   bool _useRealGPS = false;
///
///   /// 启用真实 GPS
///   Future<void> enableRealGPS() async {
///     if (await _realGPS.isAvailable()) {
///       final hasPermission = await _realGPS.checkPermission();
///       if (hasPermission) {
///         _useRealGPS = true;
///       }
///     }
///   }
///
///   /// 获取当前位置（自动选择 Mock 或真实 GPS）
///   Future<LocationData> getCurrentLocation() async {
///     if (_useRealGPS) {
///       try {
///         final position = await _realGPS.getCurrentLocation();
///         final address = await _realGPS.getAddressFromCoordinates(
///           position.latitude,
///           position.longitude,
///         );
///         return LocationData(
///           latitude: position.latitude,
///           longitude: position.longitude,
///           addressName: address,
///           city: '当前位置', // 从 address 中提取
///           timestamp: DateTime.now(),
///         );
///       } catch (e) {
///         // 回退到 Mock GPS
///         return _getMockLocation();
///       }
///     }
///     return _getMockLocation();
///   }
/// }
/// ```

// ==========================================================================
// 安装指南
// ==========================================================================

/// Step 1: 添加依赖
/// 在 pubspec.yaml 中添加：
/// ```yaml
/// dependencies:
///   geolocator: ^10.1.0
///   geocoding: ^2.1.1
/// ```
///
/// Step 2: iOS 配置
/// 在 ios/Runner/Info.plist 中添加：
/// ```xml
/// <key>NSLocationWhenInUseUsageDescription</key>
/// <string>我们需要您的位置来显示附近的宠物 SOS</string>
/// <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
/// <string>我们需要您的位置来显示附近的宠物 SOS</string>
/// ```
///
/// Step 3: Android 配置
/// 在 android/app/src/main/AndroidManifest.xml 中添加：
/// ```xml
/// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
/// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
/// ```
///
/// Step 4: 运行安装
/// ```bash
/// flutter pub get
/// ```
///
/// Step 5: 测试
/// ```dart
/// final realGPS = RealGPSService();
/// if (await realGPS.isAvailable()) {
///   final location = await realGPS.getCurrentLocation();
///   print('当前位置: ${location.latitude}, ${location.longitude}');
/// }
/// ```
