import 'dart:ui';

import 'package:flame/components.dart';
import 'package:lightrunners/game/components/score_box.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/constants.dart';
import 'package:lightrunners/utils/utils.dart';

class ScorePanel extends RectangleComponent
    with HasGameReference<LightRunnersGame> {
  @override
  void onLoad() {
    final left = fixedSize.x - scoreBoxWidth - 2 * scoreBoxMargin;
    position = Vector2(left, screenMargin) - fixedSize / 2;
    size = Vector2(scoreBoxWidth, fixedSize.y - screenMargin * 2);
    paint = Paint()..color = GamePalette.black;
    addAll(
      game.ships.values.map(
        (ship) => ScoreBox(
          shipRef: ship,
          position: _computeTarget(ship.player.slotNumber),
        ),
      ),
    );
  }

  Vector2 _computeTarget(int idx) {
    return Vector2(0, idx * (size.y / maxShips) + scoreBoxMargin * idx);
  }
}
