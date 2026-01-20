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

  v3.0 - 使用 AppDialog 和通用组件重构
*/

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/types.dart';
import '../utils/date_picker_helper.dart';
import '../utils/snackbar_helper.dart';
import '../core/theme/app_input_decoration.dart';
import 'common/app_dialog.dart';
import 'common/form_field_label.dart';
import 'common/date_picker_field.dart';

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

  // 日期格式化器（图表显示格式）
  final DateFormat _displayFormatter = DateFormat('MMM');

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
      return ('+${change.toStringAsFixed(1)} kg 📈', AppColors.success);
    } else if (change < 0) {
      // 减重
      return ('${change.toStringAsFixed(1)} kg 📉', AppColors.primaryOrange);
    } else {
      // 无变化
      return ('保持稳定 ➡️', AppColors.info);
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
      SnackBarHelper.showInfo(context, '体重记录已添加！当前 ${weight.toStringAsFixed(1)} kg');
    }
  }

  /// 构建体重变化提示组件
  Widget? _buildWeightChangeIndicator() {
    final changeInfo = _getWeightChangeInfo();
    if (changeInfo == null) return null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: changeInfo.$2.withValues(alpha: 0.1),
        borderRadius: AppRadius.allMD,
        border: Border.all(
          color: changeInfo.$2.withValues(alpha: 0.3),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final changeIndicator = _buildWeightChangeIndicator();

    return AppDialog(
      icon: LucideIcons.scale,
      iconColor: AppColors.info,
      title: '添加体重记录',
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 体重输入框
            const FormFieldLabel(label: '体重 (kg)', required: true),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
              ],
              onChanged: (value) {
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

                if (weight < 0.1 || weight > 200) {
                  return '体重范围应在 0.1 - 200 kg 之间';
                }

                return null;
              },
              decoration: AppInputDecoration.compact(
                labelText: '体重',
                hintText: '例如：29.5',
                prefixIcon: LucideIcons.scale,
              ).copyWith(
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                ),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 体重变化提示（如果有历史数据）
            if (changeIndicator != null) ...[
              const SizedBox(height: 12),
              changeIndicator,
            ],

            const SizedBox(height: 16),

            // 日期选择器
            DatePickerField(
              label: '记录日期',
              date: _recordDate,
              icon: LucideIcons.calendar,
              iconColor: AppColors.info,
              onTap: _selectDate,
            ),
          ],
        ),
      ),
      actions: [
        AppDialog.cancelButton(context),
        AppDialog.confirmButton(
          context,
          onPressed: _saveWeight,
          label: '保存',
          color: AppColors.info,
        ),
      ],
    );
  }
}
