import 'package:flutter/material.dart';
import '../data/course.dart';
import '../utils/color_utils.dart';

class CourseEditDialog extends StatefulWidget {
  final Course course;
  final Future<bool> Function(Course) onSave;
  final VoidCallback? onCancel;

  const CourseEditDialog({
    super.key,
    required this.course,
    required this.onSave,
    this.onCancel,
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
  late List<TextEditingController> _weekPatternControllers;
  late List<TextEditingController> _periodsControllers;

  @override
  void initState() {
    super.initState();
    _editingCourse = widget.course.copyWith();
    _nameController = TextEditingController(text: _editingCourse.name);
    _locationController = TextEditingController(text: _editingCourse.location);
    _teacherController = TextEditingController(text: _editingCourse.teacher);
    _selectedColor = ColorUtils.getCourseColor(_editingCourse.name);

    _weekPatternControllers = _editingCourse.schedules.map((schedule) {
      return TextEditingController(text: schedule['weekPattern'] ?? '');
    }).toList();

    _periodsControllers = _editingCourse.schedules.map((schedule) {
      final periods = (schedule['periods'] as List<int>);
      if (periods.isEmpty) return TextEditingController();
      
      // 将连续数字合并为范围
      final ranges = <String>[];
      int? start;
      int? prev;
      
      for (final period in periods..sort()) {
        if (start == null) {
          start = prev = period;
        } else if (period == prev! + 1) {
          prev = period;
        } else {
          ranges.add(start == prev ? '$start' : '$start-$prev');
          start = prev = period;
        }
      }
      if (start != null) {
        ranges.add(start == prev ? '$start' : '$start-$prev');
      }
      
      return TextEditingController(text: ranges.join(','));
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _editingCourse.name.isEmpty ? '添加课程' : '编辑课程',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sectionTitle('课程基本信息'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('课程名称', Icons.book),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('上课地点', Icons.location_on),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _teacherController,
              decoration: _inputDecoration('授课教师', Icons.person),
            ),
            _sectionTitle('课程时间信息'),
            ..._editingCourse.schedules.asMap().entries.map((entry) {
              final index = entry.key;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '星期',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _editingCourse.schedules[index]['day'],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        items: List.generate(7, (i) => i + 1).map((day) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text('星期${['一','二','三','四','五','六','日'][day - 1]}'),
                          );
                        }).toList(),
                        onChanged: (day) {
                          if (day == null) return;
                          setState(() {
                            _editingCourse.schedules[index]['day'] = day;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '节次',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _periodsControllers[index],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (value) {
                          try {
                            final periods = Course.parsePeriods(value);
                            if (periods.isNotEmpty) {
                              _editingCourse.schedules[index]['periods'] = List<int>.from(periods);
                            }
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '周数',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weekPatternControllers[index],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (value) {
                          _editingCourse.schedules[index]['weekPattern'] = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _editingCourse.schedules.removeAt(index);
                              _weekPatternControllers.removeAt(index);
                              _periodsControllers.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _editingCourse.schedules.add({
                    'day': 1,
                    'periods': [1],
                    'weekPattern': '1-16',
                  });
                  _weekPatternControllers.add(TextEditingController(text: '1-16'));
                  _periodsControllers.add(TextEditingController(text: '1'));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('添加时间安排'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            _sectionTitle('课程显示设置'),
            Wrap(
              spacing: 10,
              children: ColorUtils.courseColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            }
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        ElevatedButton(
          child: const Text('保存'),
          onPressed: () async {
            final course = _editingCourse.copyWith(
              name: _nameController.text,
              location: _locationController.text,
              teacher: _teacherController.text,
              color: _selectedColor.value,
              schedules: _editingCourse.schedules.map((schedule) {
                final index = _editingCourse.schedules.indexOf(schedule);
                return {
                  'day': schedule['day'],
                  'periods': schedule['periods'],
                  'weekPattern': _weekPatternControllers[index].text,
                };
              }).toList(),
            );
            final saved = await widget.onSave(course);
            if (saved == true && Navigator.canPop(context)) {
              Navigator.pop(context, course);
            }
          },
        ),
      ],
    );
  }
}
