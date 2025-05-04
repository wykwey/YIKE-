import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/course.dart';
import '../services/course_service.dart';
import '../utils/color_utils.dart';
import 'package:provider/provider.dart';
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
    final state = Provider.of<ScheduleState>(context);
    final timetable = state.currentTimetable;
    if (timetable == null) return const SizedBox();

    final maxPeriods = timetable.settings['maxPeriods'] ?? 16;
    final periodTimes = timetable.settings['periodTimes'] ?? {};

    List<Course> currentCourses = widget.getWeekCourses(widget.currentWeek);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 56, // 固定高度匹配周数卡片
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double fontSize = constraints.maxWidth < 50 ? 14 : 16;
                    return Text('节数',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        height: 1.2
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(widget.showWeekend ? 7 : 5, (index) {
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
                        child: Builder(
                          builder: (context) {
                            final timetable = state.currentTimetable;
                            if (timetable?.settings['startDate'] == null) {
                              return Text(AppConstants.weekDays[index],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                            }
                            final startDate = DateTime.parse(timetable!.settings['startDate'].toString());
                            final courseDate = startDate.add(Duration(days: 7 * (widget.currentWeek - 1) + index));
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppConstants.weekDays[index],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text(DateFormat('MM/dd').format(courseDate),
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double minHeight = 80.0;
              double maxHeight = 120.0;
              double calculatedHeight = constraints.maxWidth / 8;
              double cellHeight = calculatedHeight.clamp(minHeight, maxHeight);

              double totalContentHeight = cellHeight * maxPeriods;

              if (totalContentHeight < constraints.maxHeight) {
                cellHeight = constraints.maxHeight / maxPeriods;
              }

              return SingleChildScrollView(
                child: Column(
                  children: List.generate(maxPeriods, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      height: cellHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 50,  // 从70px调整为60px
                            child: _buildPeriodLabel(context, index + 1, periodTimes, maxPeriods),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(widget.showWeekend ? 7 : 5, (dayIndex) {
                                int day = dayIndex + 1;
                                var course = CourseService.getPeriodCourse(
                                  widget.currentWeek,
                                  day,
                                  index + 1,
                                  currentCourses
                                );
                                return Expanded(child: _buildCourseCell(course, context));
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );

  }

  Widget _buildPeriodLabel(BuildContext context, int period, Map periodTimes, int maxPeriods) {
    final timeText = periodTimes[period.toString()] ?? '未知时间';
    final times = timeText.split('-');

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          final state = Provider.of<ScheduleState>(context, listen: false);
          final timetable = state.currentTimetable;
          if (timetable == null) return const SizedBox();

          final currentPeriodTimes = timetable.settings['periodTimes'] ?? {};
          final currentMaxPeriods = timetable.settings['maxPeriods'] ?? 16;

          final controllers = <String, TextEditingController>{};
          for (var i = 1; i <= currentMaxPeriods; i++) {
            controllers[i.toString()] = TextEditingController(
              text: currentPeriodTimes[i.toString()] ?? '',
            );
          }

          return TimeSettingsDialog(
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
          );
        },
      ),
      child: Container(
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
            LayoutBuilder(
              builder: (context, constraints) {
                double fontSize = constraints.maxWidth < 40 ? 8 : 12;
                return Text('第$period节',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Theme.of(context).primaryColorDark
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(times[0],
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).primaryColor)),
                Text('——',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
                Text(times.length > 1 ? times[1] : '',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).primaryColor)),
              ],
            ),
          ],
        ),
      ),
  );
}

  Widget _buildCourseCell(Course course, BuildContext context) {
    void refreshScheduleState(BuildContext context) {
      final state = Provider.of<ScheduleState>(context, listen: false);
      final emptyCourse = Course.empty();
      state.updateCourse(emptyCourse);
    }

    void handleEditComplete(dynamic saved) {
      if (saved == true && context.mounted) {
        refreshScheduleState(context);
      }
    }

    if (course.isEmpty) {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              final state = Provider.of<ScheduleState>(context, listen: false);
              return CourseEditDialog(
                course: course.copyWith(),
              onSave: (updatedCourse) async {
                await state.updateCourse(updatedCourse);
                return true;
              },
              onCancel: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              );
            },
          ).then(handleEditComplete);
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
      );
    }

    Color borderColor = course.color != 0 
        ? Color(course.color) 
        : ColorUtils.getCourseColor(course.name);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            final state = Provider.of<ScheduleState>(context, listen: false);
            return CourseEditDialog(
              course: course,
              onSave: (updatedCourse) async {
                await state.updateCourse(updatedCourse);
                return true;
              },
              onCancel: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            );
          },
        ).then(handleEditComplete);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showWeekend ? 2 : 4,
          vertical: 2
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
        ),
        child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: constraints.maxWidth < (widget.showWeekend ? 80 : 100) ? 10 : (widget.showWeekend ? 12 : 15)
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(course.teacher,
                      style: TextStyle(
                        fontSize: constraints.maxWidth < (widget.showWeekend ? 80 : 100) ? 8 : 10,
                        color: Colors.grey
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(course.location,
                      style: TextStyle(
                        fontSize: constraints.maxWidth < (widget.showWeekend ? 80 : 100) ? 8 : 10,
                        color: Colors.grey
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }