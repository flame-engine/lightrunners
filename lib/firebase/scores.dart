import 'dart:io';

import 'package:firebase_admin/firebase_admin.dart';
import 'package:firedart/firedart.dart';
import 'package:firedart/firestore/token_authenticator.dart';
import 'package:lightrunners/firebase/score.dart';
import 'package:uuid/uuid.dart';

class Scores {
  static const uuid = Uuid();
  static Firestore? _firestore;

  Scores._();

  static Future<String> _createCustomToken() => FirebaseAdmin.instance
      .initializeApp(
        AppOptions(
          credential: FirebaseAdmin.instance
              .certFromPath('.secrets/lightrunners-service-account.json'),
        ),
      )
      .auth()
      .createCustomToken(uuid.v4());

  static Future<void> init() async {
    const projectId = 'lightrunners-e89a9';
    final apiKey = File('.secrets/api-key.conf').readAsStringSync();

    final customToken = await _createCustomToken();

    final tokenStore = VolatileStore();

    final auth = FirebaseAuth(apiKey, tokenStore);
    await auth.signInWithCustomToken(customToken);

    final authenticator = TokenAuthenticator.from(auth)?.authenticate;
    _firestore = Firestore(projectId, authenticator: authenticator);
  }

  static Future<List<Score>> topScores() async {
    final firestore = _firestore;
    if (firestore == null) {
      print('Error: Firestore not initialized.');
      return [];
    }

    final page = await firestore
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(10)
        .get();
    final results = page.map(Score.fromDocument).toList();
    print('Fetch top scores: $results');
    return results;
  }

  static Future<void> updateScore({
    required int playerId,
    required int score,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      print('Error: Firestore not initialized.');
      return;
    }

    final document =
        firestore.collection('scores').document(playerId.toString());
    if (await document.exists) {
      print('Updating score for player id $playerId to $score.');
      await document.update({'score': score});
    } else {
      print('Error: Score not found for player id $playerId.');
    }
  }
}
