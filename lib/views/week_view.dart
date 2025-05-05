import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/course.dart';
import '../services/course_service.dart';
import '../utils/color_utils.dart';
import '../components/course_edit_dialog.dart';
import '../components/time_settings_dialog.dart';
import '../states/schedule_state.dart';
import '../constants/app_constants.dart';

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
    final startDateString = timetable.settings['startDate'];
    final startDate = startDateString != null ? DateTime.parse(startDateString.toString()) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildHeaderCell('节数', width: 50),
          Expanded(
            child: Row(
              children: List.generate(widget.showWeekend ? 7 : 5, (index) {
                return Expanded(
                  child: _buildDayCell(index, startDate),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {double width = 50}) {
    return Container(
      width: width,
      height: 56,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildDayCell(int index, DateTime? startDate) {
    final weekday = AppConstants.weekDays[index];
    final date = startDate?.add(Duration(days: 7 * (widget.currentWeek - 1) + index));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weekday,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          if (date != null)
            Text(DateFormat('MM/dd').format(date),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
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
        child: Container(
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
    final timeText = periodTimes[period.toString()] ?? '未知时间';
    final times = timeText.split('-');

    return InkWell(
      onTap: () => _showTimeSettingsDialog(),
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: 50,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('第$period节',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).primaryColorDark)),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(times[0], style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                const Text('——', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(times.length > 1 ? times[1] : '', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
              ],
            ),
          ],
        ),
      ),
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
    
    // 只有当课程不为空时才获取连续课程
    if (!isEmpty && course.schedules.isNotEmpty) {
      consecutiveCourses = CourseService.getConsecutiveCourses(
        widget.currentWeek,
        course.schedules.first['day'],
        course.schedules.first['periods'].first,
        [course],
      );
    }
    
    final isConsecutive = consecutiveCourses.length > 1;
    
    final baseColor = isEmpty ? Colors.grey[300]! 
        : (course.color != 0
            ? Color(course.color)
            : ColorUtils.getCourseColor(course.name));
    final textColor = isEmpty ? Colors.grey[600]! 
        : ColorUtils.getContrastColor(baseColor);
    
    return InkWell(
      onTap: () => _showCourseEditDialog(course),  // 移除 isEmpty 条件
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showWeekend ? 4 : 8,
          vertical: isConsecutive ? 8 : 4,
        ),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white : baseColor.withOpacity(0.2).withAlpha(200),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEmpty ? Colors.grey[300]! : baseColor.withOpacity(0.5),
            width: 1
          ),
          boxShadow: isEmpty ? null : [
            BoxShadow(
              color: baseColor.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1
            )
          ],
        ),
        child: isEmpty
            ? null
            : LayoutBuilder(
                builder: (context, constraints) {
                  final smallWidth = constraints.maxWidth < (widget.showWeekend ? 80 : 100);
                  final nameStyle = TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isConsecutive 
                        ? (smallWidth ? 12 : 16)
                        : (smallWidth ? 10 : (widget.showWeekend ? 12 : 15)),
                    color: textColor,
                  );
                  final subStyle = TextStyle(
                    fontSize: isConsecutive ? (smallWidth ? 10 : 12) : (smallWidth ? 8 : 10),
                    color: textColor,
                  );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: isConsecutive ? 2 : 1,
                        child: Text(
                          course.name,
                          style: nameStyle,
                          maxLines: isConsecutive ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isConsecutive ? 4 : 2),
                      Flexible(
                        child: Text(
                          course.teacher,
                          style: subStyle,
                          maxLines: isConsecutive ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isConsecutive ? 4 : 2),
                      Flexible(
                        child: Text(
                          course.location,
                          style: subStyle,
                          maxLines: isConsecutive ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
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