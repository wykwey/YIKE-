import 'package:flutter/material.dart';
import 'data/courses.dart';

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

  List<Course> getWeekCourses(int week) {
    return allCourses.where((course) {
      return course.schedules.any((schedule) {
        return schedule['weekPattern'] == 'all' ||
               schedule['weekPattern'].split(',').contains(week.toString());
      });
    }).toList();
  }

  final int maxPeriods = 5; // 最多5节课，节数 1-5

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
            child: const Text('节数', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    alignment: Alignment.center,
                    child: Text(weekDays[index],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
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
                      child: _buildPeriodLabel(index + 1),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(7, (dayIndex) {
                          int day = dayIndex + 1;
                          var course = currentCourses.firstWhere(
                            (c) => c.schedules.any((s) => 
                              s['day'] == day && s['periods'].contains(index + 1)),
                            orElse: () => Course.empty(),
                          );
                          return Expanded(child: _buildCourseCell(course));
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

  Widget _buildDayView() {
    List<Course> currentCourses = getWeekCourses(currentWeek);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: currentCourses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(currentCourses[index]);
      },
    );
  }

  Widget _buildPeriodLabel(int period) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      alignment: Alignment.center,
      child: Text('第$period节', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(course.teacher, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(course.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    Color borderColor = _getCourseColor(course.name);
    final schedule = course.schedules.first;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
          Text('节数: 第${schedule['periods'].join('-')}节', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    setState(() => currentWeek++);
  }

  Color _getCourseColor(String name) {
    final colors = [Colors.orange, Colors.green, Colors.blue, Colors.purple, Colors.red, Colors.teal];
    return colors[name.hashCode % colors.length];
  }
}
