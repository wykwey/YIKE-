import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../constants.dart';
import '../utils/color_utils.dart';

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
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                '第$week周',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const itemMinWidth = 200.0;
                const itemMaxWidth = 240.0;
                final availableWidth = constraints.maxWidth - 16;
                final crossAxisCount = (availableWidth / itemMinWidth).floor().clamp(1, (availableWidth / itemMinWidth).floor());
                final itemWidth = (availableWidth / crossAxisCount).clamp(itemMinWidth, itemMaxWidth);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weekCourses.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.5,
                    mainAxisExtent: itemWidth / 1.5,
                  ),
                  itemBuilder: (context, index) {
                    return CourseCard(course: weekCourses[index]);
                  },
                );
              },
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
          for (int week = 1; week <= 20; week++) {
            map.putIfAbsent(week, () => []).add(course);
          }
        } else {
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
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colorBar = ColorUtils.getCourseColor(course.name);
    final bgColor = ColorUtils.getWeekColor(course.schedules.first['weekPattern']);
    final schedulesText = course.schedules.map((s) {
      final dayText = AppConstants.weekDays[s['day'] - 1];
      return '$dayText 第${s['periods'].join(',')}节';
    }).join('\n');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: colorBar,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  schedulesText,
                  style: const TextStyle(fontSize: 13, color: Colors.deepPurple),
                ),
                const SizedBox(height: 6),
                Text(
                  '教师: ${course.teacher}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  '地点: ${course.location}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
