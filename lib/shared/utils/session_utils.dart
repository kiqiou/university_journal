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

    final planItem = discipline.planItems.firstWhere(
          (item) => item.type.toLowerCase().trim() == selectedKey?.toLowerCase().trim(),
      orElse: () => PlanItem(type: '', hoursAllocated: 0, hoursPerSession: 2),
    );

    return {
      'planned': planItem.hoursAllocated,
      'actual': actualSessions.length * 2,
    };
  }

  static Map<String, int> getDisciplinePlanStatsWithSubgroups({
    required Discipline discipline,
    required List<Session> sessions,
    required String selectedSessionType,
  }) {
    final selectedTypeMap = lessonTypeOptions.firstWhere(
          (type) => type['label'] == selectedSessionType,
      orElse: () => {},
    );

    final selectedKey = selectedTypeMap['key'];
    final planItem = discipline.planItems.firstWhere(
          (item) => item.type.toLowerCase().trim() == selectedKey?.toLowerCase().trim(),
      orElse: () => PlanItem(type: '', hoursAllocated: 0, hoursPerSession: 2),
    );

    final int hoursPerSession = planItem.hoursPerSession;
    int planned = planItem.hoursAllocated;
    int actualSub1 = 0;
    int actualSub2 = 0;

    final uniqueSessions = sessions
        .where((s) =>
    s.type.toLowerCase().trim() ==
        selectedSessionType.toLowerCase().trim())
        .fold<Map<int, Session>>({}, (map, session) {
      map[session.id] = session;
      return map;
    })
        .values
        .toList();

    for (final session in uniqueSessions) {
      if (session.subGroup == null) {
        actualSub1 += hoursPerSession;
        actualSub2 += hoursPerSession;
      } else if (session.subGroup == 1) {
        actualSub1 += hoursPerSession;
      } else if (session.subGroup == 2) {
        actualSub2 += hoursPerSession;
      }
    }

    return {
      'planned': planned,
      'actualSub1': actualSub1,
      'actualSub2': actualSub2,
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

  String buildSessionStatsTextWithSubgroups({
    required String selectedType,
    required Discipline discipline,
    required List<Session> sessions,
  }) {
    if (selectedType == 'Все') return '';

    final stats = SessionUtils.getDisciplinePlanStatsWithSubgroups(
      discipline: discipline,
      sessions: sessions,
      selectedSessionType: selectedType,
    );

    return 'Подгр.1: ${stats['planned']}/${stats['actualSub1']} ч. | '
        'Подгр.2: ${stats['planned']}/${stats['actualSub2']} ч. | ';
  }

  Map<String, List<Session>> groupSessions(List<Session> sessions) {
    return {
      'Все': sessions,
      for (final type in {'Лекция', 'Семинар', 'Практика', 'Лабораторная'})
        type: sessions.where((s) => s.type == type).toList(),
    };
  }
}
