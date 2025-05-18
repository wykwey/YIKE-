import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timetable_state.dart';
import 'view_state.dart';
import 'week_state.dart';

class StateCoordinator extends StatefulWidget {
  final Widget child;
  
  const StateCoordinator({super.key, required this.child});
  
  @override
  _StateCoordinatorState createState() => _StateCoordinatorState();
}

class _StateCoordinatorState extends State<StateCoordinator> {
  @override
  void initState() {
    super.initState();
    // 延迟执行以确保Provider已经准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStates();
    });
  }
  
  Future<void> _initializeStates() async {
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final viewState = Provider.of<ViewState>(context, listen: false);
    final weekState = Provider.of<WeekState>(context, listen: false);
    
    // 确保先加载课表数据
    // timetableState会在构造函数中自动初始化
    
    // 等待一段时间确保timetableState已完成初始化
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 初始化后加载其他状态
    final timetable = timetableState.currentTimetable;
    await viewState.loadFromTimetable(timetable);
    await weekState.loadFromTimetable(timetable);
    
    // 监听课表切换
    timetableState.addListener(() {
      final currentTimetable = timetableState.currentTimetable;
      viewState.loadFromTimetable(currentTimetable);
      weekState.loadFromTimetable(currentTimetable);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 