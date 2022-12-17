import 'package:donateer/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  final List donated;
  final List toDonate;

  const ProgressScreen({Key? key, required this.donated, required this.toDonate})
      : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // print("Previous values");
    // print(widget.donated);
    // print(widget.toDonate);
  }

  String _formatExactDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)} hours $twoDigitMinutes minutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TabsScreen(tabNo: 2),
                        ),
                        (route) => false,
                      );
                    }),
                Text(
                  'My Donateer Contributions',
                  style: Theme.of(context).textTheme.headline1,
                ),
              ]),
              const SizedBox(height: 10),
              const Text('UPCOMING DONATEER SESSIONS',
                  style: TextStyle(
                    fontSize: 15.0,
                  )),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        title: Text(
                          widget.toDonate[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _formatExactDuration(
                                Duration(
                                  minutes: widget.toDonate[index]['duration'],
                                ),
                              ) +
                              '\n' +
                              widget.donated[index]['date'],
                        ),
                        trailing: Image.network(widget.donated[index]['iconUrl'])
                        // trailing: IconButton(
                        //   icon: Icon(
                        //     Icons.delete,
                        //     color: Theme.of(context).errorColor,
                        //   ),
                        //   onPressed: () =>
                        //       deleteTransaction(transactions[index].id),
                        // ),
                      ),
                    ),
                  );
                },
                itemCount: widget.toDonate.length,
              ),
              const SizedBox(height: 10),
              const Text('CONFIRMED CONTRIBUTIONS',
                  style: TextStyle(
                    fontSize: 15.0,
                  )),
              const SizedBox(height: 7),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        title: Text(
                          widget.donated[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _formatExactDuration(
                                Duration(
                                  minutes: widget.donated[index]['duration'],
                                ),
                              ) +
                              '\n' +
                              widget.donated[index]['date'],
                        ),
                        trailing: Image.network(widget.donated[index]['iconUrl'])
                        // trailing: IconButton(
                        //   icon: Icon(
                        //     Icons.delete,
                        //     color: Theme.of(context).errorColor,
                        //   ),
                        //   onPressed: () =>
                        //       deleteTransaction(transactions[index].id),
                        // ),
                      ),
                    ),
                  );
                },
                itemCount: widget.donated.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
