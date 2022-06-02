import 'package:donateer/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterIncomeScreen extends StatefulWidget {
  RegisterIncomeScreen({
    Key? key,
    this.userEmail,
    this.userName,
    this.userPassword,
    this.user,
  }) : super(key: key);

  String? userEmail;
  String? userName;
  String? userPassword;
  User? user;

  @override
  _RegisterIncomeScreenState createState() => _RegisterIncomeScreenState();
}

class _RegisterIncomeScreenState extends State<RegisterIncomeScreen> {
  String _income = '';
  var _isLoading = false;
  var isGoogleUser;

  void initState() {
    isGoogleUser = widget.user != null;
  }

  // List of items in our dropdown menu
  var items = [
    'Below \$1000',
    '\$1000 to \$2999',
    '\$3000 to \$4999',
    '\$5000 to \$6999',
    '\$7000 to \$8999',
    '\$9000 to \$10999',
    '\$11000 to \$12999',
    '\$13000 to \$14999',
    '\$15000 and above',
  ];

  @override
  Widget build(BuildContext context) {
    print("REACHED INCOME PAGE");
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                children: <Widget>[
                  Text('Step 2/2:\nLet’s help you set an estimate of your hourly income!',
                      style: Theme.of(context).textTheme.headline1),
                  SizedBox(height: 15),
                  Text(
                      'This information is needed to calculate how much money should be donated according to the number of hours you choose to volunteer. It is strictly confidential and will not be disclosed to any third-parties.',
                      ),
                  SizedBox(height: 20),    
                
                  Form( 
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _income = ((int.parse(value) / 160).floor()).toString();
                        });
                      },
                      decoration: InputDecoration(labelText: "Enter your monthly income"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  Text('Estimated hourly income: \$${_income}'),
                  
                  Spacer(),
                  ElevatedButton(
                    child: Text('Finish'),
                    onPressed: () async {
                      if (!isGoogleUser) {
                        User? user = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: widget.userEmail!,
                                password: widget.userPassword!)
                            .then((UserCredential userCredential) {return userCredential.user});
                        await user!.updateDisplayName(widget.userName).then((value) => null);

                        await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .set({
                        'username': widget.userName,
                        'email': widget.userEmail,
                        'income': _income,
                      });
                      } else {
                        await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.user!.uid)
                          .update({
                            'income': _income,
                        });
                      };
                      Navigator.of(context)
                        .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>
                                TabsScreen(),
                          ),
                          ModalRoute.withName('/'),
                      );
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
