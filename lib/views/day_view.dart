import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course.dart';
import '../services/course_service.dart';
import '../constants/app_constants.dart';
import '../components/course_edit_dialog.dart';
import '../states/schedule_state.dart';
import '../utils/color_utils.dart';

/// 日视图组件
///
/// 显示单日的课程安排列表视图
/// 包含:
/// - 时间轴布局
/// - 课程卡片垂直排列
/// - 空课时间段显示
class DayView extends StatefulWidget {
  final int currentWeek;
  final List<Course> Function(int) getWeekCourses;
  final bool showWeekend;

  const DayView({
    super.key,
    required this.currentWeek,
    required this.getWeekCourses,
    this.showWeekend = false,
  });

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  int selectedDay = DateTime.now().weekday.clamp(1, 7); // 1-周一, 7-周日

  @override
  Widget build(BuildContext context) {
    List<Course> dayCourses = CourseService.getDayCourses(
      widget.currentWeek, 
      selectedDay,
      widget.getWeekCourses(widget.currentWeek)
    )..removeWhere((c) => c.isEmpty);

    return Column(
      children: [
        _buildDaySelector(context),
        const SizedBox(height: 8),
        Expanded(
          child: dayCourses.isEmpty
              ? const Center(child: Text("今日无课程"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: dayCourses.length,
                  itemBuilder: (context, index) {
                    final course = dayCourses[index];
                    return _buildCourseCard(course);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(BuildContext context) {
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
              (widget.showWeekend ? 7 : 5);
          final itemAspectRatio = itemWidth / minHeight;

          return GridView.count(
            crossAxisCount: widget.showWeekend ? 7 : 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
            children: List.generate(widget.showWeekend ? 7 : 5, (i) {
              int day = i + 1;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedDay == day ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selectedDay == day
                        ? [BoxShadow(color: Colors.blue.shade300, blurRadius: 4, offset: const Offset(0, 2))]
                        : null,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Center(
                      child: Text(
                        AppConstants.weekDays[i],
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: selectedDay == day ? Colors.blue.shade800 : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
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

  Future<void> _handleEditCourse(Course course) async {
    if (!mounted) return;
    
    final editedCourse = await showDialog<Course>(
      context: context,
      builder: (context) => CourseEditDialog(
        course: course,
        onSave: (editedCourse) async {
          if (!mounted) return false;
          final state = Provider.of<ScheduleState>(context, listen: false);
          await state.updateCourse(editedCourse);
          return true;
        },
      ),
    );
    
    if (editedCourse != null && mounted) {
      final state = Provider.of<ScheduleState>(context, listen: false);
      await state.updateCourse(editedCourse);
    }
  }

  Widget _buildCourseCard(Course course) {
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
          onTap: () => _handleEditCourse(course),
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
