import 'package:flutter/material.dart';

class PeriodLabel extends StatelessWidget {
  final int period;
  final String timeText;
  final VoidCallback onTap;
  final double height;

  const PeriodLabel({
    super.key,
    required this.period,
    required this.timeText,
    required this.onTap,
    required this.height,
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
        width: 40,
        height: height,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$period',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Colors.grey[800])),
                const SizedBox(height: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(times[0], 
                        style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text(times.length > 1 ? times[1] : '', 
                        style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
