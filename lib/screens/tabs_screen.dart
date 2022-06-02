import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donateer/screens/organisations_overview_screen.dart';
import 'package:donateer/screens/register_income_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './profile_screen.dart';
import './favourites_screen.dart';

class TabsScreen extends StatefulWidget {
  final filter;
  TabsScreen({Key? key, this.filter}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late List<Widget> _pages;

  void initState() {}

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    print("RECEIVED USER:");
    print(user);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      OrganisationsOverviewScreen(filter: widget.filter),
      FavouritesScreen(),
      ProfileScreen(),
    ];

    return FutureBuilder<Map>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get()
          .then(
        (DocumentSnapshot doc) {
          return doc.data() as Map<String, dynamic>;
          // ...
        },
      ),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (!snapshot.hasData) {
          // while data is loading:
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          print("DATABASE INFORMATION");
          print(snapshot.data);
          // data loaded:
          final userInformation = snapshot.data;
          print("Accessing user information from Firestore: ");
          print(userInformation);
          print(userInformation!['income']);
          if (userInformation!['income'] == "" ||
              userInformation!['income'] == null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => RegisterIncomeScreen(user: user),
              ),
              ModalRoute.withName('/'),
            );
          }
          return Scaffold(
            body: _pages[_selectedPageIndex],
            bottomNavigationBar: BottomNavigationBar(
              onTap: _selectPage,
              selectedItemColor: Colors.black,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline_rounded),
                    label: 'Favourites'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_outlined),
                    label: 'Profile'),
              ],
            ),
          );
        }
      },
    );
  }
}
