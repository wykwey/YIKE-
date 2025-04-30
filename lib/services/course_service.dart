import '../data/courses.dart';

class CourseService {
  /// 获取指定周数的课程列表
  static List<Course> getWeekCourses(int week, List<Course> allCourses) {
    return allCourses.where((course) {
      return course.schedules.any((schedule) {
        return Course.matchesWeekPattern(week, schedule['weekPattern']);
      });
    }).toList();
  }

  /// 获取指定周数和星期的课程
  static List<Course> getDayCourses(int week, int day, List<Course> allCourses) {
    return allCourses.where((course) {
      return course.schedules.any((s) => 
        s['day'] == day && 
        Course.matchesWeekPattern(week, s['weekPattern'])
      );
    }).toList();
  }

  /// 获取指定周数、星期和节次的课程
  static Course getPeriodCourse(int week, int day, int period, List<Course> allCourses) {
    return allCourses.firstWhere(
      (c) => c.schedules.any((s) => 
        s['day'] == day && 
        s['periods'].contains(period) &&
        Course.matchesWeekPattern(week, s['weekPattern'])),
      orElse: () => Course.empty(),
    );
  }
}
