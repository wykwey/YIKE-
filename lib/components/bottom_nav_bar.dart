import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import '../../views/settings_view.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScheduleState>();
    final currentIndex = _getIndex(state.selectedView);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey[600],
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 防止自动切换效果类型
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          } else {
            final views = ['周视图', '日视图'];
            state.changeView(views[index]);
          }
        },
        items: [
          _buildItem(context, Icons.calendar_view_week, '周视图', currentIndex == 0),
          _buildItem(context, Icons.calendar_today, '日视图', currentIndex == 1),
          _buildItem(context, Icons.settings, '设置', currentIndex == 2),
        ],
      ),
    );
  }

  int _getIndex(String view) {
    switch (view) {
      case '周视图':
        return 0;
      case '日视图':
        return 1;
      default:
        return 0;
    }
  }

  BottomNavigationBarItem _buildItem(
    BuildContext context,
    IconData icon,
    String label,
    bool selected,
  ) {
    final iconColor = selected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          icon,
          key: ValueKey(selected),
          color: iconColor,
        ),
      ),
      label: label,
    );
  }
}
