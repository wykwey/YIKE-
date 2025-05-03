class SchoolConfig {
  final String name;
  final String eduSystemUrl;
  final String jsCode;

  const SchoolConfig({
    required this.name,
    required this.eduSystemUrl,
    required this.jsCode,
  });

  static const List<SchoolConfig> allSchools = [
    SchoolConfig(
      name: '清华大学',
      eduSystemUrl: 'https://edu.tsinghua.edu.cn',
      jsCode: r'''
        // 清华大学教务系统JS代码
        function getCourses() {
          // 爬取课程表的逻辑
        }
      ''',
    ),
    SchoolConfig(
      name: '北京大学', 
      eduSystemUrl: 'https://edu.pku.edu.cn',
      jsCode: r'''
        // 北京大学教务系统JS代码
        function parseTimetable() {
          // 解析课表的逻辑
        }
      ''',
    ),
    SchoolConfig(
      name: '河南大学',
      eduSystemUrl: 'https://jw.henu.edu.cn',
      jsCode: r'''
async function scheduleHtmlProvider() {
  try {
    const weekInfoRes = await fetch("/kcb/api/week?schoolYear");
    if (!weekInfoRes.ok)
      throw new Error(`Failed to fetch week info: ${weekInfoRes.statusText}`);

    const weekInfoData = await weekInfoRes.json();
    const { schoolYear, schoolTerm, week } = weekInfoData.response;

    const courseRes = await fetch(
      `/kcb/api/course?schoolYear=${schoolYear}&schoolTerm=${schoolTerm}&week=${week}`,
      {
        method: "GET",
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      }
    );

    if (!courseRes.ok)
      throw new Error(`Failed to fetch course data: ${courseRes.statusText}`);

    const courseData = await courseRes.json();
    return JSON.stringify(courseData);
  } catch (error) {
    console.error("课程表数据获取失败:", error);
    return "do not continue";
  }
}

function scheduleHtmlParser(stringify) {
  const parsedData = JSON.parse(stringify);

  function parseWeeks(weeksStr) {
    if (!weeksStr) return [];
    let weeks = [];
    weeksStr.split(",").forEach((range) => {
      range = range.trim();
      if (range.includes("-")) {
        const [start, end] = range.split("-").map(Number);
        weeks = weeks.concat(Array.from({ length: end - start + 1 }, (_, i) => start + i));
      } else {
        weeks.push(Number(range));
      }
    });
    return [...new Set(weeks)].sort((a, b) => a - b);
  }

  function parseSections(sectionStr) {
    if (!sectionStr) return [];
    return sectionStr.includes("-")
      ? sectionStr.split("-").map(Number)
      : [Number(sectionStr)];
  }

  function getDayOfWeek(dateStr) {
    if (!dateStr) return null;
    const formattedDateStr = dateStr.replace(
      /(\d{4})\/(\d{1,2})\/(\d{1,2})/,
      "$1-$2-$3"
    );
    const date = new Date(formattedDateStr);
    const day = date.getDay();
    return day === 0 ? 7 : day;
  }

  const transformedData = parsedData.response.flatMap((item) => {
    const dayOfWeek = getDayOfWeek(item.day);
    return item.data.map((course) => ({
      name: course.courseName,
      position: course.classRoom,
      teacher: course.teacherName,
      weeks: parseWeeks(course.weeks),
      day: dayOfWeek,
      sections: parseSections(course.section),
    }));
  });

  const uniqueCourses = [];
  const seen = new Set();

  for (const course of transformedData) {
    const key = `${course.name}-${course.position}-${course.weeks.join(",")}-${course.day}-${course.sections.join(",")}`;
    if (!seen.has(key)) {
      seen.add(key);
      uniqueCourses.push(course);
    }
  }

  return uniqueCourses;
}

(async () => {
  const scheduleData = await scheduleHtmlProvider();
  if (scheduleData !== "do not continue") {
    const result = scheduleHtmlParser(scheduleData);
    console.log('课程表数据:', result);
    DataChannel.postMessage(JSON.stringify(result));
  } else {
    console.log('获取课程表数据失败');
  }
})();
''',
    ),
    // 可以继续添加更多学校配置
  ];

  static SchoolConfig? findByName(String name) {
    try {
      return allSchools.firstWhere((school) => school.name == name);
    } catch (e) {
      return null;
    }
  }
}
