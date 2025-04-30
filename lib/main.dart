import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'components/bottom_nav_bar.dart';
import 'data/courses.dart';
import 'data/settings.dart';
import 'constants.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';
import 'views/settings_view.dart';
import 'package:provider/provider.dart';
import 'states/schedule_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleState()),
      ],
      child: const MyApp(),
    ),
  );
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

class CourseScheduleScreen extends StatelessWidget {
  const CourseScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScheduleState>();
    final weekDays = AppConstants.weekDays;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('课程表', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (state.selectedView != '列表视图') ...[
            IconButton(
              icon: Icon(Icons.chevron_left, 
                size: 28, 
                color: state.currentWeek > 1 ? Colors.white : Colors.white.withOpacity(0.3)),
              onPressed: state.currentWeek > 1 ? () => state.changeWeek(state.currentWeek - 1) : null,
            ),
            Center(child: Text('第${state.currentWeek}周', style: const TextStyle(fontSize: 16))),
            IconButton(
              icon: Icon(Icons.chevron_right,
                size: 28,
                color: state.currentWeek < AppSettings.totalWeeks ? Colors.white : Colors.white.withOpacity(0.3)),
              onPressed: state.currentWeek < AppSettings.totalWeeks 
                ? () => state.changeWeek(state.currentWeek + 1) 
                : null,
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
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body: Column(
        children: [
          if (state.selectedView == '周视图') 
            Container(
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
                      children: List.generate(state.showWeekend ? 7 : 5, (index) {
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
            ),
          Expanded(
            child: state.selectedView == '周视图'
                ? WeekView(
                    currentWeek: state.currentWeek,
                    maxPeriods: AppSettings.maxPeriods,
                    getWeekCourses: (week) => state.getWeekCourses(week),
                    showWeekend: state.showWeekend,
                  )
                : state.selectedView == '日视图'
                    ? DayView(
                        currentWeek: state.currentWeek,
                        getWeekCourses: (week) => state.getWeekCourses(week),
                        showWeekend: state.showWeekend,
                      )
                    : CourseListView(
                        courses: allCourses,
                      ),
          ),
        ],
      ),
    );
  }
}
