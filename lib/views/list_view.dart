import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../main.dart';
import '../constants.dart';

class CourseListView extends StatelessWidget {
  final List<Course> courses;

  const CourseListView({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    final groupedCourses = _groupCoursesByWeek(courses);

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedCourses.length,
      itemBuilder: (context, weekIndex) {
        final week = groupedCourses.keys.elementAt(weekIndex);
        final weekCourses = groupedCourses[week]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                '第$week周',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 自动计算列数，最小宽度为 200
                  final itemMinWidth = 200.0;
                  final crossAxisCount = (constraints.maxWidth / itemMinWidth).floor().clamp(1, 6);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: weekCourses.length,
                    itemBuilder: (context, index) {
                      final course = weekCourses[index];
                      final borderColor = _getCourseColor(course.name);
                      final schedulesText = course.schedules.map((s) {
                        final dayText = AppConstants.weekDays[s['day'] - 1];
                        return '$dayText 第${s['periods'].join(',')}节';
                      }).join('\n');

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getWeekColor(course.schedules.first['weekPattern']),
                          borderRadius: BorderRadius.circular(10),
                          border: Border(left: BorderSide(color: borderColor, width: 4)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              schedulesText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '教师: ${course.teacher}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '地点: ${course.location}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Map<int, List<Course>> _groupCoursesByWeek(List<Course> courses) {
    final map = <int, List<Course>>{};
    for (final course in courses) {
      for (final schedule in course.schedules) {
        if (schedule['weekPattern'] == 'all') {
          // 全周课程添加到所有周
          for (int week = 1; week <= 20; week++) {
            map.putIfAbsent(week, () => []).add(course);
          }
        } else {
          // 特定周课程
          // 处理连续周数范围 (如"1-16")和单周数(如"1,3,5")
          for (var part in schedule['weekPattern'].split(',')) {
            part = part.trim();
            if (part.contains('-')) {
              final range = part.split('-');
              final start = int.parse(range[0].trim());
              final end = int.parse(range[1].trim());
              for (int week = start; week <= end; week++) {
                map.putIfAbsent(week, () => []).add(course);
              }
            } else {
              final weekNum = int.tryParse(part) ?? 0;
              if (weekNum > 0) {
                map.putIfAbsent(weekNum, () => []).add(course);
              }
            }
          }
        }
      }
    }
    return map;
  }

  Color _getCourseColor(String name) {
    final colors = [Colors.orange, Colors.green, Colors.blue, Colors.purple, Colors.red, Colors.teal];
    return colors[name.hashCode % colors.length];
  }

  Color _getWeekColor(String weekPattern) {
    if (weekPattern == 'all') return Colors.white;
    final week = int.tryParse(weekPattern.split(',').first) ?? 1;
    return week % 2 == 0 ? Colors.grey[100]! : Colors.white;
  }
}
