import 'dart:core';

import 'package:donateer/screens/login_screen.dart';
import 'package:donateer/screens/register_details_screen.dart';
import 'package:donateer/screens/register_income_screen.dart';
import 'package:donateer/screens/tabs_screen.dart';
import 'package:flutter/material.dart';

class RouteManager {
  static const loginPage = '/login';
  static const registerDetails = '/login/user';
  static const registerIncome = '/login/income';
  static const tabsPage = '/tabs';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Map<String, dynamic> valuePassed;
    // if (settings.arguments != null) {
    //   valuePassed = settings.arguments as Map<String, dynamic>;
    // }

    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        });

      case registerDetails:
        return MaterialPageRoute(builder: (context) {
          return const RegisterDetailsScreen();
        });

      case registerIncome:
        return MaterialPageRoute(builder: (context) {
          return const RegisterIncomeScreen();
        });

      case tabsPage:
        return MaterialPageRoute(builder: (context) {
          return const TabsScreen();
        });

      default:
        throw const FormatException('Route not found, check routes!');
    }
  }
}
