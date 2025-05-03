import 'package:flutter/material.dart';
import './edu_login_webview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../data/timetable.dart';
import '../utils/color_utils.dart';
import 'dart:convert';

class ImportTimetableDialog extends StatelessWidget {
  const ImportTimetableDialog({super.key});

  Future<void> _importFileTimetable(BuildContext context) async {
    final state = Provider.of<ScheduleState>(context, listen: false);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);
        final jsonData = jsonDecode(content);
        List<Timetable> timetables = [];

        if (jsonData is List) {
          timetables = jsonData.map((e) => Timetable.fromJson(e as Map<String, dynamic>)).toList();
        } else if (jsonData is Map) {
          timetables = [Timetable.fromJson(jsonData as Map<String, dynamic>)];
        }

        for (var timetable in timetables) {
          await state.addTimetable(timetable);
        }

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功导入${timetables.length}个课表')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('选择导入方式:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EduLoginWebView(
                        schoolUrl: 'https://one.hnzj.edu.cn/common-service/kcb-pc/class/schedule',
                      ),
                    ),
                  );
                },
                child: const Text('教务系统导入'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _importFileTimetable(context);
                },
                child: const Text('文件导入'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
