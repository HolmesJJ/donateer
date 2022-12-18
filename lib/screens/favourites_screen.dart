import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './organisation_details_screen.dart';

class FavouritesScreen extends StatefulWidget {

  const FavouritesScreen ({ Key? key }): super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  List _favourites = [];

  @override
  void initState() {
    getStreamSnapshots().then((_) {
      getResultsList();
    });
    super.initState();
  }

  Future getStreamSnapshots() {
    return FirebaseFirestore.instance
        .collection('Organisations')
        .get()
        .then((data) {
      setState(() {
        _allResults = data.docs;
      });
    });
  }

  getResultsList() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      if (data.containsKey('favourites') && data['favourites'] != null) {
        _favourites = data['favourites'];
      } else {
        _favourites = [];
      }
    });
    var results = [];
    for (var data in _allResults) {
      if (_favourites.contains(data['name'])) {
        results.add(data);
      }
    }
    setState(() {
      _resultsList = results;
    });
  }

  updateFirestoreFavourites() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .update({'favourites': _favourites});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(22),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Favourites',
                    style: Theme.of(context).textTheme.headline1),
              ],
            ),
            _resultsList.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text('No favourites added yet, get started!'),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _resultsList.length,
                      itemBuilder: (ctx, index) => InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            ctx,
                            MaterialPageRoute(
                              builder: (ctx) => OrganisationDetailsScreen(
                                  obj: _resultsList[index].data()),
                            ),
                            (route) => false,
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          color: Theme.of(context).primaryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                //leading: Icon(Icons.arrow_drop_down_circle),   // to add organisation logo
                                trailing: IconButton(
                                  icon: _favourites
                                          .contains(_resultsList[index]['name'])
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.red[400],
                                        )
                                      : const Icon(
                                          Icons.favorite_outline_rounded),
                                  onPressed: () async {
                                    setState(() {
                                      _favourites
                                          .remove(_resultsList[index]['name']);
                                      _resultsList.removeAt(index);
                                    });
                                    updateFirestoreFavourites();
                                  },
                                ),
                                title: Text(_resultsList[index]['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              Image.network(_resultsList[index]['imageUrl'],
                                  height: 145, fit: BoxFit.fitWidth),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _resultsList[index]['description']
                                          .replaceAll("\\n", "\n")
                                          .substring(0, 90) +
                                      '...',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
