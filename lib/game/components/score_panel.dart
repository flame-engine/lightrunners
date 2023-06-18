import 'package:flame/components.dart';
import 'package:lightrunners/game/components/score_box.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/constants.dart';

class ScorePanel extends PositionComponent with HasGameRef<LightRunnersGame> {
  @override
  void onLoad() {
    addAll(
      gameRef.ships.values.map(
        (ship) => ScoreBox(
          shipRef: ship,
          targetPosition: _computeTarget(ship.playerNumber),
        ),
      ),
    );
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
