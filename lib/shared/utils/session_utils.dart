import '../../bloc/services/discipline/models/discipline.dart';
import '../../bloc/services/journal/models/session.dart';

class SessionUtils {
  static Map<String, int> getDisciplinePlanStats({
    required Discipline discipline,
    required List<Session> sessions,
    required String sessionType,
    required List<Map<String, String>> lessonTypeOptions,
  }) {
    final typeKey = lessonTypeOptions
        .firstWhere((t) => t['label'] == sessionType, orElse: () => {})['key'];

    if (typeKey == null) return {'planned': 0, 'actual': 0};

    final planItem = discipline.planItems
        .where((item) => item.type.toLowerCase() == typeKey.toLowerCase())
        .firstOrNull;

    final actual = sessions
        .where((s) => s.type.toLowerCase() == sessionType.toLowerCase())
        .map((e) => e.id)
        .toSet()
        .length;

    return {
      'planned': planItem?.hoursAllocated ?? 0,
      'actual': actual * 2,
    };
  }

  String buildSessionStatsText({
    required String selectedType,
    required Discipline discipline,
    required List<Session> sessions,
    required List<Map<String, String>> lessonTypeOptions,
  }) {
    if (selectedType == 'Все') return '';

    final stats = SessionUtils.getDisciplinePlanStats(
      discipline: discipline,
      sessions: sessions,
      sessionType: selectedType,
      lessonTypeOptions: lessonTypeOptions,
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
