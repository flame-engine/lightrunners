import 'dart:ui';

import 'package:lightrunners/ui/palette.dart';

class Player {
  final int slotNumber;
  final int? playerId;
  final String? gamepadId;
  final String? username;

  Player({
    required this.slotNumber,
    this.playerId,
    this.gamepadId,
    this.username,
  });

  Color get color => GamePalette.shipValues[slotNumber];

  Player copyWith({
    int? slotNumber,
    int? playerId,
    String? gamepadId,
    String? username,
  }) {
    return Player(
      slotNumber: slotNumber ?? this.slotNumber,
      playerId: playerId ?? this.playerId,
      gamepadId: gamepadId ?? this.gamepadId,
      username: username ?? this.username,
    );
  }
}
