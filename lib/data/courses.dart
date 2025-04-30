class Course {
  final String name;
  final String teacher;
  final String location;
  final List<Map<String, dynamic>> schedules;

  const Course(this.name, this.teacher, this.location, this.schedules);

  factory Course.empty() => const Course('', '', '', []);

  bool get isEmpty => name.isEmpty;

  // 获取课程所有节数的描述
  String get allPeriodsDescription {
    if (schedules.isEmpty) return "无安排";
    return schedules.map((schedule) => 
      "${weekDays[schedule['day']-1]}第${schedule['periods'].join('-')}节"
    ).join("，");
  }

  // 获取课程所有周次的描述
  String get allWeeksDescription {
    if (schedules.isEmpty) return "无安排";
    return schedules.map((schedule) => 
      "${weekDays[schedule['day']-1]}(${schedule['weekPattern']})"
    ).join("，");
  }

  bool isInWeek(int week, int day, int period) {
    return schedules.any((schedule) {
      // 检查星期和节数是否匹配
      if (schedule['day'] != day || !schedule['periods'].contains(period)) {
        return false;
      }
      return matchesWeekPattern(week, schedule['weekPattern']);
    });
  }

  static bool matchesWeekPattern(int week, String pattern) {
    if (pattern == 'all') return true;
    
    // 处理连续周数范围 (如"1-16")和单周数(如"1,3,5")
    for (var part in pattern.split(',')) {
      part = part.trim();
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.parse(range[0].trim());
        final end = int.parse(range[1].trim());
        if (week >= start && week <= end) return true;
      } else if (int.tryParse(part) == week) {
        return true;
      }
    }
    return false;
  }
}

final List<Course> allCourses = [
  const Course('数学', '张老师', 'A101', [
    {'day': 1, 'periods': [1,3], 'weekPattern': '1,3,5'},
    {'day': 3, 'periods': [3], 'weekPattern': '2,4,6'}
  ]),
  const Course('英语', '李老师', 'B201', [
    {'day': 2, 'periods': [2], 'weekPattern': '2,3'},
    {'day': 4, 'periods': [3, 4], 'weekPattern': '1-8'}
  ]),
  const Course('物理', '刘老师', 'C301', [
    {'day': 2, 'periods': [1], 'weekPattern': '1,3,5'},
    {'day': 4, 'periods': [2], 'weekPattern': '2,4,6'}
  ]),
  const Course('化学', '王老师', 'D401', [
    {'day': 1, 'periods': [3], 'weekPattern': '1-16'}
  ]),
  const Course('生物', '赵老师', 'E501', [
    {'day': 5, 'periods': [4,5], 'weekPattern': '1,3,5,7'}
  ]),
  const Course('计算机基础', '王老师', 'F601', [
    {'day': 1, 'periods': [1], 'weekPattern': '2,4,6'}
  ]),
  const Course('体育', '孙老师', '运动场', [
    {'day': 5, 'periods': [5], 'weekPattern': '1,3,5'}
  ])
];

final List<String> weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
