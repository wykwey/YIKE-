 import 'package:flutter/material.dart';
import '../time_settings_dialog.dart';
import '../../constants/app_constants.dart';
import 'package:intl/intl.dart';

class WeekHeader extends StatelessWidget {
  final bool showWeekend;
  final int currentWeek;
  final Map<String, dynamic> timetableSettings;

  const WeekHeader({
    super.key,
    required this.showWeekend,
    required this.currentWeek,
    required this.timetableSettings,
  });

  @override
  Widget build(BuildContext context) {
    final startDateString = timetableSettings['startDate'];
    final startDate = startDateString != null 
        ? DateTime.parse(startDateString.toString()) 
        : null;

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          _buildHeaderCell('节数', width: 50),
          Expanded(
            child: Row(
              children: List.generate(showWeekend ? 7 : 5, (index) {
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
      width: 50,
      height: 48,
      margin: const EdgeInsets.only(left: 0, right: 8, top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w600,
              fontSize: 16)),
    );
  }

  Widget _buildDayCell(int index, DateTime? startDate) {
    final weekday = AppConstants.weekDays[index];
    final date = startDate?.add(Duration(days: 7 * (currentWeek - 1) + index));
    
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 8, top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(weekday,
              style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          if (date != null)
            Text(DateFormat('MM/dd').format(date),
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: 12)),
        ],
      ),
    );
  }
}
