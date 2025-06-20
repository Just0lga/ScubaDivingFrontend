import 'package:flutter/material.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/cart_page.dart';
import 'package:scuba_diving/screens/favorites_page.dart';
import 'package:scuba_diving/screens/home_page.dart';
import 'package:scuba_diving/screens/profile_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    ProfilePage(),
    HomePage(),
    FavoritesPage(),
    CartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: ''),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      label: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(splashColor: Colors.black, highlightColor: Colors.black),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
          iconSize: 24,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorPalette.black,
          fixedColor: ColorPalette.primary,
          unselectedItemColor: ColorPalette.white,
          useLegacyColorScheme: false,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}
