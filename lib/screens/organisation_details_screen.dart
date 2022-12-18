import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import './tabs_screen.dart';
import 'donation_screen.dart';

class OrganisationDetailsScreen extends StatefulWidget {
  final Map obj;
  final User? user = FirebaseAuth.instance.currentUser;

  OrganisationDetailsScreen({Key? key, required this.obj}) : super(key: key);

  @override
  _OrganisationDetailsScreenState createState() =>
      _OrganisationDetailsScreenState();
}

class _OrganisationDetailsScreenState extends State<OrganisationDetailsScreen> {
  bool isFavourite = false;
  dynamic data;
  List _favourites = [];
  YoutubePlayerController? _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    initVideo();
    getData();
  }

  @override
  void deactivate() {
    pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    releaseVideo();
    super.dispose();
  }

  getData() async {
    data = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.user!.uid)
        .get();
    setState(() {
      if (data['favourites'] != null) {
        _favourites = data['favourites'];
      } else {
        _favourites = [];
      }
    });
    if (_favourites.contains(widget.obj['name'])) {
      setState(() {
        isFavourite = true;
      });
    } else {
      setState(() {
        isFavourite = false;
      });
    }
  }

  updateFirestoreFavourites() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.user!.uid)
        .update({'favourites': _favourites});
  }

  initVideo() {
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.obj['videoUrl'],
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  pauseVideo() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.pause();
    }
  }

  releaseVideo() {
    if (_youtubePlayerController != null) {
      _youtubePlayerController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                pauseVideo();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TabsScreen(),
                  ),
                  (route) => false,
                );
              }),
          title: Text(widget.obj['name']),
          actions: <Widget>[
            IconButton(
                icon: isFavourite
                    ? Icon(
                        Icons.favorite,
                        color: Colors.red[400],
                      )
                    : const Icon(Icons.favorite_outline_rounded),
                onPressed: () {
                  setState(() {
                    isFavourite = !isFavourite;
                    if (isFavourite) {
                      _favourites.add(widget.obj['name']);
                    } else {
                      _favourites.remove(widget.obj['name']);
                    }
                  });
                  updateFirestoreFavourites();
                })
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_youtubePlayerController != null)
              YoutubePlayer(
                controller: _youtubePlayerController!,
              ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'ABOUT US',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 7),
                        Text(widget.obj['description'].replaceAll("\\n", "\n")),
                        const SizedBox(height: 15),
                        Text(
                          'CONTACT',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(height: 7),
                        Row(children: [
                          const Icon(Icons.laptop),
                          const Spacer(flex: 1),
                          Text(widget.obj['website']),
                          const Spacer(flex: 15),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.call),
                          const Spacer(flex: 1),
                          Text(widget.obj['contactNo']),
                          const Spacer(flex: 15),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.email),
                          const Spacer(flex: 1),
                          Text(widget.obj['email']),
                          const Spacer(flex: 15),
                        ]),
                      ],
                    ),
                    ElevatedButton(
                      child: const Text(
                        'I WOULD LIKE TO CONTRIBUTE TO THIS CHARITY',
                        style: TextStyle(fontSize: 13.0),
                        textAlign: TextAlign.center
                      ),
                      onPressed: () {
                        pauseVideo();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => 
                                DonationScreen(isFavourite: isFavourite, obj: widget.obj),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
