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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user = FirebaseAuth.instance.currentUser;
  bool hasIncome = false;
  bool isLoaded = false;

  @override
  void initState() {
    getIncome();
    super.initState();
  }

  getIncome() async {
    if (user != null) {
      var data = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      setState(() {
        isLoaded = true;
        hasIncome = data['income'] != null;
      });
    }
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
              //bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            ),
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                primary: Colors.black, //button color
                onPrimary: Colors.white,
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
                primary: Colors.black,
                //padding: EdgeInsets.symmetric(horizontal: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            )),
        // home: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (ctx, userSnapshot) {
        //     if (!userSnapshot.hasData) {
        //       return LoginScreen();
        //     }
        //     else if (hasIncome) {
        //       return TabsScreen();
        //     }
        //     return RegisterIncomeScreen();
        //   },
        // ),
        home: (user != null)
            // if user present, check if there is income
            ? (hasIncome ? TabsScreen() : RegisterIncomeScreen())
            // if no user and no income
            : LoginScreen(),
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
