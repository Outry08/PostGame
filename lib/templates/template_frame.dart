import 'package:flutter/material.dart';
import 'package:postgame/common.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/templates/multiplayer.dart';
import 'package:postgame/templates/single_player.dart';

class TemplateFrame extends StatefulWidget {
  final GameModes? selectGameMode;
  final GameModel game;

  TemplateFrame({required this.selectGameMode, required this.game});

  @override
  _TemplateFrameState createState() => _TemplateFrameState();
}

class _TemplateFrameState extends State<TemplateFrame> {
  String? reviews = '';
  String userPost = '';
  TrackableType? postType = TrackableType.Achievement;
  late Map<GameModes, Widget> templates;

  @override
  void initState() {
    super.initState();
    // available game modes from end point https://api.igdb.com/v4/game_modes
    templates = {
      GameModes.SinglePlayer: SinglePlayer(game: widget.game),
      GameModes.Multiplayer: Multiplayer(game: widget.game),
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultTemplate = Container();

    if (widget.selectGameMode == null) {
      return defaultTemplate;
    }
    
    return templates[widget.selectGameMode] ?? defaultTemplate;
  }
}
