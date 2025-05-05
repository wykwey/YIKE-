import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../data/timetable.dart';
import '../utils/color_utils.dart';
import 'dart:convert';

class ImportTimetableDialog extends StatelessWidget {
  const ImportTimetableDialog({super.key});

  Future<void> _importTimetable(BuildContext context) async {
    final state = Provider.of<ScheduleState>(context, listen: false);
    try {
      // 1. 选择文件 (支持多平台)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // 2. 读取文件内容
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);
        
        // 3. 解析JSON数据
        final jsonData = jsonDecode(content);
        List<Timetable> timetables = [];

        if (jsonData is List) {
          // 多课表导入
          timetables = jsonData.map((e) {
            final timetable = Timetable.fromJson(e as Map<String, dynamic>);
            // 为每个课程设置随机颜色
            timetable.courses.forEach((course) {
              if (e['color'] is String && ColorUtils.courseColorMap.containsKey(e['color'])) {
                course.color = ColorUtils.courseColorMap[e['color']]!.value;
              } else if (course.color == 0) {
                course.color = ColorUtils.getRandomColor(course.name).value;
              }
            });
            return timetable;
          }).toList();
        } else if (jsonData is Map) {
          // 单课表导入
          final timetable = Timetable.fromJson(jsonData as Map<String, dynamic>);
          // 为每个课程设置随机颜色
            timetable.courses.forEach((course) {
              course.color = ColorUtils.getRandomColor(course.name).value;
            });
          timetables = [timetable];
        }

        // 4. 添加到现有课表
          for (var timetable in timetables) {
            // 检查并处理重复ID
            var newTimetable = timetable;
            while (state.timetables.any((t) => t.id == newTimetable.id)) {
              newTimetable = newTimetable.copyWith(
                id: '${newTimetable.id}-${DateTime.now().millisecondsSinceEpoch}'
              );
            }
            await state.addTimetable(newTimetable);
          }

        // 5. 显示成功提示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功导入${timetables.length}个课表')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入课表'),
      content: const Text('请选择包含课表数据的JSON文件'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _importTimetable(context);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('导入'),
        ),
      ],
    );
  }
}