import 'package:flutter/material.dart';
import '../data/courses.dart';

class CourseEditDialog extends StatelessWidget {
  final Course course;
  final Function(Course) onSave;

  const CourseEditDialog({
    super.key,
    required this.course,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: course.name);
    final teacherController = TextEditingController(text: course.teacher);
    final locationController = TextEditingController(text: course.location);

    return AlertDialog(
      title: const Text('编辑课程'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '课程名称'),
            ),
            TextField(
              controller: teacherController,
              decoration: const InputDecoration(labelText: '教师'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: '地点'),
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
          onPressed: () {
            final updatedCourse = Course(
              nameController.text,
              teacherController.text,
              locationController.text,
              course.schedules,
            );
            onSave(updatedCourse);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
