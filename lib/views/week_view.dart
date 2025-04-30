import 'package:flutter/material.dart';
import '../data/courses.dart';
import '../data/settings.dart';
import '../services/course_service.dart';
import '../utils/color_utils.dart';

class WeekView extends StatelessWidget {
  final int currentWeek;
  final int maxPeriods;
  final List<Course> Function(int) getWeekCourses;
  final bool showWeekend;

  final Function(Course)? onCourseTap;

  const WeekView({
    super.key,
    required this.currentWeek,
    required this.maxPeriods,
    required this.getWeekCourses,
    this.showWeekend = false,
    this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    List<Course> currentCourses = getWeekCourses(currentWeek);

    return LayoutBuilder(
      builder: (context, constraints) {
        double minHeight = 80.0;
        double maxHeight = 120.0;
        double calculatedHeight = constraints.maxWidth / 8;
        double cellHeight = calculatedHeight.clamp(minHeight, maxHeight);

        double totalContentHeight = cellHeight * maxPeriods;

        if (totalContentHeight < constraints.maxHeight) {
          cellHeight = constraints.maxHeight / maxPeriods;
        }

        return SingleChildScrollView(
          child: Column(
            children: List.generate(maxPeriods, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                height: cellHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 70,
                      child: _buildPeriodLabel(context, index + 1),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(showWeekend ? 7 : 5, (dayIndex) {
                          int day = dayIndex + 1;
          var course = CourseService.getPeriodCourse(
            currentWeek,
            day,
            index + 1,
            currentCourses
          );
                          return Expanded(child: _buildCourseCell(course, onCourseTap));
                        }),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPeriodLabel(BuildContext context, int period) {
    final timeText = AppSettings.periodTimes[period.toString()] ?? '未知时间';
    final times = timeText.split('-');
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('第$period节', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: Theme.of(context).primaryColorDark
              )),
          const SizedBox(height: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(times[0], 
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor
                  )),
              Text('——', 
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold
                  )),
              Text(times.length > 1 ? times[1] : '', 
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCell(Course course, Function(Course)? onTap) {
    if (course.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
      );
    }

    Color borderColor = _getCourseColor(course.name);

    return GestureDetector(
      onTap: () {
        if (onTap != null && !course.isEmpty) {
          onTap!(course);
        }
      },
      child: Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(course.teacher, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(course.location, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    ),
    );
  }

  Color _getCourseColor(String name) {
    return ColorUtils.getCourseColor(name);
  }
}
