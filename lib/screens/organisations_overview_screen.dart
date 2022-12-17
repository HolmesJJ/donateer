import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './organisation_details_screen.dart';
import '../widgets/filter_dialog.dart';
import './tabs_screen.dart';

class OrganisationsOverviewScreen extends StatefulWidget {
  final dynamic filter;

  const OrganisationsOverviewScreen({Key? key, this.filter}) : super(key: key);

  @override
  State<OrganisationsOverviewScreen> createState() =>
      _OrganisationsOverviewScreenState();
}

class _OrganisationsOverviewScreenState
    extends State<OrganisationsOverviewScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool search = false;
  final TextEditingController _searchController = TextEditingController();
  late Future resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  List _favourites = [];

  @override
  void initState() {
    getFavourites();
    super.initState();
    _searchController.addListener(searchResultsList);
  }

  @override
  void dispose() {
    _searchController.removeListener(searchResultsList);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getStreamSnapshots();
  }

  searchResultsList() {
    var showResults = [];
    var results = _allResults;
    if (widget.filter != null) {
      results = [];
      for (var data in _allResults) {
        if ((data['categories']
                    .toSet()
                    .intersection(widget.filter['categories'].toSet())
                    .isNotEmpty |
                widget.filter['categories'].isEmpty) &
            ((data['taxDeductible'] == widget.filter['tax']) |
                (widget.filter['tax'] == ''))) {
          results.add(data);
        }
      }
    }
    if (_searchController.text != "") {
      for (var data in results) {
        var title = data['name'].toLowerCase();
        if (title.contains(_searchController.text.toLowerCase())) {
          showResults.add(data);
        }
      }
    } else {
      showResults = List.from(results);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  getStreamSnapshots() async {
    var data =
        await FirebaseFirestore.instance.collection('Organisations').get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
  }

  getFavourites() async {
    var data = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    setState(() {
      if (data['favourites'] != null) {
        _favourites = data['favourites'];
      } else {
        _favourites = [];
      }
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
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (!search)
              Text(
                'Get Involved',
                style: Theme.of(context).textTheme.headline1,
              ),
            if (!search)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    search = true;
                  });
                },
              ),
            if (search)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(),
                ),
              ),
            if (search)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    search = false;
                  });
                },
              ),
          ]),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                label: const Text('Filter'),
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const FilterDialog();
                    },
                  );
                },
              ),
              const SizedBox(width: 10),
              Center(
                child: Ink(
                  width: 40,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    shape: const CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    iconSize: 19.0,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const TabsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
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
                        icon: _favourites.contains(_resultsList[index]['name'])
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red[400],
                              )
                            : const Icon(Icons.favorite_outline_rounded),
                        onPressed: () async {
                          if (!_favourites
                              .contains(_resultsList[index]['name'])) {
                            setState(() {
                              _favourites.add(_resultsList[index]['name']);
                            });
                            updateFirestoreFavourites();
                          } else if (_favourites
                              .contains(_resultsList[index]['name'])) {
                            setState(() {
                              _favourites.remove(_resultsList[index]['name']);
                            });
                            updateFirestoreFavourites();
                          }
                        },
                      ),
                      title: Text(_resultsList[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
