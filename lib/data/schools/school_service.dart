import 'school_config.dart';

class SchoolService {
  static Future<List<String>> getSchoolNames() async {
    return SchoolConfig.allSchools.map((school) => school.name).toList();
  }

  static Future<String?> getJsCode(String schoolName) async {
    final school = SchoolConfig.findByName(schoolName);
    return school?.jsCode;
  }

  static Future<String?> getEduUrl(String schoolName) async {
    final school = SchoolConfig.findByName(schoolName);
    return school?.eduSystemUrl;
  }

  static Future<void> addSchool(SchoolConfig newSchool) async {
    // 这里可以添加将新学校保存到本地或服务器的逻辑
  }
}
