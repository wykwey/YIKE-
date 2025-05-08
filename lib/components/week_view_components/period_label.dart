import 'package:flutter/material.dart';


class PeriodLabel extends StatelessWidget {
  final int period;
  final String timeText;
  final VoidCallback onTap;

  const PeriodLabel({
    super.key,
    required this.period,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final times = timeText.split('-');

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        width: 50,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('第$period节',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.blue[800])),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(times[0], style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text('—', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                Text(times.length > 1 ? times[1] : '', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
