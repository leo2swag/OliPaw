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
*/

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/types.dart';
import '../utils/date_picker_helper.dart';
import '../core/theme/app_input_decoration.dart';

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
  /// 说明：打开日期选择器，限制不能选择未来日期
  Future<void> _selectAdministeredDate() async {
    final DateTime? picked = await DatePickerHelper.showOrange(
      context,
      initialDate: _administeredDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // 不能选择未来日期
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
  /// 说明：打开日期选择器，限制必须在接种日期之后
  Future<void> _selectDueDate() async {
    final DateTime? picked = await DatePickerHelper.showTeal(
      context,
      initialDate: _dueDate,
      firstDate: _administeredDate, // 必须在接种日期之后
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 最多 10 年
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  /// 保存疫苗记录
  /// 说明：
  /// - 验证表单
  /// - 创建 Vaccine 对象
  /// - 返回给调用者
  void _saveVaccine() {
    if (_formKey.currentState!.validate()) {
      // 创建新的疫苗记录对象
      final vaccine = Vaccine(
        id: 'v${DateTime.now().millisecondsSinceEpoch}', // 临时 ID 生成
        name: _nameController.text.trim(),
        dateAdministered: _dateFormatter.format(_administeredDate),
        dueDate: _dateFormatter.format(_dueDate),
        veterinarian: _veterinarianController.text.trim(),
      );

      // 返回结果并关闭对话框
      Navigator.of(context).pop(vaccine);

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('疫苗记录已添加！ 💉'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.syringe,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '添加疫苗记录',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 疫苗名称输入框
                _buildTextField(
                  controller: _nameController,
                  label: '疫苗名称',
                  hint: '例如：狂犬病疫苗',
                  icon: LucideIcons.fileText,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入疫苗名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 接种日期选择器
                _buildDateField(
                  label: '接种日期',
                  date: _administeredDate,
                  icon: LucideIcons.calendar,
                  color: Colors.orange,
                  onTap: _selectAdministeredDate,
                ),
                const SizedBox(height: 16),

                // 到期日期选择器
                _buildDateField(
                  label: '下次接种日期',
                  date: _dueDate,
                  icon: LucideIcons.calendarClock,
                  color: Colors.teal,
                  onTap: _selectDueDate,
                ),
                const SizedBox(height: 16),

                // 兽医信息输入框（可选）
                _buildTextField(
                  controller: _veterinarianController,
                  label: '兽医姓名（可选）',
                  hint: '例如：Dr. Smith',
                  icon: LucideIcons.userCheck,
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
                        onPressed: _saveVaccine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
      ),
    );
  }

  /// 构建文本输入框
  /// 说明：统一的输入框样式，带图标和验证
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // 输入框
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: AppInputDecoration.compact(
            labelText: label,
            hintText: hint,
            prefixIcon: icon,
          ),
        ),
      ],
    );
  }

  /// 构建日期选择字段
  /// 说明：可点击打开日期选择器的字段
  Widget _buildDateField({
    required String label,
    required DateTime date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // 日期显示容器（可点击）
        InkWell(
          onTap: onTap,
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
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(
                  _dateFormatter.format(date),
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
    );
  }
}
