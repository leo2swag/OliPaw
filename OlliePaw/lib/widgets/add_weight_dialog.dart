/*
  文件：widgets/add_weight_dialog.dart
  说明：
  - 添加体重记录的对话框组件
  - 功能：
    1) 输入体重数值（支持小数）
    2) 选择记录日期
    3) 显示体重变化趋势提示
    4) 表单验证（范围检查）
  - 使用方式：通过 showAddWeightDialog 调用
  注意：体重单位为 kg，支持 0.1 kg 精度
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/types.dart';
import '../utils/date_picker_helper.dart';
import '../core/theme/app_input_decoration.dart';

/// 显示添加体重记录对话框
///
/// 参数：
/// - context: 构建上下文
/// - lastWeight: 上一次记录的体重（用于显示变化趋势）
/// - onWeightAdded: 体重添加成功后的回调函数
///
/// 返回值：新创建的 WeightRecord 对象（如果用户取消则返回 null）
Future<WeightRecord?> showAddWeightDialog({
  required BuildContext context,
  double? lastWeight,
  required Function(WeightRecord) onWeightAdded,
}) async {
  return showDialog<WeightRecord>(
    context: context,
    builder: (context) => AddWeightDialog(lastWeight: lastWeight),
  ).then((record) {
    if (record != null) {
      onWeightAdded(record);
    }
    return record;
  });
}

/// 添加体重记录对话框主组件
class AddWeightDialog extends StatefulWidget {
  final double? lastWeight; // 上一次体重记录

  const AddWeightDialog({super.key, this.lastWeight});

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  // 表单 Key
  final _formKey = GlobalKey<FormState>();

  // 体重输入控制器
  final _weightController = TextEditingController();

  // 记录日期
  DateTime _recordDate = DateTime.now();

  // 日期格式化器（简化格式用于显示）
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormatter = DateFormat('MMM'); // 图表显示格式

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// 选择记录日期
  /// 说明：打开日期选择器，限制不能选择未来日期
  Future<void> _selectDate() async {
    final DateTime? picked = await DatePickerHelper.showBlue(
      context,
      initialDate: _recordDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 最多回溯 2 年
      lastDate: DateTime.now(), // 不能选择未来
    );

    if (picked != null && picked != _recordDate) {
      setState(() {
        _recordDate = picked;
      });
    }
  }

  /// 计算体重变化
  /// 返回值：
  /// - 正数表示增重
  /// - 负数表示减重
  /// - null 表示没有历史数据
  double? _getWeightChange() {
    if (widget.lastWeight == null || _weightController.text.isEmpty) {
      return null;
    }

    final currentWeight = double.tryParse(_weightController.text);
    if (currentWeight == null) return null;

    return currentWeight - widget.lastWeight!;
  }

  /// 获取体重变化提示文本和颜色
  /// 说明：根据体重变化幅度给出不同的提示和颜色
  (String, Color)? _getWeightChangeInfo() {
    final change = _getWeightChange();
    if (change == null) return null;

    if (change > 0) {
      // 增重
      return ('+${change.toStringAsFixed(1)} kg 📈', Colors.green);
    } else if (change < 0) {
      // 减重
      return ('${change.toStringAsFixed(1)} kg 📉', Colors.orange);
    } else {
      // 无变化
      return ('保持稳定 ➡️', Colors.blue);
    }
  }

  /// 保存体重记录
  /// 说明：
  /// - 验证表单
  /// - 创建 WeightRecord 对象
  /// - 返回给调用者
  void _saveWeight() {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);

      // 创建新的体重记录对象
      final record = WeightRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 生成唯一 ID
        date: _displayFormatter.format(_recordDate), // 使用简化日期格式
        weight: weight,
      );

      // 返回结果并关闭对话框
      Navigator.of(context).pop(record);

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('体重记录已添加！当前 ${weight.toStringAsFixed(1)} kg'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeInfo = _getWeightChangeInfo();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.scale,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '添加体重记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 体重输入框
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '体重 (kg)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 体重数值输入
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      // 只允许数字和小数点
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                    ],
                    onChanged: (value) {
                      // 实时更新体重变化提示
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入体重';
                      }

                      final weight = double.tryParse(value);
                      if (weight == null) {
                        return '请输入有效的数字';
                      }

                      // 合理范围检查（0.1 kg ~ 200 kg）
                      if (weight < 0.1 || weight > 200) {
                        return '体重范围应在 0.1 - 200 kg 之间';
                      }

                      return null;
                    },
                    decoration: AppInputDecoration.compact(
                      labelText: 'Weight',
                      hintText: '例如：29.5',
                      prefixIcon: LucideIcons.scale,
                    ).copyWith(
                      suffixText: 'kg',
                      suffixStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // 体重变化提示（如果有历史数据）
              if (changeInfo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: changeInfo.$2.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: changeInfo.$2.withValues(alpha:0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        size: 16,
                        color: changeInfo.$2,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '相比上次: ${changeInfo.$1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: changeInfo.$2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 日期选择器
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '记录日期',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 20, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            _dateFormatter.format(_recordDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 底部按钮组
              Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 保存按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveWeight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
