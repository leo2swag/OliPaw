/*
  文件：widgets/add_vaccine_dialog.dart
  说明：
  - 添加疫苗记录的对话框组件
  - 功能：
    1) 输入疫苗名称
    2) 选择接种日期
    3) 选择到期提醒日期
    4) 输入兽医信息
    5) 表单验证
  - 使用方式：通过 showAddVaccineDialog 调用
  注意：当前数据保存在本地状态，待集成后端后持久化到数据库

  v3.0 - 使用 AppDialog 和通用组件重构
*/

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/types.dart';
import '../utils/date_picker_helper.dart';
import '../utils/snackbar_helper.dart';
import '../core/theme/app_input_decoration.dart';
import 'common/app_dialog.dart';
import 'common/form_field_label.dart';
import 'common/date_picker_field.dart';

/// 显示添加疫苗记录对话框
///
/// 参数：
/// - context: 构建上下文
/// - onVaccineAdded: 疫苗添加成功后的回调函数
///
/// 返回值：新创建的 Vaccine 对象（如果用户取消则返回 null）
Future<Vaccine?> showAddVaccineDialog({
  required BuildContext context,
  required Function(Vaccine) onVaccineAdded,
}) async {
  return showDialog<Vaccine>(
    context: context,
    builder: (context) => const AddVaccineDialog(),
  ).then((vaccine) {
    if (vaccine != null) {
      onVaccineAdded(vaccine);
    }
    return vaccine;
  });
}

/// 添加疫苗记录对话框主组件
class AddVaccineDialog extends StatefulWidget {
  const AddVaccineDialog({super.key});

  @override
  State<AddVaccineDialog> createState() => _AddVaccineDialogState();
}

class _AddVaccineDialogState extends State<AddVaccineDialog> {
  // 表单 Key，用于验证
  final _formKey = GlobalKey<FormState>();

  // 各字段的文本控制器
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();

  // 日期选择
  DateTime _administeredDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 365)); // 默认一年后

  // 日期格式化器
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    super.dispose();
  }

  /// 选择接种日期
  Future<void> _selectAdministeredDate() async {
    final DateTime? picked = await DatePickerHelper.showOrange(
      context,
      initialDate: _administeredDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _administeredDate) {
      setState(() {
        _administeredDate = picked;
        // 自动设置到期日期为一年后
        _dueDate = picked.add(const Duration(days: 365));
      });
    }
  }

  /// 选择到期提醒日期
  Future<void> _selectDueDate() async {
    final DateTime? picked = await DatePickerHelper.showTeal(
      context,
      initialDate: _dueDate,
      firstDate: _administeredDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  /// 保存疫苗记录
  void _saveVaccine() {
    if (_formKey.currentState!.validate()) {
      final vaccine = Vaccine(
        id: 'v${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        dateAdministered: _dateFormatter.format(_administeredDate),
        dueDate: _dateFormatter.format(_dueDate),
        veterinarian: _veterinarianController.text.trim(),
      );

      Navigator.of(context).pop(vaccine);
      SnackBarHelper.showSuccess(context, '疫苗记录已添加！ 💉');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: LucideIcons.syringe,
      iconColor: AppColors.success,
      title: '添加疫苗记录',
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 疫苗名称输入框
            const FormFieldLabel(label: '疫苗名称', required: true),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入疫苗名称';
                }
                return null;
              },
              decoration: AppInputDecoration.compact(
                labelText: '疫苗名称',
                hintText: '例如：狂犬病疫苗',
                prefixIcon: LucideIcons.fileText,
              ),
            ),
            const SizedBox(height: 16),

            // 接种日期选择器
            DatePickerField(
              label: '接种日期',
              date: _administeredDate,
              icon: LucideIcons.calendar,
              iconColor: AppColors.primaryOrange,
              onTap: _selectAdministeredDate,
            ),
            const SizedBox(height: 16),

            // 到期日期选择器
            DatePickerField(
              label: '下次接种日期',
              date: _dueDate,
              icon: LucideIcons.calendarClock,
              iconColor: AppColors.success,
              onTap: _selectDueDate,
            ),
            const SizedBox(height: 16),

            // 兽医信息输入框（可选）
            const FormFieldLabel(label: '兽医姓名（可选）'),
            TextFormField(
              controller: _veterinarianController,
              decoration: AppInputDecoration.compact(
                labelText: '兽医姓名',
                hintText: '例如：Dr. Smith',
                prefixIcon: LucideIcons.userCheck,
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppDialog.cancelButton(context),
        AppDialog.confirmButton(
          context,
          onPressed: _saveVaccine,
          label: '保存',
          color: AppColors.success,
        ),
      ],
    );
  }
}
