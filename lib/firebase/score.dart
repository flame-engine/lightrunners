import 'package:firedart/firestore/models.dart';

class Score {
  final int playerId;
  final String email;
  final int score;

  Score({
    required this.playerId,
    required this.email,
    required this.score,
  });

  Score.fromDocument(Document document)
      : this(
          playerId: document.map['playerId'] as int,
          email: document.map['email'] as String,
          score: document.map['score'] as int,
        );
}
