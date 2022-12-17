import 'package:donateer/screens/organisations_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './profile_screen.dart';
import './favourites_screen.dart';

class TabsScreen extends StatefulWidget {
  final dynamic filter;
  final dynamic tabNo;
  const TabsScreen({Key? key, this.filter, this.tabNo}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  // late List<Widget> _pages;
  late int _selectedPageIndex;

  @override
  void initState() {
    _selectedPageIndex = widget.tabNo ?? 0;
    super.initState();
  }

  void selectPage(int index) {
    // print("RECEIVED USER:");
    // print(user);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      OrganisationsOverviewScreen(filter: widget.filter),
      const FavouritesScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectPage,
        selectedItemColor: Colors.black,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded), label: 'Favourites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
