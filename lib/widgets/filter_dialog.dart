import 'package:flutter/material.dart';
import '../screens/tabs_screen.dart';

class FilterDialog extends StatefulWidget {

  const FilterDialog({Key? key}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String selectedTax = '';
  var selectedCategories = [];
  final totalCategories = [
    "Animal",
    "Arts & Heritage",
    "Children",
    "Community",
    "Disability",
    "Education",
    "Elderly",
    "Environment",
    "Families",
    "Health",
    "Sports",
    "Women"
  ];
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      scrollable: true,
      title: const Text('Filter by', textAlign: TextAlign.center),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('CATEGORIES'),
          SizedBox(
            height: 350.0,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: totalCategories.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                    title: Text(totalCategories[index]),
                    value: selectedCategories.contains(totalCategories[index]),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedCategories.add(totalCategories[index]);
                        } else {
                          selectedCategories.remove(totalCategories[index]);
                        }
                      });
                    });
              },
            ),
          ),
          const SizedBox(height: 15),
          const Text('TAX'),
          ListTile(
            title: const Text("Tax Deductible"),
            trailing: Radio(
              value: "Tax Deductible",
              groupValue: selectedTax,
              onChanged: (value) {
                setState(() {
                  selectedTax = value as String;
                });
              },
              //activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: const Text("Not Tax Deductible"),
            trailing: Radio(
              value: "Not Tax Deductible",
              groupValue: selectedTax,
              onChanged: (value) {
                setState(() {
                  selectedTax = value as String;
                });
              },
              //activeColor: Colors.green,
            ),
          ),
          TextButton(
              onPressed: () {
                // pass into organisation overview as params
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TabsScreen(filter: {
                      'categories': selectedCategories,
                      'tax': selectedTax
                    }),
                  ),
                );
              },
              child: Text(
                'SHOW RESULTS',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              )),
        ],
      ),
    );
  }
}
