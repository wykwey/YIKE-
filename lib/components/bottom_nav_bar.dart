import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/schedule_state.dart';
import 'timetable_management_dialog.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScheduleState>();
    final currentIndex = _getIndex(state.selectedView);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent, // 关闭点击水波纹
        highlightColor: Colors.transparent, // 关闭点击高亮
        hoverColor: Colors.transparent, // 关闭鼠标悬停背景
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 防止自动切换效果类型
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3) {
            showDialog(
              context: context,
              builder: (context) => const TimetableManagementDialog(),
            );
          } else {
            final views = ['周视图', '日视图', '列表视图'];
            state.changeView(views[index]);
          }
        },
        items: [
          _buildItem(context, Icons.calendar_view_week, '周视图', currentIndex == 0),
          _buildItem(context, Icons.calendar_today, '日视图', currentIndex == 1),
          _buildItem(context, Icons.list, '列表视图', currentIndex == 2),
          _buildItem(context, Icons.menu, '课表管理', currentIndex == 3),
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
      case '列表视图':
        return 2;
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
