import 'package:flutter/material.dart';
import 'package:postgame/main.dart';
import 'package:postgame/pages/home_page.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final List<String> routes = <String>[
    "/",
    "/search",
    "/create",
    "/explore",
    "/profile"
  ];

  final List<String> navButtonNames = [
    "Home",
    "Search",
    "Create",
    "Explore",
    "Profile"
  ];

  final List<IconData> idleNavButtonIcons = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.add_box_outlined,
    Icons.explore_outlined,
    Icons.person_outline
  ];

  final List<IconData> activeNavButtonIcons = [
    Icons.home,
    Icons.saved_search,
    Icons.add_box,
    Icons.explore,
    Icons.person
  ];

  List<BottomNavigationBarItem> setNavBar(BuildContext context, bool isDark) {
    List<BottomNavigationBarItem> navButtons = [];
    for (int i = 0; i < 5; i++) {
      navButtons.add(BottomNavigationBarItem(
          icon: Icon(idleNavButtonIcons[i]),
          activeIcon: Icon(activeNavButtonIcons[i]),
          label: '',
          backgroundColor: context.read<PostGameProvider>().tertiaryColor));
    }

    return navButtons;
  }

  void _onItemTapped(int index) {
    Provider.of<PostGameProvider>(context, listen: false).pageIndex = index;

    setState(() {
      Navigator.pushNamed(context, routes[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<PostGameProvider>().isDark;
    int pageIndex = context.watch<PostGameProvider>().pageIndex;

    return BottomNavigationBar(
      items: setNavBar(context, isDark),
      type: BottomNavigationBarType
          .fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: (context.read<PostGameProvider>().tertiaryColor),
      unselectedItemColor: (context.read<PostGameProvider>().oppColor),
      selectedItemColor: (context.read<PostGameProvider>().oppColor),
      currentIndex: pageIndex,
      onTap: _onItemTapped,
    );
  }
}
