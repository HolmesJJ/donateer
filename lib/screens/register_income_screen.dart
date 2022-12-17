import 'package:donateer/screens/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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
  User? user = FirebaseAuth.instance.currentUser;
  String _income = '';
  String _hourlyIncome = '';
  TextEditingController incomeController = new TextEditingController();
  var _isLoading = false;
  var isGoogleUser = true;

  void initState() {
    setState(() {
      isGoogleUser = user != null;
    });
    super.initState();
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
    return Scaffold(
      body: SafeArea(
      minimum: EdgeInsets.all(22),
      child: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height - 44,
              child: Column(
                children: <Widget>[
                  Text('Step 2/2:\nLet’s help you set an estimate of your hourly income!',
                      style: Theme.of(context).textTheme.headline1),
                  const SizedBox(height: 15),
                  const Text(
                      'This information is needed to calculate how much money should be donated according to the number of hours you choose to donateer. It is strictly confidential and will not be disclosed to any third-parties.',
                      ),
                  const SizedBox(height: 20),    
                
                  Form( 
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _hourlyIncome = ((int.parse(value) / 160).floor()).toString();
                        });
                      },
                      decoration: const InputDecoration(labelText: "Enter your monthly income (optional)"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: incomeController,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  Text('Estimated hourly income: \$$_hourlyIncome'),
                  
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Finish'),
                    onPressed: () async {
                      if (widget.userName != null) {
                        User? user = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: widget.userEmail!,
                                password: widget.userPassword!)
                            .then((UserCredential userCredential) {return userCredential.user;});
                        await user!.updateDisplayName(widget.userName).then((value) => null);

                        await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .set({
                        'username': widget.userName,
                        'email': widget.userEmail,
                        'income': incomeController.text,
                        'hourlyIncome': _hourlyIncome,
                      });
                      } else {
                        await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user!.uid)
                          .update({
                            'income': incomeController.text,
                            'hourlyIncome': _hourlyIncome,
                        });
                      };
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IntroductionScreen(),
                        ),
                        (route) => false,
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
