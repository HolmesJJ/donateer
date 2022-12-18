import 'package:donateer/provider/google_sign_in.dart';
import 'package:donateer/screens/register_income_screen.dart';
import 'package:donateer/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import './register_details_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen ({ Key? key }): super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

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
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Image.asset('assets/images/auth_image.png',
                      height: 200, fit: BoxFit.fitWidth),
                  Text('Welcome back.\nLogin to your account',
                      style: Theme.of(context).textTheme.headline1),
                  const SizedBox(height: 30),
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
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                    ), 
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red[400],),
                    label: const Text('Sign In with Google'), 
                    onPressed: () {
                      final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                      provider.googleLogin().then((userCredential) => {
                        // User exists and is a new Google user
                          if (userCredential != null) {
                            if (!userCredential.additionalUserInfo.isNewUser) {
                            // Not a new Google user
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const TabsScreen(),
                              ),
                            ),
                          } else {
                              Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => RegisterIncomeScreen(user: userCredential.user,),
                              ),
                            ),
                          } 
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('— OR —'),
                  const SizedBox(height: 12),
                  const Text('Continue with your email'),
                  TextFormField(
                    key: const ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    controller: _emailTextController,
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordTextController,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('LOGIN'),
                    onPressed: () async {
                      _trySubmit();
                      User? user =
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text,
                      ).then((UserCredential userCredential) {return userCredential.user;});
                      if (user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const TabsScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('Create an account',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterDetailsScreen(),
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
