/*
  文件：services/location_service.dart
  说明：
  - GPS 位置服务（MVP 版本使用模拟数据）
  - 距离计算
  - 范围查询

  功能：
  - 获取当前位置（模拟）
  - 计算两点间距离
  - 查询范围内的用户/帖子

  未来扩展：
  - 真实 GPS 集成（geolocator 包）
  - 地址反向解析（geocoding 包）
  - GeoFirestore 地理查询优化
*/

import '../models/sos_types.dart';

/// 位置服务
/// MVP 版本：使用预定义的模拟位置
/// 未来：集成真实 GPS
class LocationService {
  // 单例模式
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // 模拟位置数据库（城市地标）
  static final Map<String, LocationData> mockLocations = {
    // 北京
    'beijing_cbd': LocationData(
      latitude: 39.9163,
      longitude: 116.4619,
      addressName: '北京 CBD 中央商务区',
      city: '北京',
      timestamp: DateTime.now(),
    ),
    'beijing_park': LocationData(
      latitude: 39.9884,
      longitude: 116.3163,
      addressName: '北京奥林匹克森林公园',
      city: '北京',
      timestamp: DateTime.now(),
    ),

    // 上海
    'shanghai_bund': LocationData(
      latitude: 31.2396,
      longitude: 121.4908,
      addressName: '上海外滩',
      city: '上海',
      timestamp: DateTime.now(),
    ),
    'shanghai_century_park': LocationData(
      latitude: 31.2226,
      longitude: 121.5538,
      addressName: '上海世纪公园',
      city: '上海',
      timestamp: DateTime.now(),
    ),

    // 广州
    'guangzhou_tianhe': LocationData(
      latitude: 23.1367,
      longitude: 113.3265,
      addressName: '广州天河体育中心',
      city: '广州',
      timestamp: DateTime.now(),
    ),
    'guangzhou_park': LocationData(
      latitude: 23.1489,
      longitude: 113.3253,
      addressName: '广州天河公园',
      city: '广州',
      timestamp: DateTime.now(),
    ),

    // 深圳
    'shenzhen_civic_center': LocationData(
      latitude: 22.5468,
      longitude: 114.0545,
      addressName: '深圳市民中心',
      city: '深圳',
      timestamp: DateTime.now(),
    ),
    'shenzhen_lianhua_park': LocationData(
      latitude: 22.5520,
      longitude: 114.0408,
      addressName: '深圳莲花山公园',
      city: '深圳',
      timestamp: DateTime.now(),
    ),

    // 美国城市（示例）
    'nyc_central_park': LocationData(
      latitude: 40.7829,
      longitude: -73.9654,
      addressName: 'Central Park, New York',
      city: 'New York',
      timestamp: DateTime.now(),
    ),
    'sf_golden_gate': LocationData(
      latitude: 37.8199,
      longitude: -122.4783,
      addressName: 'Golden Gate Park, San Francisco',
      city: 'San Francisco',
      timestamp: DateTime.now(),
    ),
    'la_griffith': LocationData(
      latitude: 34.1341,
      longitude: -118.2943,
      addressName: 'Griffith Park, Los Angeles',
      city: 'Los Angeles',
      timestamp: DateTime.now(),
    ),
  };

  // 当前用户位置（默认值）
  LocationData? _currentLocation;

  /// 获取当前位置
  /// MVP: 返回模拟位置或提示用户选择
  Future<LocationData> getCurrentLocation() async {
    // 如果已有缓存位置，直接返回
    if (_currentLocation != null) {
      return _currentLocation!;
    }

    // MVP: 默认返回北京 CBD（实际应用中应提示用户选择）
    _currentLocation = mockLocations['beijing_cbd'];
    return _currentLocation!;
  }

  /// 设置当前位置（供用户手动选择）
  void setCurrentLocation(String locationKey) {
    if (mockLocations.containsKey(locationKey)) {
      _currentLocation = mockLocations[locationKey];
    }
  }

  /// 设置自定义位置
  void setCustomLocation(LocationData location) {
    _currentLocation = location;
  }

  /// 计算两点间距离（公里）
  /// 使用 LocationData 内置的 Haversine 公式
  double calculateDistance(LocationData from, LocationData to) {
    return from.distanceTo(to);
  }

  /// 检查位置是否在指定范围内
  bool isWithinRange(
    LocationData from,
    LocationData to,
    double rangeKm,
  ) {
    final distance = calculateDistance(from, to);
    return distance <= rangeKm;
  }

  /// 获取所有可用的模拟位置（供用户选择）
  List<MapEntry<String, LocationData>> getAvailableLocations() {
    return mockLocations.entries.toList();
  }

  /// 按城市分组获取位置
  Map<String, List<MapEntry<String, LocationData>>> getLocationsByCity() {
    final grouped = <String, List<MapEntry<String, LocationData>>>{};

    for (final entry in mockLocations.entries) {
      final city = entry.value.city;
      if (!grouped.containsKey(city)) {
        grouped[city] = [];
      }
      grouped[city]!.add(entry);
    }

    return grouped;
  }

  /// 获取指定范围内的位置
  /// 注意：这是模拟方法，真实应用中应查询 Firestore
  List<MapEntry<String, LocationData>> getLocationsInRange(
    LocationData center,
    double rangeKm,
  ) {
    return mockLocations.entries
        .where((entry) => isWithinRange(center, entry.value, rangeKm))
        .toList();
  }

  /// 格式化距离显示
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      // 小于1公里，显示米
      final meters = (distanceKm * 1000).round();
      return '$meters 米';
    } else if (distanceKm < 10) {
      // 1-10公里，保留1位小数
      return '${distanceKm.toStringAsFixed(1)} 公里';
    } else {
      // 大于10公里，取整
      return '${distanceKm.round()} 公里';
    }
  }

  /// 重置当前位置
  void resetLocation() {
    _currentLocation = null;
  }
}

/*
  未来真实 GPS 集成示例：

  添加依赖到 pubspec.yaml:
  dependencies:
    geolocator: ^10.1.0
    geocoding: ^2.1.1

  然后修改 getCurrentLocation():

  Future<LocationData> getCurrentLocation() async {
    // 检查权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置权限被拒绝');
      }
    }

    // 获取当前位置
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 反向地址解析
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final placemark = placemarks.first;
    final addressName = placemark.name ?? placemark.street ?? '未知地址';
    final city = placemark.locality ?? placemark.administrativeArea ?? '未知城市';

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      addressName: addressName,
      city: city,
      timestamp: DateTime.now(),
    );
  }
*/
