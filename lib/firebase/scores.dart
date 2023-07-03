import 'package:firedart/firedart.dart';
import 'package:lightrunners/firebase/score.dart';

class Scores {
  static late Firestore firestore;

  Scores._();

  static Future<void> init() async {
    // NOTE: This will not work. support was removed from the library
    const projectId = 'lightrunners-e89a9';
    Firestore.initialize(projectId);
    firestore = Firestore.instance;
  }

  static Future<List<Score>> topScores() async {
    final page = await firestore
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(10)
        .get();
    return page.map(Score.fromDocument).toList();
  }

  static Future<void> updateScore({
    required int playerId,
    required int score,
  }) async {
    final document =
        firestore.collection('scores').document(playerId.toString());
    if (await document.exists) {
      await document.update({'score': score});
    } else {
      print('Error: Score not found for player id $playerId.');
    }
  }
}
