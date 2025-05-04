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
                            width: 70,
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
            onSave: (newTimes, _) async {
              timetable.settings['periodTimes'] = newTimes;
              await state.updateTimetable(timetable);
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
            Text('第$period节',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).primaryColorDark)),
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
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(course.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(course.teacher,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(course.location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}