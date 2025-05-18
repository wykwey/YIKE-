import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/schools/school_service.dart';
import '../../states/timetable_state.dart';
import 'package:provider/provider.dart';

class SchoolSelectionPage extends StatelessWidget {
  final String? currentSchool;
  final ValueChanged<String> onSchoolSelected;

  const SchoolSelectionPage({
    super.key,
    required this.currentSchool,
    required this.onSchoolSelected,
  });

  Future<void> _selectSchool(String schoolName, BuildContext context) async {
    // 保存到全局设置
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('globalSchool', schoolName);
    
    // 更新当前课表设置
    final timetableState = Provider.of<TimetableState>(context, listen: false);
    final timetable = timetableState.currentTimetable;
    if (timetable != null) {
      timetable.settings['school'] = schoolName;
      await timetableState.updateTimetable(timetable);
    }
    
    onSchoolSelected(schoolName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择学校'),
      ),
      body: FutureBuilder<List<String>>(
        future: SchoolService.getSchoolNames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final schools = snapshot.data!;
          return ListView.builder(
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return ListTile(
                title: Text(school),
                trailing: school == currentSchool 
                    ? Icon(Icons.check, color: Colors.blue.shade400)
                    : null,
                onTap: () => _selectSchool(school, context),
              );
            },
          );
        },
      ),
    );
  }
}
