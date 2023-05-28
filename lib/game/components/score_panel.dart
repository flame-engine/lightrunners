import 'package:flame/components.dart';
import 'package:flutter_con_game/game/components/score_box.dart';
import 'package:flutter_con_game/game/lightrunners_game.dart';
import 'package:flutter_con_game/utils/constants.dart';

class ScorePanel extends PositionComponent with HasGameRef<LightRunnersGame> {
  @override
  Future<void> onLoad() async {
    final promises = gameRef.ships.values.map((ship) {
      return ScoreBox(
        shipRef: ship,
        targetPosition: _computeTarget(ship.playerNumber),
      );
    }).map((e) async => await add(e));
    await Future.wait(promises);
    return super.onLoad();
  }

  Vector2 _computeTarget(int idx) {
    return Vector2(
      gameRef.playArea.right + scoreBoxMargin,
      gameRef.playArea.top +
          idx * (gameRef.playArea.height / maxShips) +
          scoreBoxMargin * idx,
    );
  }
}
