/*
  文件：utils/chart_utils.dart
  说明：
  - 图表相关工具函数
  - 提取自 health_tracker.dart 的复杂逻辑
  - 统一的图表计算方法

  使用示例：
  ```dart
  // 计算 Y 轴间隔
  List<double> weights = [29.0, 29.2, 30.1, 29.8];
  double interval = ChartUtils.calculateYAxisInterval(weights);
  // 返回: 0.5 (自动计算合适的刻度间隔)

  // 计算 Y 轴范围
  var (minY, maxY) = ChartUtils.calculateYAxisBounds(weights);
  // 返回: (28.0, 31.0)

  // 计算合适的刻度数量
  int count = ChartUtils.calculateOptimalTickCount([1, 5, 10, 15]);
  // 返回: 4 或 5
  ```

  替换位置：
  - health_tracker.dart - Y 轴间隔计算 (lines 195-221)
*/

/// 图表相关工具类
///
/// 提供图表绘制时的计算方法
/// 主要用于 fl_chart 等图表库的配置
class ChartUtils {
  /// 计算 Y 轴间隔
  ///
  /// 根据数据范围自动计算合适的 Y 轴刻度间隔
  /// 算法会选择最接近的"美观"数值（0.5, 1, 2, 5, 10, ...）
  ///
  /// 参数：
  /// - values: 数据值列表
  /// - targetIntervals: 目标刻度数量（默认 4，即尝试生成 4-5 个刻度）
  ///
  /// 返回：合适的刻度间隔值
  ///
  /// 算法逻辑：
  /// 1. 计算数据范围（最大值 - 最小值）
  /// 2. 粗略间隔 = 范围 / 目标刻度数
  /// 3. 将粗略间隔舍入到最接近的"美观"数值
  ///
  /// 示例：
  /// ```dart
  /// // 数据范围 29.0-30.1，范围 1.1
  /// calculateYAxisInterval([29.0, 29.2, 30.1, 29.8]) // 返回 0.5
  ///
  /// // 数据范围 10-50，范围 40
  /// calculateYAxisInterval([10, 25, 35, 50]) // 返回 10
  ///
  /// // 数据范围 100-500，范围 400
  /// calculateYAxisInterval([100, 250, 400, 500]) // 返回 100
  /// ```
  static double calculateYAxisInterval(
    List<double> values, {
    int targetIntervals = 4,
  }) {
    if (values.isEmpty) return 1.0;

    // 找出最小值和最大值
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // 计算数据范围
    final range = maxValue - minValue;

    // 粗略间隔 = 范围 / 目标刻度数
    final rawInterval = range / targetIntervals;

    // 将间隔舍入到"美观"的数值
    if (rawInterval <= 0.5) {
      return 0.5;
    } else if (rawInterval <= 1) {
      return 1;
    } else if (rawInterval <= 2) {
      return 2;
    } else if (rawInterval <= 5) {
      return 5;
    } else if (rawInterval <= 10) {
      return 10;
    } else {
      // 对于更大的数值，舍入到 10 的倍数
      return (rawInterval / 10).ceil() * 10.0;
    }
  }

  /// 计算 Y 轴的最小值和最大值
  ///
  /// 在数据范围基础上添加缓冲空间，使图表更美观
  ///
  /// 参数：
  /// - values: 数据值列表
  /// - paddingFactor: 缓冲系数（默认 1.0，即上下各加 1 个单位）
  ///
  /// 返回：(minY, maxY) 元组
  ///
  /// 算法：
  /// - minY = floor(最小值 - paddingFactor)
  /// - maxY = ceil(最大值 + paddingFactor)
  ///
  /// 示例：
  /// ```dart
  /// calculateYAxisBounds([29.0, 29.2, 30.1, 29.8])
  /// // 返回 (28.0, 31.0)
  ///
  /// calculateYAxisBounds([10, 20, 30], paddingFactor: 5)
  /// // 返回 (5.0, 35.0)
  /// ```
  static (double min, double max) calculateYAxisBounds(
    List<double> values, {
    double paddingFactor = 1.0,
  }) {
    if (values.isEmpty) return (0.0, 10.0);

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final minY = (minValue - paddingFactor).floorToDouble();
    final maxY = (maxValue + paddingFactor).ceilToDouble();

    return (minY, maxY);
  }

  /// 计算最优刻度数量
  ///
  /// 根据数据范围推荐合适的刻度数量
  ///
  /// 参数：
  /// - values: 数据值列表
  ///
  /// 返回：推荐的刻度数量（3-6 之间）
  ///
  /// 算法：
  /// - 范围 < 5: 3 个刻度
  /// - 范围 5-20: 4 个刻度
  /// - 范围 20-50: 5 个刻度
  /// - 范围 > 50: 6 个刻度
  ///
  /// 示例：
  /// ```dart
  /// calculateOptimalTickCount([1, 2, 3]) // 返回 3
  /// calculateOptimalTickCount([10, 20, 30]) // 返回 4
  /// calculateOptimalTickCount([10, 50, 90]) // 返回 5
  /// ```
  static int calculateOptimalTickCount(List<double> values) {
    if (values.isEmpty) return 4;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range < 5) {
      return 3;
    } else if (range < 20) {
      return 4;
    } else if (range < 50) {
      return 5;
    } else {
      return 6;
    }
  }

  /// 格式化数值为字符串（用于图表标签）
  ///
  /// 参数：
  /// - value: 数值
  /// - decimalPlaces: 小数位数（默认 1）
  ///
  /// 返回：格式化后的字符串
  ///
  /// 示例：
  /// ```dart
  /// formatValue(29.12345) // 返回 "29.1"
  /// formatValue(30.0) // 返回 "30.0"
  /// formatValue(29.12345, decimalPlaces: 2) // 返回 "29.12"
  /// ```
  static String formatValue(double value, {int decimalPlaces = 1}) {
    return value.toStringAsFixed(decimalPlaces);
  }
}
