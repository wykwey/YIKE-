import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PingFang',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CourseScheduleScreen(),
    );
  }
}

class CourseScheduleScreen extends StatefulWidget {
  const CourseScheduleScreen({super.key});

  @override
  State<CourseScheduleScreen> createState() => _CourseScheduleScreenState();
}

class _CourseScheduleScreenState extends State<CourseScheduleScreen> {
  int currentWeek = 1;
  String selectedView = '周视图';

  static const List<String> weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  final Map<int, List<Course>> weekCourses = {
    1: [
      const Course('数学', '张老师', '周一', '8:00 - 10:00', 'A101'),
      const Course('英语', '李老师', '周二', '10:00 - 12:00', 'B201'),
      const Course('物理', '刘老师', '周三', '14:00 - 16:00', 'C301'),
      const Course('化学', '王老师', '周四', '16:00 - 18:00', 'D401'),
      const Course('生物', '赵老师', '周五', '19:00 - 21:00', 'E501'),
    ],
    2: [
      const Course('计算机基础', '王老师', '周一', '8:00 - 10:00', 'F601'),
      const Course('物理', '刘老师', '周二', '10:00 - 12:00', 'C301'),
      const Course('高等数学', '张老师', '周三', '14:00 - 16:00', 'A101'),
      const Course('英语', '李老师', '周四', '16:00 - 18:00', 'B201'),
      const Course('体育', '孙老师', '周五', '19:00 - 21:00', '运动场'),
    ],
  };

  final List<String> timeSlots = [
    '8:00 - 10:00',
    '10:00 - 12:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '19:00 - 21:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (selectedView == '周视图') _buildWeekHeader(),
          Expanded(
            child: selectedView == '周视图'
                ? _buildWeekView()
                : _buildDayView(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('课程表', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
      actions: [
        _buildWeekNavigationButton(Icons.chevron_left, _prevWeek),
        Center(child: Text('第$currentWeek周', style: const TextStyle(fontSize: 16))),
        _buildWeekNavigationButton(Icons.chevron_right, _nextWeek),
        const SizedBox(width: 8),
        _buildViewSwitcher(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 70,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: const Text('时间', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Row(
              children: weekDays.map((day) {
                return Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    alignment: Alignment.center,
                    child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 修改 _buildWeekView() 方法
  Widget _buildWeekView() {
    List<Course> currentCourses = weekCourses[currentWeek] ?? [];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕尺寸计算合适的单元格高度
        double minHeight = 80.0; // 最小高度
        double calculatedHeight = constraints.maxWidth / 8;
        double cellHeight = calculatedHeight < minHeight ? minHeight : calculatedHeight;
        
        return ListView.builder(
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              height: cellHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 70,
                    child: _buildFixedTimeSlotColumn(timeSlots[index], index),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(7, (dayIndex) {
                        String day = weekDays[dayIndex];
                        Course course = currentCourses.firstWhere(
                          (c) => c.day == day && c.time == timeSlots[index],
                          orElse: () => Course.empty(),
                        );
                        return Expanded(child: _buildCourseCell(course));
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayView() {
    List<Course> currentCourses = weekCourses[currentWeek] ?? [];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: currentCourses.map((course) => _buildCourseCard(course)).toList(),
    );
  }

  // 修改 _buildCourseCell() 方法
  Widget _buildCourseCell(Course course) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据可用高度调整字体大小
        double availableHeight = constraints.maxHeight;
        double fontSize = availableHeight < 100 ? 11 : 13;
        double smallFontSize = fontSize - 2;

        return Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: borderColor, width: 4)),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                course.teacher,
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                course.location,
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // 修改 _buildFixedTimeSlotColumn() 方法
  Widget _buildFixedTimeSlotColumn(String timeSlot, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        double fontSize = availableHeight < 100 ? 11 : 13;
        double smallFontSize = fontSize - 2;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '第${index + 1}节',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeSlot,
                style: TextStyle(
                  fontSize: smallFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    Color borderColor = _getCourseColor(course.name);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('教师: ${course.teacher}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('时间: ${course.time}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('地点: ${course.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWeekNavigationButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.white),
      onPressed: onPressed,
    );
  }

  Widget _buildViewSwitcher() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      isSelected: [selectedView == '周视图', selectedView == '日视图'],
      selectedColor: Colors.white,
      fillColor: Colors.blueAccent,
      color: Colors.white70,
      onPressed: (index) {
        setState(() {
          selectedView = index == 0 ? '周视图' : '日视图';
        });
      },
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('周视图')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('日视图')),
      ],
    );
  }

  void _prevWeek() {
    if (currentWeek > 1) {
      setState(() => currentWeek--);
    }
  }

  void _nextWeek() {
    if (currentWeek < weekCourses.keys.length) {
      setState(() => currentWeek++);
    }
  }

  Color _getCourseColor(String name) {
    final colors = [Colors.orange, Colors.green, Colors.blue, Colors.purple, Colors.red, Colors.teal];
    return colors[name.hashCode % colors.length];
  }
}

class Course {
  final String name;
  final String teacher;
  final String day;
  final String time;
  final String location;

  const Course(this.name, this.teacher, this.day, this.time, this.location);

  factory Course.empty() => const Course('', '', '', '', '');

  bool get isEmpty => name.isEmpty;
}
