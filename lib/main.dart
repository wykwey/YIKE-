import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/courses.dart';
import 'services/course_service.dart';
import 'data/settings.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';
import 'views/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
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
  int _currentWeek = 1;
  int get currentWeek => _currentWeek;
  set currentWeek(int value) {
    if (value >= 1 && value <= AppSettings.totalWeeks) {
      setState(() {
        _currentWeek = value;
        AppSettings.saveWeekPreference(value); // 仍然保存到设置
      });
    }
  }
  String get selectedView => AppSettings.selectedView;
  bool get showWeekend => AppSettings.showWeekend;

  List<Course> getWeekCourses(int week) {
    return CourseService.getWeekCourses(week, allCourses);
  }

  final int maxPeriods = AppSettings.maxPeriods; // 从设置中获取节数

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
                  maxPeriods: AppSettings.maxPeriods,
                  getWeekCourses: getWeekCourses,
                  showWeekend: showWeekend,
                  )
                : selectedView == '日视图'
                    ? DayView(
                        currentWeek: currentWeek,
                        getWeekCourses: getWeekCourses,
                        showWeekend: showWeekend,
                      )
                    : CourseListView(
                        courses: allCourses,
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
        if (selectedView != '列表视图') ...[
          _buildWeekNavigationButton(
            Icons.chevron_left, 
            _prevWeek,
            enabled: currentWeek > 1,
          ),
          Center(child: Text('第$currentWeek周', style: const TextStyle(fontSize: 16))),
          _buildWeekNavigationButton(
            Icons.chevron_right, 
            _nextWeek,
            enabled: currentWeek < AppSettings.totalWeeks,
          ),
          const SizedBox(width: 8),
        ],
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        ),
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
              children: List.generate(showWeekend ? 7 : 5, (index) {
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

  Widget _buildWeekNavigationButton(IconData icon, VoidCallback onPressed, {bool enabled = true}) {
    return IconButton(
      icon: Icon(icon, size: 28, color: enabled ? Colors.white : Colors.white.withOpacity(0.3)),
      onPressed: enabled ? onPressed : null,
    );
  }

  void _prevWeek() => currentWeek--;
  void _nextWeek() => currentWeek++;
}
