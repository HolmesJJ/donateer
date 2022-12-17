import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donateer/provider/google_sign_in.dart';
import 'package:donateer/screens/register_income_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import './screens/login_screen.dart';
import './screens/tabs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  late Future<bool> hasIncome;
  bool hasUser = false;

  @override
  void initState() {
    hasIncome = checkIncome();
    super.initState();
  }

  Future<bool> checkIncome() async {
    user = FirebaseAuth.instance.currentUser;
    // print("CHECKING INCOME AND USER");
    // print("Has user?");
    if (user != null) {
      // print("Yes! User details:");
      // print(user);
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      // print("Retrieved data: ");
      // print(data);
      hasUser = true;
      return data.containsKey('income');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Donateer',
        theme: ThemeData(
            primarySwatch: Colors.red,
            primaryColor: HexColor('#FFFBFE'),
            secondaryHeaderColor: HexColor('#FCEEEE'),
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Buenard',
                  color: Colors.red[900]), // page titles
              headline2: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
              subtitle2: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45), backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.black,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            )),
        home: FutureBuilder<bool>(
          future: hasIncome,
          initialData: false,
          builder: (
            BuildContext context,
            AsyncSnapshot<bool> snapshot,
          ) {
            // print("Snapshot:");
            // print(snapshot);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      Visibility(
                        visible: snapshot.hasData,
                        child: const Text(
                          'Loading',
                          style: TextStyle(color: Colors.black, fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              // print("Has user 2nd check");
              // print(hasUser);
              // print(user);
              // No user at all
              if (!hasUser) {
                return const LoginScreen();
              }
              // Has user
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                if (snapshot.data!) {
                  // user has income
                  return const TabsScreen();
                } else {
                  // user has not entered income yet
                  return const RegisterIncomeScreen();
                }
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
