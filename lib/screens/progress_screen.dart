import 'dart:io';

import 'package:donateer/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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

  final _screenshotController = ScreenshotController();

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

  Future<String> saveImage(Uint8List bytes, String name) async {
    await [Permission.storage].request();
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result["filePath"];
  }

  saveAndShare(Uint8List bytes, String name) async {
    await [Permission.storage].request();
    final directory = await getApplicationDocumentsDirectory();
    final image = File("${directory.path}/$name.png");
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path], text: "Hey, I would like to share my donateer contributions with you!");
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                        const Text(
                          'My Donateer Contributions',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                    ]),
                  IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () async {
                        final image = await _screenshotController.capture();
                        if (image == null) return;
                        saveAndShare(image, "donateer");
                        // saveImage(image, "donateer");
                      }),
                ]),
                const SizedBox(height: 10),
                const Text('UPCOMING DONATEER SESSIONS',
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
                if (widget.toDonate.isNotEmpty)
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
                                  widget.toDonate[index]['date'],
                            ),
                            trailing: Image.network(widget.toDonate[index]['iconUrl'])
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
                const SizedBox(height: 10),
                if (widget.donated.isNotEmpty)
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
      ),
    );
  }
}
