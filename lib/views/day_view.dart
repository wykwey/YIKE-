import 'package:flutter/material.dart';
import '../data/courses.dart';

class DayView extends StatefulWidget {
  final int currentWeek;
  final List<Course> Function(int) getWeekCourses;

  const DayView({
    super.key,
    required this.currentWeek,
    required this.getWeekCourses,
  });

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  int selectedDay = DateTime.now().weekday.clamp(1, 7); // 1-周一, 7-周日

  @override
  Widget build(BuildContext context) {
    List<Course> allCourses = widget.getWeekCourses(widget.currentWeek);
    List<Course> dayCourses = allCourses.where((course) {
      return course.schedules.any((s) => s['day'] == selectedDay);
    }).toList();

    return Column(
      children: [
        _buildDaySelector(),
        const SizedBox(height: 8),
        Expanded(
          child: dayCourses.isEmpty
              ? const Center(child: Text("今日无课程"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: dayCourses.length,
                  itemBuilder: (context, index) {
                    return _buildCourseCard(dayCourses[index]);
                  },
                ),
        ),
      ],
    );
  }

Widget _buildDaySelector() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5, // 更改比例，使每个格子更高
      children: List.generate(7, (i) {
        int day = i + 1;
        return InkWell(
          onTap: () {
            setState(() {
              selectedDay = day;
            });
          },
          child: Container(
            constraints: BoxConstraints(minHeight: 60), // 确保容器有足够高度
            decoration: BoxDecoration(
              color: selectedDay == day ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selectedDay == day
                  ? [BoxShadow(color: Colors.blue.shade300, blurRadius: 4, offset: Offset(0, 2))]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8), // 水平填充
            child: Center(
              child: Text(
                weekDays[i], // 显示周几
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: selectedDay == day ? Colors.blue.shade800 : Colors.black87,
                ),
                textAlign: TextAlign.center, // 确保文本居中
              ),
            ),
          ),
        );
      }),
    ),
  );
}



  Widget _buildCourseCard(Course course) {
    final borderColor = _getCourseColor(course.name);
    final schedule = course.schedules.firstWhere((s) => s['day'] == selectedDay, orElse: () => course.schedules.first);
    final periods = schedule['periods'].join('-');
    final timeText = '${weekDays[schedule['day'] - 1]} 第$periods节';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.deepPurple)),
          Text('教师: ${course.teacher}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('地点: ${course.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getCourseColor(String name) {
    final colors = [Colors.orange, Colors.green, Colors.blue, Colors.purple, Colors.red, Colors.teal];
    return colors[name.hashCode % colors.length];
  }
}
