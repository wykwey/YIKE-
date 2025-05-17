import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'components/bottom_nav_bar.dart';
import 'views/week_view.dart';
import 'views/day_view.dart';
import 'views/list_view.dart';
import 'package:provider/provider.dart';
import 'states/timetable_state.dart';
import 'states/view_state.dart';
import 'states/week_state.dart';
import 'states/state_coordinator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'components/timetable_management_dialog.dart';
import 'package:flutter/services.dart';

/// 应用入口函数
///
/// 主要功能：
/// 1. 初始化Flutter引擎绑定(WidgetsFlutterBinding)
/// 2. 初始化应用设置(AppSettings.init)
/// 3. 配置全局状态管理(使用MultiProvider)
///    - TimetableState: 管理课表数据
///    - ViewState: 管理视图相关状态
///    - WeekState: 管理周次相关状态
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

  // 使用MultiProvider注册多个状态管理类
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimetableState()),
        ChangeNotifierProvider(create: (_) => ViewState()),
        ChangeNotifierProvider(create: (_) => WeekState()),
      ],
      child: StateCoordinator(
        child: const MyApp(),
      ),
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
/// - 通过拆分的多个状态类管理应用状态
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
    final timetableState = context.watch<TimetableState>();
    final viewState = context.watch<ViewState>();
    final weekState = context.watch<WeekState>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => SystemNavigator.pop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left,
                  color: weekState.currentWeek > 1
                      ? Colors.black87
                      : Colors.black26),
              onPressed: weekState.currentWeek > 1
                  ? () => weekState.changeWeek(weekState.currentWeek - 1, timetableState.currentTimetable)
                  : null,
            ),
            Text(
              '第${weekState.currentWeek}周',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: weekState.currentWeek < timetableState.totalWeeks
                      ? Colors.black87
                      : Colors.black26),
              onPressed: weekState.currentWeek < timetableState.totalWeeks
                  ? () => weekState.changeWeek(weekState.currentWeek + 1, timetableState.currentTimetable)
                  : null,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.swap_horiz, color: Colors.black54),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TimetableManagementDialog(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      body: Column(
        children: [
          Expanded(
            child: viewState.selectedView == '周视图'
                ? WeekView(
                    currentWeek: weekState.currentWeek,
                    maxPeriods: timetableState.maxPeriods,
                    getWeekCourses: (week) => weekState.getWeekCourses(week, timetableState.currentTimetable),
                    showWeekend: viewState.showWeekend,
                  )
                : viewState.selectedView == '日视图'
                    ? DayView(
                        currentWeek: weekState.currentWeek,
                        getWeekCourses: (week) => weekState.getWeekCourses(week, timetableState.currentTimetable),
                        showWeekend: viewState.showWeekend,
                      )
                    : CourseListView(
                        courses: timetableState.currentTimetable?.courses ?? [],
                      ),
          ),
        ],
      ),
    );
  }
}
