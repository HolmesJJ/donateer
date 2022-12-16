import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:intl/intl.dart';

import '../screens/donation_screen.dart';

class DonateDialog extends StatefulWidget {
  final String name;
  final Map obj;

  DonateDialog({Key? key, required this.name, required this.obj})
      : super(key: key);
  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  List _donations = [];
  final _startDateController = TextEditingController();
  final _startHourController = TextEditingController();
  final _endHourController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String startHour = '';
  String endHour = '';

  var isDurationValid = true;

  @override
  void initState() {
    getData();
    _startDateController.text = DateFormat.yMMMMd().format(selectedDate);
    super.initState();
  }

  getData() async {
    var data = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    setState(() {
      if (data['donations'] != null) {
        _donations = data['donations'];
      } else {
        _donations = [];
      }
    });
  }

  void _trySubmit() {
    final formValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (formValid) {
      _formKey.currentState!.save();
    }
  }

  submitDonation(duration) async {
    print("hereee");
    print(startHour);
    print(selectedDate);
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();
    final data = doc.data() as Map<String, dynamic>;
    var amount = (int.parse(data['hourlyIncome']) / 60 * duration.inMinutes)
        .toStringAsFixed(2);
    var formattedDate = DateFormat.yMMMMd().format(selectedDate);
    _donations.add({
      'name': widget.name,
      'start': startHour,
      'end': endHour,
      'duration': duration.inMinutes,
      'date': formattedDate,
      'donationAmount': double.parse(amount),
    });
    updateFirestore();
    Add2Calendar.addEvent2Cal(getEvent(startHour, endHour));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (ctx) => DonationScreen(obj: widget.obj),
      ),
      (route) => false,
    );
  }

  updateFirestore() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .update({'donations': _donations});
  }

  Event getEvent(start, end) {
    Event event = Event(
      title: 'Donation to: ' + widget.name,
      description: widget.obj["description"].replaceAll("\\n", "\n") +
          '\nDonation link: ' +
          widget.obj["donationUrl"],
      startDate: DateTime.parse(start),
      endDate: DateTime.parse(end),
    );
    return event;
  }

  /// This decides which day will be enabled
  /// This will be called every time while displaying day in calender.
  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 30))))) {
      return true;
    }
    return false;
  }

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      selectableDayPredicate: _decideWhichDayToEnable,
      lastDate: DateTime(2100),
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _startDateController.text = DateFormat.yMMMMd().format(picked);
      });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      scrollable: true,
      title: Text('Which upcoming work hours of yours would you like to pledge to ${widget.name}? Please choose a date and time slot below:'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                  'Thank you for your support to ${widget.name}. \nHow many hours do you want to donate?'),
              SizedBox(
                height: 12,
              ),
              Text(
                'Start date',
                textAlign: TextAlign.center,
              ),
              InkWell(
                onTap: () {
                  _selectStartDate(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: TextFormField(
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: _startDateController,
                    validator: (value) {
                      if (value == null || value!.isEmpty) {
                        return 'Please select a date!';
                      }
                      return null;
                    },
                    // onSaved: (val) {
                    //   if (val != null) {
                    //     print("START DATE");
                    //     print(val);
                    //     startDate = val;
                    //   }
                    // },
                    decoration: InputDecoration(
                        disabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.only(top: 0.0)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Start hour'),
                  Text('End hour'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      DatePicker.showTime12hPicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (hour) {
                          setState(() {
                            // YYYY-MM-DD HH-MM-SS.SSS format
                            startHour = selectedDate.toString().substring(0,11) + hour.toString().substring(11);
                            // HH:MM AM/PM format
                            _startHourController.text =
                                DateFormat('jm').format(hour);
                          });
                        },
                        // pickerModel: CustomPicker(
                        //   currentTime: DateTime.now(),
                        //   locale: LocaleType.en,
                        // ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _startHourController,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            return 'Please select starting time!';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          if (val != null) {
                            startHour = val;
                          }
                        },
                        decoration: InputDecoration(
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.only(top: 0.0)),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DatePicker.showTime12hPicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (hour) {
                          setState(() {
                            // YYYY-MM-DD HH-MM-SS.SSS format
                            endHour = selectedDate.toString().substring(0,11) + hour.toString().substring(11);;
                            // HH:MM AM/PM format
                            _endHourController.text =
                                DateFormat('jm').format(hour);
                          });
                        },
                        // pickerModel: CustomPicker(
                        //   currentTime: DateTime.now(),
                        //   locale: LocaleType.en,
                        // ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _endHourController,
                        validator: (value) {
                          if (value == null || value!.isEmpty) {
                            return 'Please select ending date!';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          if (val != null) {
                            endHour = val;
                          }
                        },
                        decoration: InputDecoration(
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.only(top: 0.0)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              isDurationValid
                  ? Container()
                  : Text(
                      'Start hour must not be later than end hour!',
                      style: Theme.of(context).textTheme.subtitle2,
                      textAlign: TextAlign.center,
                    ),
              isDurationValid ? Container() : const SizedBox(height: 12),
              ElevatedButton(
                child: const Text("Submit"),
                onPressed: () {
                  // _trySubmit();
                  var duration = DateTime.parse(endHour)
                      .difference(DateTime.parse(startHour));
                  if (duration > Duration.zero) {
                    this.submitDonation(duration);
                  } else {
                    setState(() {
                      isDurationValid = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({required DateTime currentTime, required LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime != null ? currentTime : DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return this.digits(index, 2);
    } else {
      return '';
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return '';
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return '';
    }
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return ":";
  }

  @override
  List<int> layoutProportions() {
    return [1, 0, 0];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            this.currentLeftIndex(),
            this.currentMiddleIndex(),
            this.currentRightIndex())
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            this.currentLeftIndex(),
            this.currentMiddleIndex(),
            this.currentRightIndex());
  }
}
