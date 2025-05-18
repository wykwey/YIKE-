import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/course_service.dart';
import '../constants/app_constants.dart';
import '../components/course_edit_dialog.dart';
import '../states/timetable_state.dart';
import '../states/week_state.dart';
import '../utils/color_utils.dart';
import '../components/add_course_fab.dart';

/// 日视图组件
///
/// 负责显示单日的课程安排，包括：
/// - 顶部日期选择器（_DaySelector）
/// - 课程卡片列表（_CourseList, _CourseCard）
/// - 悬浮添加按钮
///
/// 状态管理说明：
/// - selectedDay: 当前选中的星期（1-7），为null表示未选中
/// - lastSelectedDay/lastSelectedWeek: 记录上次选中的日期和周，用于切换周时高亮和内容回显
/// - 课程数据通过getWeekCourses和CourseService.getDayCourses获取
class DayView extends StatefulWidget {
  final int currentWeek;
  final List<Course> Function(int) getWeekCourses;
  final bool showWeekend;

  /// [currentWeek] 当前周数
  /// [getWeekCourses] 获取指定周的所有课程的方法
  /// [showWeekend] 是否显示周末
  const DayView({
    super.key,
    required this.currentWeek,
    required this.getWeekCourses,
    this.showWeekend = false,
  });

  @override
  State<DayView> createState() => _DayViewState();
}

