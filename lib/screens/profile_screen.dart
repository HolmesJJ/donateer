import 'package:donateer/provider/google_sign_in.dart';
import 'package:donateer/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import './login_screen.dart';
import './progress_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  String hoursDonated = 'No hours';

  double amountDonated = 0.00;

  List donated = [];

  String hoursToDonate = 'No hours';

  double amountToDonate = 0.00;

  List toDonate = [];

  String income = '';

  void initState() {
    _getUserInfo();
  }

  void _getUserInfo() async {
    int timeDonated = 0;
    int timeToDonate = 0;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    final data = doc.data() as Map<String, dynamic>;
    var donations = data['donations'];
    print("Donations");
    print(donations);
    donations.forEach((donation) {
      DateTime startTime = DateTime.parse(donation['start']);
      int duration = donation['duration'];
      double amount = donation['donationAmount'].toDouble();
      if (startTime.isBefore(DateTime.now())) {
        timeDonated += duration;
        amountDonated += amount;
        donated.add(donation);
      } else {
        timeToDonate += duration;
        amountToDonate += amount;
        toDonate.add(donation);
      }
    });
    print("Results:");
    print("Time donated");
    print(timeDonated);
    print("Amount donated");
    print(amountDonated);
    print("Time to donate");
    print(timeToDonate);
    print("Amount to donate");
    print(amountToDonate);

    print("Formated hours:");
    print(hoursDonated);
    print(hoursToDonate);
    setState(() {
      hoursDonated = _formatDuration(Duration(minutes: timeDonated));
      hoursToDonate = _formatDuration(Duration(minutes: timeToDonate));
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    int hours = duration.inHours;
    // never donate at all
    if (hours == 0 && duration.inMinutes == 0)
      return "${twoDigitMinutes} hours";
    // less than 1 hr
    if (hours < 1) {
      if (twoDigitMinutes == 1) return "${twoDigitMinutes} minute";
      return "${twoDigitMinutes} minutes";
    }
    // 1 hr or more, only show hour
    if (hours == 1) {
      return "${twoDigits(hours)} hour";
    } else {
      return "${twoDigits(hours)} hours";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(22),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Donateer Profile',
                  style: Theme.of(context).textTheme.headline1,
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () async {
                    final provider = Provider.of<GoogleSignInProvider>(
                      context,
                      listen: false,
                    );
                    // check if Google is used, if used then sign out
                    final GoogleSignIn googleSignIn = new GoogleSignIn();
                    googleSignIn.isSignedIn().then((s) {
                      provider.logout();
                    });
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.shade800,
                  foregroundColor: Colors.white,
                  radius: 40,
                  child: Text(
                    user!.displayName![0],
                    style: const TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Text(user!.displayName!,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        )),
                    OutlinedButton(
                      child: const Text('Edit Profile'),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            Card(
              color: Theme.of(context).secondaryHeaderColor,
              child: Column(
                children: [
                  ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset('assets/images/progress.png')),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        print("Donated");
                        print(donated);
                        print("To donate");
                        print(toDonate);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => ProgressScreen(
                                donated: donated, toDonate: toDonate),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    title: const Text(
                      'My Donateer Contributions',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    child: Card(
                      child: Align(
                        alignment: Alignment.center,
                        child: ListTile(
                          title: Text(hoursDonated, textAlign: TextAlign.center),
                          subtitle: const Text('total donateered', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 80,
                    child: Card(
                      child: Align(
                        alignment: Alignment.center,
                        child: ListTile(
                          title: Text(hoursToDonate, textAlign: TextAlign.center),
                          subtitle: const Text('upcoming this month', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    child: Card(
                      child: Align(
                        alignment: Alignment.center,
                        child: ListTile(
                          title: Text('\$ $amountDonated', textAlign: TextAlign.center),
                          subtitle: const Text('donations generated', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 80,
                    child: Card(
                      child: Align(
                        alignment: Alignment.center,
                        child: ListTile(
                          title: Text('\$ $amountToDonate', textAlign: TextAlign.center),
                          subtitle: const Text('more contributions pledged this month', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ), 
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Spacer(),
            const Text('SUPPORT'),
            const SizedBox(height: 5),
            Card(
              child: Column(
                children: [
                  ListTile(
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {},
                      ),
                      title: const Text('CONTACT US',
                          style: TextStyle(
                            fontSize: 14.0,
                          ))),
                  ListTile(
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {},
                      ),
                      title: const Text('FAQ',
                          style: TextStyle(
                            fontSize: 14.0,
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
