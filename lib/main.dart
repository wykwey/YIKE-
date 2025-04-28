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

  final Map<int, List<Course>> weekCourses = {
    1: [
      Course('数学', '张老师', '周一', '8:00 - 10:00'),
      Course('英语', '李老师', '周二', '10:00 - 12:00'),
      Course('物理', '刘老师', '周三', '14:00 - 16:00'),
      Course('化学', '王老师', '周四', '16:00 - 18:00'),
      Course('生物', '赵老师', '周五', '19:00 - 21:00'),
    ],
    2: [
      Course('计算机基础', '王老师', '周一', '8:00 - 10:00'),
      Course('物理', '刘老师', '周二', '10:00 - 12:00'),
      Course('高等数学', '张老师', '周三', '14:00 - 16:00'),
      Course('英语', '李老师', '周四', '16:00 - 18:00'),
      Course('体育', '孙老师', '周五', '19:00 - 21:00'),
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
          _buildWeekHeader(),
          Expanded(child: _buildTimeTable()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4a6bdf), // 蓝色背景
      title: const Text(
        '智能课表系统',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: false, // 左对齐标题
      actions: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: _prevWeek, // 切换到上一周
            ),
            Center(
              child: Text(
                '第 $currentWeek 周',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: _nextWeek, // 切换到下一周
            ),
            const SizedBox(width: 8),
            _buildViewSwitcher(), // 视图切换按钮
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildWeekDayCard('时间', isFirst: true),
          ...['周一', '周二', '周三', '周四', '周五', '周六', '周日']
              .map((day) => _buildWeekDayCard(day))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWeekDayCard(String text, {bool isFirst = false}) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(left: isFirst ? 0 : 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTable() {
    List<Course> currentWeekCourses = weekCourses[currentWeek] ?? [];
    return ListView.builder(
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeftColumn(index, timeSlots[index]),
              Expanded(
                flex: 7,
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    String day = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][dayIndex];
                    Course course = currentWeekCourses.firstWhere(
                          (c) => c.day == day && c.time == timeSlots[index],
                      orElse: () => Course.empty(),
                    );
                    return Expanded(child: _buildCourseCard(course));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftColumn(int index, String timeSlot) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blueAccent),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '第${index + 1}节',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              timeSlot,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    if (course.isEmpty) return const SizedBox.shrink();

    Color borderColor = _getCourseColor(course.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('教师: ${course.teacher}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('时间: ${course.time}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('地点: 教室 A101', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getCourseColor(String name) {
    switch (name) {
      case '数学':
        return Colors.orange;
      case '英语':
        return Colors.green;
      case '计算机基础':
        return Colors.blue;
      case '物理':
        return Colors.purple;
      case '体育':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildViewSwitcher() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      isSelected: [
        selectedView == '周视图',
        selectedView == '日视图',
        selectedView == '列表视图'
      ],
      selectedColor: Colors.white,
      fillColor: Colors.blueAccent,
      color: Colors.white70,
      onPressed: (index) {
        setState(() {
          selectedView = ['周视图', '日视图', '列表视图'][index];
        });
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('周视图'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('日视图'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('列表视图'),
        ),
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
}

class Course {
  final String name;
  final String teacher;
  final String day;
  final String time;

  const Course(this.name, this.teacher, this.day, this.time);

  factory Course.empty() => const Course('', '', '', '');

  bool get isEmpty => name.isEmpty;
}
