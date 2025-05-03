import 'package:flutter/material.dart';
import '../../data/schools/school_service.dart';

class SchoolSelectionPage extends StatelessWidget {
  final String? currentSchool;
  final ValueChanged<String> onSchoolSelected;

  const SchoolSelectionPage({
    super.key,
    required this.currentSchool,
    required this.onSchoolSelected,
  });

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
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  onSchoolSelected(school);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
