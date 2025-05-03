import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'components/bottom_nav_bar.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';
import 'views/settings_view.dart';
import 'package:provider/provider.dart';
import 'states/schedule_state.dart';
import 'package:permission_handler/permission_handler.dart';

/// 应用入口函数
/// 
/// 主要功能：
/// 1. 初始化Flutter引擎绑定(WidgetsFlutterBinding)
/// 2. 初始化应用设置(AppSettings.init)
/// 3. 配置全局状态管理(使用MultiProvider)
///    - ScheduleState: 管理课程表相关状态
/// 4. 启动应用(runApp)
///
/// 注意：
/// - 必须使用async/await确保初始化完成
/// - WidgetsFlutterBinding.ensureInitialized()是运行Flutter应用的必要前提
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 仅在非Web平台请求存储权限
  if (!kIsWeb) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      // 如果权限被拒绝，可以在这里处理
      print('Storage permission denied');
    }
  }
  
  // 设置初始化已迁移到课表级别
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScheduleState(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// 应用根组件
/// 
/// 负责配置应用的全局设置，包括：
/// - 主题样式(字体、颜色方案)
/// - 本地化支持(中文)
/// - 路由导航设置
/// - 调试标志控制
/// 
/// 使用MaterialApp作为基础框架，集成所有子组件
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

/// 课程表主界面
///
/// 主要功能包括：
/// - 顶部导航栏：显示当前周数、周数切换按钮、设置按钮
/// - 三种视图切换：周视图、日视图、列表视图
/// - 周视图：显示一周课程表格
/// - 日视图：显示单日课程详情
/// - 列表视图：显示所有课程列表
///
/// 状态管理：
/// - 通过ScheduleState管理当前周数、视图类型等状态
/// - 使用Provider进行状态共享
///
/// 布局结构：
/// 1. AppBar - 顶部导航栏
/// 2. Body - 根据当前视图类型显示不同内容
/// 3. BottomNavigationBar - 底部导航栏
class CourseScheduleScreen extends StatelessWidget {
  const CourseScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScheduleState>();

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
                color: state.currentWeek > 1 ? const Color(0xFFFFFFFF) : const Color.fromRGBO(255, 255, 255, 0.3)),
              onPressed: state.currentWeek > 1 ? () => state.changeWeek(state.currentWeek - 1) : null,
            ),
            Center(child: Text('第${state.currentWeek}周', style: const TextStyle(fontSize: 16))),
            IconButton(
              icon: Icon(Icons.chevron_right,
                size: 28,
                color: state.currentWeek < state.totalWeeks ? const Color(0xFFFFFFFF) : const Color.fromRGBO(255, 255, 255, 0.3)),
              onPressed: state.currentWeek < state.totalWeeks
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
          Expanded(
            child: state.selectedView == '周视图'
                ? WeekView(
                    currentWeek: state.currentWeek,
                    maxPeriods: state.maxPeriods,
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
                        courses: Provider.of<ScheduleState>(context).currentTimetable?.courses ?? [],
                      ),
          ),
        ],
      ),
    );
  }
}
