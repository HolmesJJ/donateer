import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donateer/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String income = '0';
  String _hourlyIncome = '0';
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameTextController = TextEditingController();
  late TextEditingController _emailTextController = TextEditingController();
  late TextEditingController _incomeController = TextEditingController();

  @override
  void initState() {
    _getUserInfo();
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .update({
        'username': _nameTextController.text,
        'email': _emailTextController.text,
        'income': _incomeController.text,
        'hourlyIncome': _hourlyIncome,
      });
      navigateBack();
    }
  }

  void _getUserInfo() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    final data = doc.data() as Map<String, dynamic>;
    print("Retrieved data");
    print(data);
    setState(() {
      _nameTextController = TextEditingController(text: data['username']);
      _emailTextController = TextEditingController(text: data['email']);
      _incomeController = TextEditingController(text: data['income']);
      _hourlyIncome = ((int.parse(data['income']) / 160).floor()).toString();
    });
  }

  ImageProvider _getProfileImage() {
    if (user!.photoURL != null) {
      return NetworkImage(user!.photoURL!);
    }
    return const AssetImage('assets/images/smile.png');
  }

  void navigateBack() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => TabsScreen(tabNo: 2),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    print("User:");
    print(user);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              navigateBack();
            }),
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _getProfileImage(),
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
                  controller: _nameTextController,
                ),
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _hourlyIncome =
                          ((int.parse(value) / 160).floor()).toString();
                    });
                  },
                  decoration: const InputDecoration(
                      labelText: "Enter your monthly income (optional)"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: _incomeController,
                ),
                const SizedBox(height: 12),
                Text('Estimated hourly income: \$$_hourlyIncome'),
                const Spacer(),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: _trySubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
