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
        child: Column(
          children: List.generate(maxPeriods, (periodIndex) {
            return Container(
              height: cellHeight,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  _buildPeriodLabel(periodIndex + 1, periodTimes),
                  Expanded(
                    child: Row(
                      children:
                          List.generate(widget.showWeekend ? 7 : 5, (dayIndex) {
                        final course = CourseService.getPeriodCourse(
                          widget.currentWeek,
                          dayIndex + 1,
                          periodIndex + 1,
                          currentCourses,
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
    });
  }

  Widget _buildPeriodLabel(int period, Map periodTimes) {
    final timeText = periodTimes[period.toString()] ?? '未知时间';
    final times = timeText.split('-');

    return InkWell(
      onTap: () => _showTimeSettingsDialog(),
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
    final borderColor = course.color != 0
        ? Color(course.color)
        : ColorUtils.getCourseColor(course.name);

    return InkWell(
      onTap: () => _showCourseEditDialog(course),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: EdgeInsets.symmetric(
            horizontal: widget.showWeekend ? 2 : 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isEmpty
              ? Border.all(color: Colors.grey[300]!)
              : Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: isEmpty
              ? []
              : const [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: isEmpty
            ? null
            : LayoutBuilder(builder: (context, constraints) {
                final smallWidth = constraints.maxWidth < (widget.showWeekend ? 80 : 100);
                final nameStyle = TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: smallWidth ? 10 : (widget.showWeekend ? 12 : 15));
                final subStyle = TextStyle(
                    fontSize: smallWidth ? 8 : 10, color: Colors.grey);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: Text(course.name, style: nameStyle, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Flexible(child: Text(course.teacher, style: subStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Flexible(child: Text(course.location, style: subStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                );
              }),
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
