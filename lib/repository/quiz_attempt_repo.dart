import 'package:learnquran/service/database.dart';
import 'package:logging/logging.dart';

const String tableQuizAttempt = 'quiz_attempt';
const String columnWordId = 'wordId';
const String columnIsCorrect = 'isCorrect';

class QuizAttemptRepo extends DbService {
  final log = Logger('QuizAttemptRepo');

  recordAttempt(String wordId, isCorrect) async {
    log.info('recordAttempt: $wordId $isCorrect');

    await insert(tableQuizAttempt, {
      'wordId': wordId,
      'isCorrect': isCorrect ? 1 : 0,
    });
  }

  getTotalWordIdsAttempted() async {
    return await query(tableQuizAttempt);
  }

  getWordAttemptsWithCount() async {
    var result = await query(tableQuizAttempt,
        distinct: true,
        columns: [columnWordId, columnIsCorrect, 'count(*) as total'],
        groupBy: "$columnWordId, $columnIsCorrect");

    var wordsAttemptMap = {};
    for (final row in result) {
      wordsAttemptMap[row[columnWordId]] ??= {columnWordId: row[columnWordId]};
      var key = row[columnIsCorrect] != 0 ? 'totalCorrect' : 'totalFailed';
      wordsAttemptMap[row[columnWordId]][key] = row['total'];
    }

    var wordAttempts = List.of(wordsAttemptMap.values);
    wordAttempts.sort((a, b) =>
        (b['totalFailed'] ?? 0 - b['totalCorrect'] ?? 0) -
        (a['totalFailed'] ?? 0 - a['totalCorrect'] ?? 0));
    return wordAttempts;
  }
}