/// 日视图状态
///
/// 负责管理日期选择、切换周时的高亮与内容回显
class _DayViewState extends State<DayView> {
  int? selectedDay; // 当前选中的星期（1-7），为null表示未选中
  int? lastSelectedDay; // 上次选中的星期
  int? lastSelectedWeek; // 上次选中的周

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectDayOnEnter();
    });
  }

  /// 进入日视图时自动选择日期（今日或下周一）
  void _autoSelectDayOnEnter() {
    final now = DateTime.now();
    final todayWeekday = now.weekday.clamp(1, 7);
    if (!widget.showWeekend && todayWeekday >= 6) {
      final timetableState = Provider.of<TimetableState>(context, listen: false);
      final weekState = Provider.of<WeekState>(context, listen: false);
      weekState.changeWeek(widget.currentWeek + 1, timetableState.currentTimetable);
      setState(() {
        selectedDay = 1;
        lastSelectedDay = 1;
        lastSelectedWeek = widget.currentWeek + 1;
      });
    } else {
      setState(() {
        selectedDay = todayWeekday;
        lastSelectedDay = todayWeekday;
        lastSelectedWeek = widget.currentWeek;
      });
    }
  }

  /// 切换周时，清空选中项，若切回上次有选中日期的周则自动恢复高亮
  @override
  void didUpdateWidget(covariant DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeek != widget.currentWeek) {
      setState(() {
        selectedDay = null;
      });
      if (lastSelectedWeek == widget.currentWeek && lastSelectedDay != null) {
        setState(() {
          selectedDay = lastSelectedDay;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 当前用于内容展示的周和天
    final int displayWeek = selectedDay == null && lastSelectedDay != null && lastSelectedWeek != null
        ? lastSelectedWeek!
        : widget.currentWeek;
    final int? displayDay = selectedDay ?? lastSelectedDay;
    final List<Course> dayCourses = (displayDay == null)
        ? []
        : CourseService.getDayCourses(
            displayWeek,
            displayDay,
            widget.getWeekCourses(displayWeek),
          )..removeWhere((c) => c.isEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _DaySelector(
                currentWeek: widget.currentWeek,
                showWeekend: widget.showWeekend,
                selectedDay: selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                    lastSelectedDay = day;
                    lastSelectedWeek = widget.currentWeek;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _CourseList(
                  displayDay: displayDay,
                  dayCourses: dayCourses,
                  onEditCourse: _handleEditCourse,
                ),
              ),
            ],
          ),
          const AddCourseFab(),
        ],
      ),
    );
  }

  /// 课程编辑弹窗
  Future<void> _handleEditCourse(Course course) async {
    if (!mounted) return;
    final editedCourse = await showDialog<Course>(
      context: context,
      builder: (context) => CourseEditDialog(
        course: course,
        onSave: (editedCourse) async {
          if (!mounted) return false;
          final timetableState = Provider.of<TimetableState>(context, listen: false);
          await timetableState.updateCourse(editedCourse);
          return true;
        },
        onCancel: () {
          if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
    ).then((saved) {
      if (saved == true && mounted) {
        setState(() {});
      }
      return saved;
    });
    if (editedCourse != null && mounted) {
      final timetableState = Provider.of<TimetableState>(context, listen: false);
      await timetableState.updateCourse(editedCourse);
      setState(() {});
    }
  }
}

/// 顶部日期选择器组件
///
/// 负责渲染一周的日期按钮，支持高亮、回调选中
class _DaySelector extends StatelessWidget {
  final int currentWeek;
  final bool showWeekend;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  /// [currentWeek] 当前周数
  /// [showWeekend] 是否显示周末
  /// [selectedDay] 当前高亮的星期
  /// [onDaySelected] 日期点击回调
  const _DaySelector({
    required this.currentWeek,
    required this.showWeekend,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final fontSize = isWide ? 14.0 : 13.0;
          final padding = isWide ? 10.0 : 8.0;
          const minHeight = 50.0;
          const spacing = 8.0;

          final itemWidth = (constraints.maxWidth - spacing * 6) /
              (showWeekend ? 7 : 5);
          final itemAspectRatio = itemWidth / minHeight;

          return GridView.count(
            crossAxisCount: showWeekend ? 7 : 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
            children: List.generate(showWeekend ? 7 : 5, (i) {
              int day = i + 1;
              return InkWell(
                onTap: () => onDaySelected(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedDay == day ? Colors.blue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final timetableState = Provider.of<TimetableState>(context);
                        final timetable = timetableState.currentTimetable;
                        final textColor = selectedDay == day ? Colors.white : Colors.grey[800];
                        if (timetable?.settings['startDate'] == null) {
                          return Text(
                            AppConstants.weekDays[i],
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                        final startDate = DateTime.parse(timetable!.settings['startDate'].toString());
                        final courseDate = startDate.add(Duration(days: 7 * (currentWeek - 1) + i));
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConstants.weekDays[i],
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              DateFormat('MM/dd').format(courseDate),
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: textColor?.withOpacity(0.85),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// 课程列表组件
///
/// 负责渲染选中日期下的所有课程卡片
class _CourseList extends StatelessWidget {
  final int? displayDay;
  final List<Course> dayCourses;
  final Future<void> Function(Course) onEditCourse;

  /// [displayDay] 当前展示的星期
  /// [dayCourses] 该天的课程列表
  /// [onEditCourse] 编辑课程回调
  const _CourseList({
    required this.displayDay,
    required this.dayCourses,
    required this.onEditCourse,
  });

  @override
  Widget build(BuildContext context) {
    if (displayDay == null) {
      return const Center(child: Text("请选择日期"));
    }
    if (dayCourses.isEmpty) {
      return const Center(child: Text("今日无课程"));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: dayCourses.length,
      itemBuilder: (context, index) {
        final course = dayCourses[index];
        return _CourseCard(
          course: course,
          selectedDay: displayDay!,
          onEdit: () => onEditCourse(course),
        );
      },
    );
  }
}

/// 单个课程卡片组件
///
/// 负责渲染课程的详细信息，点击可编辑
class _CourseCard extends StatelessWidget {
  final Course course;
  final int selectedDay;
  final VoidCallback onEdit;

  /// [course] 课程对象
  /// [selectedDay] 当前星期
  /// [onEdit] 编辑回调
  const _CourseCard({
    required this.course,
    required this.selectedDay,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final schedule = course.schedules.firstWhere(
      (s) => s['day'] == selectedDay,
      orElse: () => course.schedules.first,
    );
    final periods = schedule['periods'].join(',');
    final timeText = '${AppConstants.weekDays[schedule['day'] - 1]} 第$periods节';
    final borderColor = course.color != 0
        ? Color(course.color)
        : ColorUtils.getCourseColor(course.name);

    return LayoutBuilder(
      builder: (context, constraints) {
        final large = constraints.maxWidth > 600;
        final titleSize = large ? 18.0 : 15.0;
        final detailSize = large ? 14.0 : 12.0;
        final padding = large ? 16.0 : 12.0;
        final borderWidth = large ? 5.0 : 4.0;

        return GestureDetector(
          onTap: onEdit,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: borderColor, width: borderWidth)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold)),
                SizedBox(height: large ? 8 : 6),
                Text(timeText, style: TextStyle(fontSize: detailSize, color: Colors.deepPurple)),
                Text('教师: ${course.teacher}', style: TextStyle(fontSize: detailSize, color: Colors.grey)),
                Text('地点: ${course.location}', style: TextStyle(fontSize: detailSize, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
