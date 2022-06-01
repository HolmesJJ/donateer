import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donateer/provider/google_sign_in.dart';
import 'package:donateer/screens/register_income_screen.dart';
import 'package:donateer/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:provider/provider.dart';

import './register_details_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  // Future<FirebaseApp> _initializeFirebase() async {
  //   FirebaseApp firebaseApp = await Firebase.initializeApp();

  //   User? user = FirebaseAuth.instance.currentUser;

  //   if (user != null) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => TabsScreen(),
  //       ),
  //     );
  //   }

  //   return firebaseApp;
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
      height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/auth_image.png',
                    height: 200, fit: BoxFit.fitWidth),
                Text('Welcome back.\nLogin to your account',
                    style: Theme.of(context).textTheme.headline1),
                SizedBox(height: 30),
                /*
                if (defaultTargetPlatform == TargetPlatform.iOS)
                  SignInWithAppleButton(
                    onPressed: () async {
                      final credential = await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      print(credential);
                      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                      // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                    },
                  ),
                  */
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                  ), 
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red[400],),
                  label: Text('Sign In with Google'), 
                  onPressed: () {
                    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogin().then((userCredential) async {
                      // User exists, if not do nothing
                      if (userCredential != null) {
                        print("1. User credential received");
                        print(userCredential);
                        print("User UID");
                        print(userCredential.user.uid);
                        // check if income is defined, if not redirect to income page
                        var firestoreUserData;
                        await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userCredential.user.uid)
                          .get().then((DocumentSnapshot doc) {
                            firestoreUserData = doc.data() as Map<String, dynamic>;
                            print("2. Firestore data:");
                            print(firestoreUserData);
                          },);
                        print("2. Firestore data:");
                        print(firestoreUserData);
                        if (!userCredential.additionalUserInfo.isNewUser && firestoreUserData.income) {
                          // Not a new Google user
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => TabsScreen(),
                            ),
                          );
                        } else {
                          // New Google user
                          Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => RegisterIncomeScreen(user: userCredential.user,),
                          ),
                          );
                        } 
                      };
                    },);
                  },
                ),
                SizedBox(height: 15),
                Text('— OR —'),
                SizedBox(height: 12),
                Text('Continue with your email'),
                TextFormField(
                  key: ValueKey('email'),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                  ),
                  controller: _emailTextController,
                ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordTextController,
                ),
                Spacer(),
                ElevatedButton(
                  child: Text('Log in'),
                  onPressed: () async {
                    _trySubmit();
                    User? user =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    ).then((UserCredential userCredential) {return userCredential.user});

                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TabsScreen(),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  child: Text('Create an account',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterDetailsScreen(),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
