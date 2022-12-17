import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/donate_dialog.dart';
import './organisation_details_screen.dart';

class DonationScreen extends StatelessWidget {
  final Map obj;
  User? user = FirebaseAuth.instance.currentUser;

  DonationScreen({Key? key, required this.obj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrganisationDetailsScreen(obj: obj),
                  ),
                  (route) => false,
                );
              }),
          title: Text(obj['name']),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.favorite_outline_rounded),
                onPressed: () {})
          ]),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(obj['imageUrl'],
                height: 250, fit: BoxFit.fitWidth),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(obj["donateMessage"]),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: ElevatedButton(
                  child: const Text('DONATE YOUR TIME'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DonateDialog(name: obj['name'], obj: obj);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
