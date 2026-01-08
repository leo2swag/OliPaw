/*
  文件：widgets/health_tracker.dart
  说明：
  - 健康追踪页签：展示 AI 健康提示、疫苗记录与体重历史图表。
  - 依赖 GeminiService 获取每日健康提示；使用 fl_chart 绘制折线图。
  注意：本文件仅添加中文注释，不改变逻辑。
*/
import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/types.dart';
import '../services/gemini_service.dart';
import 'add_vaccine_dialog.dart';
import 'add_weight_dialog.dart';

/// 健康追踪组件：展示宠物健康相关信息
class HealthTracker extends StatefulWidget {
  final Pet pet;
  const HealthTracker({super.key, required this.pet});

  @override
  State<HealthTracker> createState() => _HealthTrackerState();
}

class _HealthTrackerState extends State<HealthTracker> {
  /// 顶部 AI 提示文案与加载态
  String _tip = "Analyzing breed data...";
  bool _loading = true;
  final GeminiService _ai = GeminiService();

  /// 本地疫苗和体重记录列表（用于动态更新）
  late List<Vaccine> _vaccines;
  late List<WeightRecord> _weightHistory;

  @override
  /// 初始化时拉取 AI 健康提示并加载数据
  void initState() {
    super.initState();
    _vaccines = List.from(widget.pet.vaccines);
    _weightHistory = List.from(widget.pet.weightHistory);
    _fetchTip();
  }

  /// 异步获取健康提示（若无 Key 则返回默认占位）
  Future<void> _fetchTip() async {
    final tip = await _ai.analyzeHealthTip(widget.pet);
    if (mounted) setState(() { _tip = tip; _loading = false; });
  }

  /// 构建空状态视图
  /// 说明：当疫苗或体重记录为空时显示
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI 提示卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF10B981)]),
            borderRadius: AppRadius.allLG,
            boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.yellow, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dr. AI's Daily Tip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_loading ? "Thinking..." : _tip, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 疫苗记录标题和添加按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Vaccine Records", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            // 添加疫苗按钮
            ElevatedButton.icon(
              onPressed: () {
                showAddVaccineDialog(
                  context: context,
                  onVaccineAdded: (vaccine) {
                    setState(() {
                      _vaccines.add(vaccine);
                    });
                  },
                );
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('添加', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.allMD),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.allLG, border: Border.all(color: Colors.grey.shade100)),
          child: _vaccines.isEmpty
              ? _buildEmptyState('还没有疫苗记录', '点击上方按钮添加疫苗记录', LucideIcons.syringe)
              : Column(
                  children: _vaccines.map((v) => _VaccineRow(vaccine: v)).toList(),
                ),
        ),
        const SizedBox(height: 24),

        // 体重历史图表标题和添加按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Weight History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            // 添加体重按钮
            ElevatedButton.icon(
              onPressed: () {
                showAddWeightDialog(
                  context: context,
                  lastWeight: _weightHistory.isNotEmpty ? _weightHistory.last.weight : null,
                  onWeightAdded: (record) {
                    setState(() {
                      _weightHistory.add(record);
                    });
                  },
                );
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('记录', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.allMD),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.allLG, border: Border.all(color: Colors.grey.shade100)),
          child: _weightHistory.isEmpty
              ? _buildEmptyState('还没有体重记录', '点击上方按钮记录体重', LucideIcons.scale)
              : Builder(
                  builder: (context) {
                    // 计算智能 Y 轴间隔 - 确保最多显示 5 个标签
                    final minWeight = _weightHistory.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
                    final maxWeight = _weightHistory.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

                    final minY = (minWeight - 1).floorToDouble();
                    final maxY = (maxWeight + 1).ceilToDouble();
                    final range = maxY - minY;

                    // 计算间隔以确保最多 5 个标签
                    // 目标：range / interval <= 5，因此 interval >= range / 5
                    final rawInterval = range / 4; // 4 intervals = 5 labels (including min and max)

                    // 将间隔四舍五入到合理的值 (0.5, 1, 2, 5, 10, etc.)
                    double yInterval;
                    if (rawInterval <= 0.5) {
                      yInterval = 0.5;
                    } else if (rawInterval <= 1) {
                      yInterval = 1;
                    } else if (rawInterval <= 2) {
                      yInterval = 2;
                    } else if (rawInterval <= 5) {
                      yInterval = 5;
                    } else if (rawInterval <= 10) {
                      yInterval = 10;
                    } else {
                      yInterval = (rawInterval / 10).ceil() * 10.0;
                    }

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          // 隐藏右侧和顶部标签
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          // 底部显示月份标签
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < _weightHistory.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _weightHistory[index].date,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          // 左侧显示体重数值 - 智能间隔
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                // 只显示整数或半数（.5）
                                if (yInterval == 0.5) {
                                  return Text(
                                    '${value.toStringAsFixed(1)}kg',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    '${value.toInt()}kg',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                            left: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weightHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade400, Colors.amber.shade400],
                            ),
                            barWidth: 4,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: Colors.orange.shade600,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withValues(alpha: 0.3),
                                  Colors.amber.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// 疫苗记录行（私有）：名称、兽医与状态（是否过期）
class _VaccineRow extends StatelessWidget {
  final Vaccine vaccine;
  const _VaccineRow({required this.vaccine});

  @override
  /// 简易状态逻辑：当前日期晚于 dueDate 视为过期
  Widget build(BuildContext context) {
    // Simple mock logic for status
    final isOverdue = DateTime.now().isAfter(DateTime.parse(vaccine.dueDate));
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vaccine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Vet: ${vaccine.veterinarian}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: AppRadius.allSM,
              border: Border.all(color: isOverdue ? Colors.red.shade100 : Colors.green.shade100),
            ),
            child: Row(
              children: [
                Icon(isOverdue ? LucideIcons.alertTriangle : LucideIcons.checkCircle, size: 12, color: isOverdue ? Colors.red : Colors.green),
                const SizedBox(width: 4),
                Text(isOverdue ? "Overdue" : "Up to date", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.green)),
              ],
            ),
          )
        ],
      ),
    );
  }
}