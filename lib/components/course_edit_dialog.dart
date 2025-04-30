import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../states/schedule_state.dart';
import '../utils/color_utils.dart';

class CourseEditDialog extends StatefulWidget {
  final Course course;
  final Function(Course) onSave;

  const CourseEditDialog({
    super.key,
    required this.course,
    required this.onSave,
  });

  @override
  State<CourseEditDialog> createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<CourseEditDialog> {
  late Course _editingCourse;
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _teacherController;
  late Color _selectedColor;
  late List<TextEditingController> _weekPatternControllers = [];
  late List<TextEditingController> _periodsControllers = [];

  @override
  void initState() {
    super.initState();
    _editingCourse = widget.course.copyWith();
    _nameController = TextEditingController(text: _editingCourse.name);
    _locationController = TextEditingController(text: _editingCourse.location);
    _teacherController = TextEditingController(text: _editingCourse.teacher);
    _selectedColor = ColorUtils.getCourseColor(_editingCourse.name);
    
    // 初始化控制器
    _weekPatternControllers = _editingCourse.schedules.map((schedule) {
      return TextEditingController(text: schedule['weekPattern'] ?? '');
    }).toList();
    
    _periodsControllers = _editingCourse.schedules.map((schedule) {
      return TextEditingController(text: (schedule['periods'] as List).join('-'));
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _teacherController.dispose();
    for (var controller in _weekPatternControllers) {
      controller.dispose();
    }
    for (var controller in _periodsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editingCourse.name.isEmpty ? '添加课程' : '编辑课程'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('课程基本信息', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '课程名称'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '上课地点'),
            ),
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(labelText: '授课教师'),
            ),
            const SizedBox(height: 16),
            const Text('课程时间信息', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._editingCourse.schedules.asMap().entries.map((entry) {
              final index = entry.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: _editingCourse.schedules[index]['day'],
                          items: List.generate(7, (i) => i+1).map((day) => 
                            DropdownMenuItem(
                              value: day,
                              child: Text('星期${['一','二','三','四','五','六','日'][day-1]}'),
                            )).toList(),
                          onChanged: (day) {
                            if (day == null) return;
                            setState(() {
                              _editingCourse.schedules[index]['day'] = day;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _editingCourse.schedules.removeAt(index);
                            _weekPatternControllers.removeAt(index);
                            _periodsControllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '节次 (如:1-3)'),
                    controller: _periodsControllers[index],
                    onChanged: (value) {
                      try {
                        final periods = value.split('-')
                          .where((e) => e.isNotEmpty)
                          .map((e) => int.tryParse(e))
                          .where((e) => e != null)
                          .map((e) => e!)
                          .toList();
                        if (periods.isNotEmpty) {
                          _editingCourse.schedules[index]['periods'] = periods;
                        }
                      } catch (e) {
                        // 忽略格式错误
                      }
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: '周数 (如:1-16或1,3,5)'),
                    controller: _weekPatternControllers[index],
                    textDirection: TextDirection.ltr,
                    onChanged: (value) {
                      _editingCourse.schedules[index]['weekPattern'] = value;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _editingCourse.schedules.add({
                    'day': 1,
                    'periods': [1],
                    'weekPattern': '1-16'
                  });
                  _weekPatternControllers.add(TextEditingController(text: '1-16'));
                  _periodsControllers.add(TextEditingController(text: '1'));
                });
              },
              child: const Text('添加时间安排'),
            ),
            const SizedBox(height: 16),
            const Text('课程显示设置', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<Color>(
              value: _selectedColor,
              items: ColorUtils.courseColors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Container(
                    width: 100,
                    height: 20,
                    color: color,
                  ),
                );
              }).toList(),
              onChanged: (color) {
                if (color != null) {
                  setState(() {
                    _selectedColor = color;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            final updatedCourse = _editingCourse.copyWith(
              name: _nameController.text,
              location: _locationController.text,
              teacher: _teacherController.text,
              color: _selectedColor.value,
            );
            try {
              await widget.onSave(updatedCourse);
              if (mounted) Navigator.pop(context, updatedCourse);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()))
                );
              }
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
