import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:postgame/igdb/igdb.dart';
import 'package:postgame/igdb/igdbModels.dart';

class PostGameProvider extends ChangeNotifier {
  PostGameProvider({TwitchIGDBApi? api = null}) {
    _igdbResource = api;
  }

  bool _isDark =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
  int _pageIndex = 0;

  TwitchIGDBApi? _igdbResource;

  List<GameModel> _listGamesSearch = [];
  List<Map<String, dynamic>> _listUsersSearch = [];

  String _currUid = "";

  /*
  Index key:
  0 - Dark
  1 - Light
  2 - Purple
  3 - Blue
  */
  int _colorIndex = 0;
  final List<Color> _primaryColors = [
    Colors.grey.shade800,
    Colors.grey,
    Colors.deepPurple.shade400,
    Colors.indigo.shade400,
  ];
  final List<Color> _secondaryColors = [
    Color(0xFF323232),
    Colors.white,
    Colors.deepPurple.shade800,
    Colors.indigo.shade700,
  ];
  final List<Color> _tertiaryColors = [
    Color(0xFF282828),
    Colors.white,
    Colors.deepPurple.shade900,
    Colors.indigo.shade900,
  ];
  final List<Color> _oppColors = [
    Colors.white,
    Color(0xFF323232),
    Colors.white,
    Colors.white
  ];

  Color _accentColor = Color(0xFF0139B5);
  Color _accentColor2 = Color(0xFF424242);
  Color _accentColor3 = Color(0xFF828282);

  set isDark(bool pref) {
    _isDark = pref;
    notifyListeners();
  }

  set pageIndex(int index) {
    _pageIndex = index;
  }

  set colorIndex(int index) {
    _colorIndex = index;
  }

  set currUid(String uid) {
    _currUid = uid;
  }

  set listGamesSearch(List<GameModel> list) {
    _listGamesSearch = list;
    notifyListeners();
  }

  set listUsersSearch(List<Map<String, dynamic>> list) {
    _listUsersSearch = list;
    notifyListeners();
  }

  bool get isDark => _isDark;
  int get pageIndex => _pageIndex;

  int get colorIndex => _colorIndex;
  Color get primaryColor => _primaryColors[_colorIndex];
  Color get secondaryColor => _secondaryColors[_colorIndex];
  Color get tertiaryColor => _tertiaryColors[_colorIndex];
  Color get oppColor => _oppColors[_colorIndex];
  Color get accentColor => _accentColor;
  Color get accentColor2 => _accentColor2;
  Color get accentColor3 => _accentColor3;

  TwitchIGDBApi? get igdbResource => _igdbResource;
  List<GameModel> get listGamesSearch => _listGamesSearch;
  List<Map<String, dynamic>> get listUsersSearch => _listUsersSearch;

  String get currUid => _currUid;
}
