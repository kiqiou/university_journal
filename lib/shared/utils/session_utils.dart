import '../../bloc/services/discipline/models/discipline.dart';
import '../../bloc/services/discipline/models/discipline_plan.dart';
import '../../bloc/services/journal/models/session.dart';
import '../../components/constants/constants.dart';

class SessionUtils {
  static Map<String, int> getDisciplinePlanStats({
    required Discipline discipline,
    required List<Session> sessions,
    required String selectedSessionType,
  }) {
    final selectedTypeMap = lessonTypeOptions.firstWhere(
          (type) => type['label'] == selectedSessionType,
      orElse: () => {},
    );

    final selectedKey = selectedTypeMap['key'];

    // ✅ Сравнение по локализованному — потому что в Session.type лежит 'Лекция'
    final actualSessions = sessions
        .where((s) =>
    s.type.toLowerCase().trim() ==
        selectedSessionType.toLowerCase().trim())
        .fold<Map<int, Session>>({}, (map, session) {
      map[session.id] = session;
      return map;
    })
        .values
        .toList();

    print("SelectedSessionType: $selectedSessionType, Key: $selectedKey");
    print("Matched sessions: ${actualSessions.length}");

    // ✅ Сравнение по ключу — потому что в planItem.type лежит 'lecture'
    final planItem = discipline.planItems.firstWhere(
          (item) => item.type.toLowerCase().trim() == selectedKey?.toLowerCase().trim(),
      orElse: () => PlanItem(type: '', hoursAllocated: 0, hoursPerSession: 2),
    );

    return {
      'planned': planItem.hoursAllocated,
      'actual': actualSessions.length * 2,
    };
  }

  String buildSessionStatsText({
    required String selectedType,
    required Discipline discipline,
    required List<Session> sessions,
  }) {
    if (selectedType == 'Все') return '';

    final stats = SessionUtils.getDisciplinePlanStats(
      discipline: discipline,
      sessions: sessions,
      selectedSessionType: selectedType,
    );

    return '${stats['planned']} ч. запланировано / ${stats['actual']} ч. проведено';
  }

  Map<String, List<Session>> groupSessions(List<Session> sessions) {
    return {
      'Все': sessions,
      for (final type in {'Лекция', 'Семинар', 'Практика', 'Лабораторная'})
        type: sessions.where((s) => s.type == type).toList(),
    };
  }
}
