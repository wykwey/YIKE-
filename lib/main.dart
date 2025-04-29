import 'package:flutter/material.dart';
import 'data/courses.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';

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
  String selectedView = '列表视图';

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
                ? WeekView(
                    currentWeek: currentWeek,
                    maxPeriods: maxPeriods,
                    getWeekCourses: getWeekCourses,
                  )
                : selectedView == '日视图'
                    ? DayView(
                        currentWeek: currentWeek,
                        getWeekCourses: getWeekCourses,
                      )
                    : CourseListView(
                        currentWeek: currentWeek,
                        getWeekCourses: getWeekCourses,
                      ),
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

  Widget _buildWeekNavigationButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.white),
      onPressed: onPressed,
    );
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
          selectedView = index == 0 ? '周视图' : index == 1 ? '日视图' : '列表视图';
        });
      },
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('周视图')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('日视图')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('列表视图')),
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
}
