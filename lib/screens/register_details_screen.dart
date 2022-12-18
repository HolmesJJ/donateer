import 'package:flutter/material.dart';
import './register_income_screen.dart';
import './login_screen.dart';

class RegisterDetailsScreen extends StatefulWidget {

  const RegisterDetailsScreen ({ Key? key }): super(key: key);

  @override
  _RegisterDetailsScreenState createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordTextController = TextEditingController();

  void trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterIncomeScreen(
              userEmail: _emailTextController.text,
              userName: _usernameController.text,
              userPassword: _passwordTextController.text),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Step 1/2:\nEnter your details \nto create an account',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const SizedBox(height: 12),
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
                    key: const ValueKey('username'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Please enter at least 4 characters';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Username'),
                    controller: _usernameController,
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
                    child: const Text('Continue'),
                    onPressed: trySubmit,
                  ),
                  TextButton(
                    child: const Text('Already have an account? Log In',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        )),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
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
