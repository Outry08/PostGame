import 'package:flutter/widgets.dart';

enum TrackableType { Progression, Achievement, Review, Update, None }

// game modes we support
enum GameModes { SinglePlayer, Multiplayer }

extension GameModesExtension on GameModes {
  String toDisplayString() {
    switch (this) {
      case GameModes.SinglePlayer:
        return 'Single Player';
      case GameModes.Multiplayer:
        return 'Multiplayer';
    }
  }
}
