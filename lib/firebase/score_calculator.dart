import 'package:collection/collection.dart';
import 'package:lightrunners/game/player.dart';

class _PlayerScore {
  final Player player;
  int score = 0;

  _PlayerScore(this.player);
}

class ScoreCalculator {
  ScoreCalculator._();

  static Map<Player, int> computeScores(Map<Player, int> points) {
    final scores = points.entries
        .toList()
        .sortedBy<num>((entry) => entry.value)
        .map((entry) => _PlayerScore(entry.key));

    final numPlayers = points.length;
    final totalScore = points.values.reduce((a, b) => a + b);

    var jackpot = numPlayers;
    if (jackpot == 0) {
      return {};
    }

    scores.first.score = 1;
    for (final playerScore in scores) {
      final point = points[playerScore.player]!;
      final ratio = point / totalScore;

      final score = (ratio * jackpot).ceil().clamp(0, jackpot);
      playerScore.score += score;
      jackpot -= score;
      if (jackpot == 0) {
        break;
      }
    }

    return Map.fromEntries(
      scores
          .map((score) => MapEntry(score.player, score.score))
          .where((element) => element.value > 0),
    );
  }
}
