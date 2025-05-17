import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/course_service.dart';
import '../components/course_edit_dialog.dart';
import '../components/week_view_components/week_header.dart';
import '../components/week_view_components/period_label.dart';
import '../components/week_view_components/course_card.dart';
import '../states/timetable_state.dart';
import '../states/week_state.dart';
import '../components/add_course_fab.dart';
import '../views/time_settings_page.dart';

class WeekView extends StatefulWidget {
  final int currentWeek;
  final List<Course> Function(int) getWeekCourses;
  final int maxPeriods;
  final bool showWeekend;

  const WeekView({
    super.key,
    required this.currentWeek,
    required this.getWeekCourses,
    required this.maxPeriods,
    this.showWeekend = false,
  });

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  @override
  Widget build(BuildContext context) {
    final timetableState = context.watch<TimetableState>();
    final timetable = timetableState.currentTimetable;
    if (timetable == null) return const SizedBox();

    final periodTimes = timetable.settings['periodTimes'] ?? {};
    final currentCourses = widget.getWeekCourses(widget.currentWeek);

    return Stack(
      children: [
        Column(
          children: [
            _buildHeaderRow(timetable),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _buildCourseGrid(periodTimes, currentCourses),
              ),
            ),
          ],
        ),
        const AddCourseFab(),
      ],
    );
  }

  Widget _buildHeaderRow(dynamic timetable) {
    return WeekHeader(
      showWeekend: widget.showWeekend,
      currentWeek: widget.currentWeek,
      timetableSettings: timetable.settings,
    );
  }

  Widget _buildCourseGrid(Map periodTimes, List<Course> currentCourses) {
    return LayoutBuilder(builder: (context, constraints) {
      final preferredCellHeight = (constraints.maxWidth / 8).clamp(80.0, 120.0);
      final maxPeriods = widget.maxPeriods;
      final totalHeight = preferredCellHeight * maxPeriods;
      final cellHeight = totalHeight < constraints.maxHeight
          ? constraints.maxHeight / maxPeriods
          : preferredCellHeight;

      return SingleChildScrollView(
        child: SizedBox(
          height: cellHeight * maxPeriods,  // 设置总高度
          child: Stack(  // 使用Stack作为主容器
            children: [
              // 绘制网格背景
              Column(
                children: List.generate(maxPeriods, (periodIndex) {
                  return Container(
                    height: cellHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: periodIndex < maxPeriods - 1 ? BorderSide(color: Colors.grey[200]!, width: 1.0) : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodLabel(periodIndex + 1, periodTimes, cellHeight),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // 绘制课程卡片
              Positioned(
                left: 40,  // 匹配调整后的PeriodLabel宽度
                right: 0,
                top: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    for (int periodIndex = 0; periodIndex < maxPeriods; periodIndex++)
                      for (int dayIndex = 0; dayIndex < (widget.showWeekend ? 7 : 5); dayIndex++)
                        Builder(builder: (context) {
                          final course = CourseService.getPeriodCourse(
                            widget.currentWeek,
                            dayIndex + 1,
                            periodIndex + 1,
                            currentCourses,
                          );
                          
                          // 跳过连续课程的非第一节
                          if (periodIndex > 0 && !course.isEmpty) {
                            final isPartOfConsecutive = CourseService.areConsecutive(
                              widget.currentWeek,
                              dayIndex + 1,
                              periodIndex,
                              periodIndex + 1,
                              currentCourses,
                            );
                            if (isPartOfConsecutive) {
                              return const SizedBox.shrink();
                            }
                          }

                          // 计算连续课程长度
                          var consecutiveCount = 1;
                          if (!course.isEmpty) {
                            final consecutiveCourses = CourseService.getConsecutiveCourses(
                              widget.currentWeek,
                              dayIndex + 1,
                              periodIndex + 1,
                              currentCourses,
                            );
                            consecutiveCount = consecutiveCourses.length;
                          }

                          final cellWidth = (constraints.maxWidth - 40) / (widget.showWeekend ? 7 : 5);
                          return Positioned(
                            left: dayIndex * cellWidth,
                            top: periodIndex * cellHeight,  // 根据节次计算位置
                            width: cellWidth,
                            height: cellHeight * consecutiveCount,
                            child: _buildCourseCell(
                              course,
                              dayIndex + 1,  // 传递星期信息
                              periodIndex + 1,  // 传递节次信息
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPeriodLabel(int period, Map periodTimes, double cellHeight) {
    return PeriodLabel(
      period: period,
      timeText: periodTimes[period.toString()] ?? '未知时间',
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TimeSettingsPage(),
          ),
        );
        if (mounted) setState(() {});
      },
      height: cellHeight,
    );
  }

  Widget _buildCourseCell(Course course, int day, int period) {
    final isEmpty = course.isEmpty;
    List<Course> consecutiveCourses = [];
    
    if (!isEmpty && course.schedules.isNotEmpty) {
      consecutiveCourses = CourseService.getConsecutiveCourses(
        widget.currentWeek,
        course.schedules.first['day'],
        course.schedules.first['periods'].first,
        [course],
      );
    }
    
    return CourseCard(
      course: course,
      isConsecutive: consecutiveCourses.length > 1,
      showWeekend: widget.showWeekend,
      onTap: () => _showCourseEditDialog(course, day, period),
    );
  }

  Future<void> _showCourseEditDialog(Course course, int day, int period) async {
    final timetableState = context.read<TimetableState>();
    
    // 如果是空课程，创建一个默认的课程对象，并设置日期和节次信息
    if (course.isEmpty) {
      course = Course.empty().copyWith(
        schedules: [
          {
            'day': day,
            'periods': [period],
            'weekPattern': '${widget.currentWeek}',
          }
        ]
      );
    }

    final result = await showDialog(
      context: context,
      builder: (_) => CourseEditDialog(
        course: course.copyWith(),
        onSave: (updatedCourse) async {
          await timetableState.updateCourse(updatedCourse);
          return true;
        },
        onCancel: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
    );

    if (result == true && mounted) {
      timetableState.updateCourse(Course.empty());
    }
  }
}
