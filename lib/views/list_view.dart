import 'package:flutter/material.dart';
import '../data/courses.dart';

class CourseListView extends StatelessWidget {
  final int currentWeek;
  final List<Course> Function(int) getWeekCourses;

  const CourseListView({
    super.key,
    required this.currentWeek,
    required this.getWeekCourses,
  });

  @override
  Widget build(BuildContext context) {
    final courses = getWeekCourses(currentWeek);
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
              child: Text('第$week周',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: weekCourses.length,
                itemBuilder: (context, index) {
                  final course = weekCourses[index];
                  final borderColor = _getCourseColor(course.name);
                  final schedulesText = course.schedules.map((s) {
                    final dayText = weekDays[s['day'] - 1];
                    return '$dayText 第${s['periods'].join('-')}节';
                  }).join('\n');

                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getWeekColor(course.schedules.first['weekPattern']),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                schedulesText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '教师: ${course.teacher}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '地点: ${course.location}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
          map.putIfAbsent(0, () => []).add(course);
        } else {
          for (final week in schedule['weekPattern'].split(',')) {
            final weekNum = int.tryParse(week) ?? 0;
            map.putIfAbsent(weekNum, () => []).add(course);
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
