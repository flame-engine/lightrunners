import 'package:firedart/firestore/models.dart';

class Score {
  final int playerId;
  final String username;
  final int score;

  Score({
    required this.playerId,
    required this.username,
    required this.score,
  });

  Score.fromDocument(Document document)
      : this(
          playerId: document.map['playerId'] as int,
          username: document.map['username'] as String,
          score: document.map['score'] as int,
        );

  @override
  String toString() => '[$playerId] $username: $score';
}
