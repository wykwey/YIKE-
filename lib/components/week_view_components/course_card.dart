import 'package:flutter/material.dart';
import '../../data/course.dart';
import '../../utils/color_utils.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isConsecutive;
  final bool showWeekend;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.isConsecutive,
    required this.showWeekend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = course.isEmpty;
    final baseColor = isEmpty ? Colors.grey[300]! 
        : (course.color != 0
            ? Color(course.color)
            : ColorUtils.getCourseColor(course.name));
    final textColor = isEmpty ? Colors.grey[600]! 
        : ColorUtils.getContrastColor(baseColor);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        padding: EdgeInsets.symmetric(
          horizontal: showWeekend ? 4 : 8,
          vertical: isConsecutive ? 8 : 4,
        ),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white : baseColor.withOpacity(0.2).withAlpha(200),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEmpty ? Colors.grey[300]! : baseColor.withOpacity(0.5),
            width: 1
          ),
        ),
        child: isEmpty
            ? null
            : LayoutBuilder(
                builder: (context, constraints) {
                  final smallWidth = constraints.maxWidth < (showWeekend ? 80 : 100);
                  final nameStyle = TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isConsecutive 
                        ? (smallWidth ? 12 : 16)
                        : (smallWidth ? 10 : (showWeekend ? 12 : 15)),
                    color: textColor,
                  );
                  final subStyle = TextStyle(
                    fontSize: isConsecutive ? (smallWidth ? 10 : 12) : (smallWidth ? 8 : 10),
                    color: textColor,
                  );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
}
