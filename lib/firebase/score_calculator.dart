import 'package:collection/collection.dart';
import 'package:lightrunners/game/player.dart';

class _PlayerScore {
  final Player player;
  int score = 0;

  _PlayerScore(this.player);

  @override
  String toString() => '$player: $score';
}

class ScoreCalculator {
  ScoreCalculator._();

  static Map<Player, int> computeScores(Map<Player, int> points) {
    final scores = points.entries
        .toList()
        .sortedBy<num>((entry) => -entry.value)
        .map((entry) => _PlayerScore(entry.key))
        .toList();

    final numPlayers = points.length;
    final totalScore = points.values.reduce((a, b) => a + b);

    var jackpot = numPlayers;
    if (jackpot == 0 || totalScore == 0) {
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
      scores.where((e) => e.score > 0).map((e) => MapEntry(e.player, e.score)),
    );
  }
}
