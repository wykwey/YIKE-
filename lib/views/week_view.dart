import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/course_service.dart';
import '../components/course_edit_dialog.dart';
import '../components/time_settings_dialog.dart';
import '../components/week_view_components/week_header.dart';
import '../components/week_view_components/period_label.dart';
import '../components/week_view_components/course_card.dart';
import '../states/schedule_state.dart';

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
    final state = context.watch<ScheduleState>();
    final timetable = state.currentTimetable;
    if (timetable == null) return const SizedBox();

    final periodTimes = timetable.settings['periodTimes'] ?? {};
    final currentCourses = widget.getWeekCourses(widget.currentWeek);

    return Column(
      children: [
        _buildHeaderRow(timetable),
        Expanded(child: _buildCourseGrid(periodTimes, currentCourses)),
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
                  return SizedBox(
                    height: cellHeight,
                    child: Row(
                      children: [
                        _buildPeriodLabel(periodIndex + 1, periodTimes),
                        Expanded(
                          child: Container(),  // 空容器作为占位
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // 绘制课程卡片
              Positioned(
                left: 58,  // 节次标签宽度 + margin
                right: 12,  // 右边距
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

                          final cellWidth = (constraints.maxWidth - 70) / (widget.showWeekend ? 7 : 5);
                          return Positioned(
                            left: dayIndex * cellWidth,
                            top: periodIndex * cellHeight,  // 根据节次计算位置
                            width: cellWidth - 2,  // 减去边距
                            height: cellHeight * consecutiveCount - 2,  // 减去边距
                            child: _buildCourseCell(course),
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

  Widget _buildPeriodLabel(int period, Map periodTimes) {
    return PeriodLabel(
      period: period,
      timeText: periodTimes[period.toString()] ?? '未知时间',
      onTap: _showTimeSettingsDialog,
    );
  }

  Future<void> _showTimeSettingsDialog() async {
    final state = context.read<ScheduleState>();
    final timetable = state.currentTimetable;
    if (timetable == null) return;

    final periodTimes = timetable.settings['periodTimes'] ?? {};
    final maxPeriods = timetable.settings['maxPeriods'] ?? 16;

    final controllers = {
      for (int i = 1; i <= maxPeriods; i++)
        i.toString(): TextEditingController(text: periodTimes[i.toString()] ?? '')
    };

    await showDialog(
      context: context,
      builder: (_) => TimeSettingsDialog(
        controllers: controllers,
        initialStartDate: timetable.settings['startDate'] != null
            ? DateTime.parse(timetable.settings['startDate'].toString())
            : null,
        onSave: (newTimes, newStartDate) async {
          timetable.settings['periodTimes'] = newTimes;
          if (newStartDate != null) {
            timetable.settings['startDate'] = newStartDate.toString();
          }
          await state.updateTimetable(timetable);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _buildCourseCell(Course course) {
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
      onTap: () => _showCourseEditDialog(course),
    );
  }

  Future<void> _showCourseEditDialog(Course course) async {
    final state = context.read<ScheduleState>();

    final result = await showDialog(
      context: context,
      builder: (_) => CourseEditDialog(
        course: course.copyWith(),
        onSave: (updatedCourse) async {
          await state.updateCourse(updatedCourse);
          return true;
        },
        onCancel: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
    );

    if (result == true && mounted) {
      state.updateCourse(Course.empty());
    }
  }
}
          