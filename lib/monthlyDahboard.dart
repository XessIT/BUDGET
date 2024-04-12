import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'DashBoard.dart';
import 'MonthlyBudget2.dart';
import 'package:http/http.dart' as http;
import 'budgetdashboard.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MonthlyDashboard extends StatefulWidget {
  final String uid;
  const MonthlyDashboard({Key? key, required this.uid}) : super(key: key);

  @override
  _MonthlyDashboardState createState() => _MonthlyDashboardState();
}

class _MonthlyDashboardState extends State<MonthlyDashboard> {
  List<Map<String, dynamic>> trips = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String remainingValue = "300";

  final TextEditingController monthlyincome = TextEditingController();
  TextEditingController monthlyincomeType = TextEditingController();
  TextEditingController _textEditingControllerFrom = TextEditingController();
  TextEditingController _textEditingControllerTo = TextEditingController();

  late DateTime fromDate;
  late DateTime toDate;
  DateTime date = DateTime.now();
  final TextEditingController Fromdate = TextEditingController();
  final TextEditingController Todate = TextEditingController();

  bool _isAlertDialogOpen = false;
  bool _speedDialEnabled = true;
// Declare the boolean variable

  String? _monthlyincomeTypeError;
  String? _monthlyincomeAmountError;

  String? _validateFormField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  List<dynamic> monthlyData = [];
  String? fromDate2;
  String? toDate2;
  Future<void> fetchData2() async {
    const url =
        'http://localhost/BUDGET/lib/BUDGETAPI/get_daterange.php'; // Replace with your API endpoint
    final response = await http.get(Uri.parse('$url?uid=${widget.uid}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fromDate2 = data['fromDate'];
        //toDate2 = data['toDate'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> insertMonthlyData2() async {
    try {
      final url = Uri.parse(
          'http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php');
      final DateTime fromparsedDate =
          DateFormat('dd-MM-yyyy').parse(_textEditingControllerFrom.text);
      final fromDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate =
          DateFormat('dd-MM-yyyy').parse(_textEditingControllerTo.text);
      final toDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      final response = await http.post(
        url,
        body: jsonEncode({
          "uid": widget.uid,
          "incomeType": monthlyincomeType.text,
          "incomeAmt": monthlyincome.text,
          "fromDate": fromDate,
          "toDate": toDate,
          "status": "open",
        }),
      );

      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
    }
  }

  Future<void> fetchData() async {
    final url = Uri.parse("http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php");
    final response = await http.get(url);
    print("Dash: $url");
    if (response.statusCode == 200) {
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      setState(() {
        monthlyData = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> insertMonthlyData() async {
    try {
      final url =
          Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/date_range.php');
      final DateTime fromparsedDate =
          DateFormat('dd').parse(_textEditingControllerFrom.text);
      final fromDate = DateFormat('dd').format(fromparsedDate);
      final response = await http.post(
        url,
        body: jsonEncode({
          "uid": widget.uid,
          "fromDate": fromDate,
        }),
      );

      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
    }
  }

/*
  Future<void> updateRecord(Map<String, dynamic> updateData) async {
    try {
      var response = await http.put(Uri.parse('http://localhost/mybudget2/mybudget/lib/BUDGETAPI/MonthlyDashBoard.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        print('Record updated successfully');
      } else {
        print('Failed to update record: ${response.body}');
        throw Exception('Failed to update record');
      }
    } catch (e) {
      print('Exception while updating record: $e');
      rethrow; // Rethrow the exception for higher-level error handling
    }
  }
*/
  @override
  void initState() {
    super.initState();
    //fetchDataFromSharedPreferences();
    fetchData();
    fetchData2();
  }

  Future<DateTime?> _showCustomDatePicker(BuildContext context,
      {required DateTime initialDate, required int enabledDate}) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2300),
      selectableDayPredicate: (DateTime date) {
        return date.day == enabledDate;
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8155BA),
            ),
          ),
          child: child!,
        );
      },
    );
  }

/*
  void fetchDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? incomeIds = prefs.getStringList('totalIncomes');
    if (incomeIds != null) {
      for (String incomeId in incomeIds) {
        // Check if monthClose is true for this incomeId
        bool? monthClosed = prefs.getBool('$incomeId:monthClose');
        if (monthClosed != null && monthClosed) {
          // Skip fetching data for this incomeId if monthClose is true
          continue;
        }

        // Fetch data for this incomeId if monthClose is not true
        String? totalIncome = prefs.getString('$incomeId:totalincome');
        String? incomeType = prefs.getString('$incomeId:incomeType');
        String? totalRemaining = prefs.getString('$incomeId:totalRemaining');
        String? selectedFromDate = prefs.getString('$incomeId:selectedFromDate');
        String? selectedToDate = prefs.getString('$incomeId:selectedToDate');

        if (totalIncome != null && incomeType != null && selectedFromDate != null && selectedToDate != null) {
          setState(() {
            trips.add({
              'incomeId': incomeId,
              'totalIncome': totalIncome,
              'totalRemaining': totalRemaining,
              'incomeType': incomeType,
              'selectedFromDate': selectedFromDate,
              'selectedToDate': selectedToDate,
            });
          });
        }
      }
    }
  }
*/
  Map<String, dynamic> trip = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Text(
            "Monthly Budget",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const DashBoard()));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.date_range,
                color: Colors.white,
              ), // You can use any icon for the date
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Center(
                              child: Text(
                            'Set Date Range',
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.green),
                          )),
                          insetPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.deepPurple),
                          ),
                          shadowColor: Colors.deepPurple,
                          content: SizedBox(
                            width: 250, // Set your desired width
                            height: 180,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 200,
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 11),
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2300),
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Theme(
                                                  data: ThemeData.light()
                                                      .copyWith(
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary:
                                                          Color(0xFF8155BA),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickDate == null) return;
                                            {
                                              setState(() {
                                                _textEditingControllerFrom
                                                        .text =
                                                    DateFormat('dd')
                                                        .format(pickDate);
                                              });
                                            }
                                          },
                                          controller:
                                              _textEditingControllerFrom, // Set the initial value of the field to the selected date
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(
                                              Icons.date_range,
                                              color: Colors.teal,
                                              size: 14,
                                            ),
                                            // filled: true,
                                            // fillColor: Colors.white,
                                            labelText: "Start Date",
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                            // border: OutlineInputBorder(
                                            //   //  borderRadius: BorderRadius.circular(8),
                                            // ),
                                          ),
                                          validator: (value) =>
                                              _validateFormField(value, 'From'),
                                        ),
                                      ),
                                      /*SizedBox(
                                        height: 40,
                                        width: 120,
                                        child: TextFormField(
                                          style: TextStyle(fontSize: 11),
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2300),
                                              builder: (BuildContext context, Widget? child) {
                                                return Theme(
                                                  data: ThemeData.light()
                                                      .copyWith(
                                                    colorScheme:
                                                    ColorScheme.light(
                                                      primary:
                                                      Color(0xFF8155BA),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickDate == null) return;
                                            {
                                              setState(() {
                                                _textEditingControllerTo.text = DateFormat('dd-MM-yyyy').format(pickDate);
                                              });
                                            }
                                          },
                                          controller:
                                          _textEditingControllerTo, // Set the initial value of the field to the selected date
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.date_range,color: Colors.teal,size: 14,),
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelText: "To",
                                            labelStyle: Theme.of(context).textTheme.labelMedium,
                                            border: OutlineInputBorder(
                                              //  borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          validator: (value) => _validateFormField(value, 'To'),
                                        ),
                                      ),*/
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Validate the form
                                      if (_formKey.currentState!.validate()) {
                                        insertMonthlyData();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MonthlyDashboard(
                                                uid:
                                                    ''), // Pass UID to the dashboard if needed
                                          ),
                                        );
                                      } else {
                                        // Fields are not valid, trigger a rebuild to display error messages
                                        setState(() {});
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.teal),
                                    ),
                                    child: Text("Ok",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Note: This range will be applied to all budget calculations and analyses. ',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          backgroundColor: Colors.teal.shade50,
                        );
                      },
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ), // You can use any icon for the date
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyUi(),
                  ),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.add,
            //     color: Colors.white,
            //   ), // You can use any icon for the date
            //   onPressed: () {
            //     Navigator.of(context).push(
            //         MaterialPageRoute(builder: (context) => sppeddiaall()));
            //   },
            // ),
          ],
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
          elevation: 0.00,
          backgroundColor: Color(0xFF8155BA),
        ),
      ),
      floatingActionButton: _speedDialEnabled
          ? SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 3,
              childrenButtonSize: const Size(56.0, 56.0),
              visible: true,
              direction: SpeedDialDirection.up,
              closeManually: true,
              renderOverlay: false,
              onOpen: () => debugPrint('OPENING DIAL'),
              onClose: () => debugPrint('DIAL CLOSED'),
              useRotationAnimation: true,
              tooltip: 'Open Speed Dial',
              heroTag: 'speed-dial-hero-tag',
              elevation: 8.0,
              animationCurve: Curves.elasticInOut,
              isOpenOnStart: false,
              shape: const StadiumBorder(),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.dashboard),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  label: 'Custom',
                  onTap: () {
                    setState(() {
                      _speedDialEnabled = false; // Disable the Speed Dial
                    });
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Set to true to enable the barrier

                      builder: (BuildContext context) {
                        //DateTime _dialogSelectedDate = _selectedDate;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Center(
                                  child: Text(
                                'Set your Income',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green),
                              )),
                              insetPadding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                              shadowColor: Colors.deepPurple,
                              content: SizedBox(
                                width: 250, // Set your desired width
                                height: 350,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (fromDate2 != null)
                                        Text('Start Date: ${fromDate2!}'),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Fromdate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Fromdate.text}");

                                                int daysInCurrentMonth =
                                                    DateTime(
                                                            pickDate.year,
                                                            pickDate.month + 1,
                                                            0)
                                                        .day;
                                                int daysToAdd;

                                                switch (pickDate.month) {
                                                  case DateTime.february:
                                                    bool isLeapYear =
                                                        pickDate.year % 4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                    daysToAdd =
                                                        isLeapYear ? 29 : 28;
                                                    break;
                                                  case DateTime.april:
                                                  case DateTime.june:
                                                  case DateTime.september:
                                                  case DateTime.november:
                                                    daysToAdd = 30;
                                                    break;
                                                  default:
                                                    daysToAdd = 31;
                                                }
                                                if (pickDate.day == 1) {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                } else {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                }

                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(toDate);
                                              });
                                            }
                                          },
                                          controller: Fromdate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'From Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Fromdate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Fromdate.text}");

                                                    int daysInCurrentMonth =
                                                        DateTime(
                                                                pickDate.year,
                                                                pickDate.month +
                                                                    1,
                                                                0)
                                                            .day;
                                                    int daysToAdd;

                                                    switch (pickDate.month) {
                                                      case DateTime.february:
                                                        bool isLeapYear = pickDate
                                                                        .year %
                                                                    4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                        daysToAdd = isLeapYear
                                                            ? 29
                                                            : 28;
                                                        break;
                                                      case DateTime.april:
                                                      case DateTime.june:
                                                      case DateTime.september:
                                                      case DateTime.november:
                                                        daysToAdd = 30;
                                                        break;
                                                      default:
                                                        daysToAdd = 31;
                                                    }
                                                    if (pickDate.day == 1) {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    } else {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    }

                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(toDate);
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Todate.text}");
                                              });
                                            }
                                          },
                                          controller: Todate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'To Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Todate.text}");
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),

                                      /// TODATE

                                      SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincomeType,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Type',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[a-zA-Z]')), // Allow only alphabets
                                              ],
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Type'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeTypeError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                            ),
                                            if (_monthlyincomeTypeError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeTypeError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            // Add other form fields and error messages here
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincome,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Amount',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Amount'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeAmountError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    7)
                                              ],
                                            ),
                                            if (_monthlyincomeAmountError !=
                                                null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeAmountError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the dialog
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty
                                                  .all<Color>(Colors
                                                      .red), // Customize button color
                                            ),
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Validate the form
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // All fields are valid, proceed with your logic
                                                if (monthlyincomeType
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeTypeError =
                                                        'Income Type is required.';
                                                  });
                                                } else if (monthlyincome
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeAmountError =
                                                        'Income Amount is required.';
                                                  });
                                                } else {
                                                  insertMonthlyData2();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MonthlyDashboard(
                                                        uid: '',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Fields are not valid, trigger a rebuild to display error messages
                                                setState(() {});
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.green),
                                            ),
                                            child: Text("Save",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.teal.shade50,
                            );
                          },
                        );
                      },
                    );
                    // Add your logic for the monthly button tap here
                    debugPrint('Monthly button tapped');
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.view_day),
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  label: 'Weekly',
                  onTap: () {
                    setState(() {
                      _speedDialEnabled = false; // Disable the Speed Dial
                    });
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Set to true to enable the barrier

                      builder: (BuildContext context) {
                        //DateTime _dialogSelectedDate = _selectedDate;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Center(
                                  child: Text(
                                'Set your Income',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green),
                              )),
                              insetPadding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                              shadowColor: Colors.deepPurple,
                              content: SizedBox(
                                width: 250, // Set your desired width
                                height: 350,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (fromDate2 != null)
                                        Text('Start Date: ${fromDate2!}'),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Fromdate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Fromdate.text}");

                                                int daysInCurrentMonth =
                                                    DateTime(
                                                            pickDate.year,
                                                            pickDate.month + 1,
                                                            0)
                                                        .day;
                                                int daysToAdd;

                                                switch (pickDate.month) {
                                                  case DateTime.february:
                                                    bool isLeapYear =
                                                        pickDate.year % 4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                    daysToAdd =
                                                        isLeapYear ? 29 : 28;
                                                    break;
                                                  case DateTime.april:
                                                  case DateTime.june:
                                                  case DateTime.september:
                                                  case DateTime.november:
                                                    daysToAdd = 30;
                                                    break;
                                                  default:
                                                    daysToAdd = 31;
                                                }
                                                if (pickDate.day == 1) {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                } else {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                }

                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(toDate);
                                              });
                                            }
                                          },
                                          controller: Fromdate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'From Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Fromdate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Fromdate.text}");

                                                    int daysInCurrentMonth =
                                                        DateTime(
                                                                pickDate.year,
                                                                pickDate.month +
                                                                    1,
                                                                0)
                                                            .day;
                                                    int daysToAdd;

                                                    switch (pickDate.month) {
                                                      case DateTime.february:
                                                        bool isLeapYear = pickDate
                                                                        .year %
                                                                    4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                        daysToAdd = isLeapYear
                                                            ? 29
                                                            : 28;
                                                        break;
                                                      case DateTime.april:
                                                      case DateTime.june:
                                                      case DateTime.september:
                                                      case DateTime.november:
                                                        daysToAdd = 30;
                                                        break;
                                                      default:
                                                        daysToAdd = 31;
                                                    }
                                                    if (pickDate.day == 1) {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    } else {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    }

                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(toDate);
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Todate.text}");
                                              });
                                            }
                                          },
                                          controller: Todate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'To Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Todate.text}");
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),

                                      /// TODATE

                                      SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincomeType,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Type',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[a-zA-Z]')), // Allow only alphabets
                                              ],
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Type'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeTypeError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                            ),
                                            if (_monthlyincomeTypeError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeTypeError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            // Add other form fields and error messages here
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincome,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Amount',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Amount'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeAmountError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    7)
                                              ],
                                            ),
                                            if (_monthlyincomeAmountError !=
                                                null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeAmountError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the dialog
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty
                                                  .all<Color>(Colors
                                                      .red), // Customize button color
                                            ),
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Validate the form
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // All fields are valid, proceed with your logic
                                                if (monthlyincomeType
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeTypeError =
                                                        'Income Type is required.';
                                                  });
                                                } else if (monthlyincome
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeAmountError =
                                                        'Income Amount is required.';
                                                  });
                                                } else {
                                                  insertMonthlyData2();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MonthlyDashboard(
                                                        uid: '',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Fields are not valid, trigger a rebuild to display error messages
                                                setState(() {});
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.teal),
                                            ),
                                            child: Text("Save",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.teal.shade50,
                            );
                          },
                        );
                      },
                    );
                    // Add your logic for the monthly button tap here
                    debugPrint('Monthly button tapped');
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.date_range),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  label: 'Monthly',
                  onTap: () {
                    setState(() {
                      _speedDialEnabled = false; // Disable the Speed Dial
                    });
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Set to true to enable the barrier

                      builder: (BuildContext context) {
                        //DateTime _dialogSelectedDate = _selectedDate;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Center(
                                  child: Text(
                                'Set your Income',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green),
                              )),
                              insetPadding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.deepPurple),
                              ),
                              shadowColor: Colors.deepPurple,
                              content: SizedBox(
                                width: 250, // Set your desired width
                                height: 350,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (fromDate2 != null)
                                        Text('Start Date: ${fromDate2!}'),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          readOnly: true,
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Fromdate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Fromdate.text}");

                                                int daysInCurrentMonth =
                                                    DateTime(
                                                            pickDate.year,
                                                            pickDate.month + 1,
                                                            0)
                                                        .day;
                                                int daysToAdd;

                                                switch (pickDate.month) {
                                                  case DateTime.february:
                                                    bool isLeapYear =
                                                        pickDate.year % 4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                    daysToAdd =
                                                        isLeapYear ? 29 : 28;
                                                    break;
                                                  case DateTime.april:
                                                  case DateTime.june:
                                                  case DateTime.september:
                                                  case DateTime.november:
                                                    daysToAdd = 30;
                                                    break;
                                                  default:
                                                    daysToAdd = 31;
                                                }
                                                if (pickDate.day == 1) {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                } else {
                                                  toDate = pickDate.add(
                                                      Duration(
                                                          days: daysToAdd - 1));
                                                }

                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(toDate);
                                              });
                                            }
                                          },
                                          controller: Fromdate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'From Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Fromdate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Fromdate.text}");

                                                    int daysInCurrentMonth =
                                                        DateTime(
                                                                pickDate.year,
                                                                pickDate.month +
                                                                    1,
                                                                0)
                                                            .day;
                                                    int daysToAdd;

                                                    switch (pickDate.month) {
                                                      case DateTime.february:
                                                        bool isLeapYear = pickDate
                                                                        .year %
                                                                    4 ==
                                                                0 &&
                                                            (pickDate.year %
                                                                        100 !=
                                                                    0 ||
                                                                pickDate.year %
                                                                        400 ==
                                                                    0);
                                                        daysToAdd = isLeapYear
                                                            ? 29
                                                            : 28;
                                                        break;
                                                      case DateTime.april:
                                                      case DateTime.june:
                                                      case DateTime.september:
                                                      case DateTime.november:
                                                        daysToAdd = 30;
                                                        break;
                                                      default:
                                                        daysToAdd = 31;
                                                    }
                                                    if (pickDate.day == 1) {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    } else {
                                                      toDate = pickDate.add(
                                                          Duration(
                                                              days: daysToAdd -
                                                                  1));
                                                    }

                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(toDate);
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: TextFormField(
                                          onTap: () async {
                                            DateTime? pickDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: date,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2100),
                                            );
                                            print("Picked date: $pickDate");
                                            if (pickDate != null) {
                                              setState(() {
                                                Todate.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(pickDate);
                                                print(
                                                    "_date.text updated: ${Todate.text}");
                                              });
                                            }
                                          },
                                          controller: Todate,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "*Enter the Validity";
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'To Date',
                                            suffixIcon: IconButton(
                                              onPressed: () async {
                                                DateTime? pickDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: date,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2100),
                                                );
                                                print("Picked date: $pickDate");
                                                if (pickDate != null) {
                                                  setState(() {
                                                    Todate.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(pickDate);
                                                    print(
                                                        "_date.text updated: ${Todate.text}");
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              color: Colors.green,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),

                                      /// TODATE

                                      SizedBox(height: 10),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincomeType,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Type',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'[a-zA-Z]')), // Allow only alphabets
                                              ],
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Type'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeTypeError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                            ),
                                            if (_monthlyincomeTypeError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeTypeError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            // Add other form fields and error messages here
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              controller: monthlyincome,
                                              decoration: InputDecoration(
                                                // filled: true,
                                                // fillColor: Colors.white,
                                                hintText: 'Income Amount',
                                                labelStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                              validator: (value) =>
                                                  _validateFormField(
                                                      value, 'Income Amount'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeAmountError =
                                                      null; // Clear error message when text changes
                                                });
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    7)
                                              ],
                                            ),
                                            if (_monthlyincomeAmountError !=
                                                null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  _monthlyincomeAmountError!,
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close the dialog
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty
                                                  .all<Color>(Colors
                                                      .red), // Customize button color
                                            ),
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Validate the form
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // All fields are valid, proceed with your logic
                                                if (monthlyincomeType
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeTypeError =
                                                        'Income Type is required.';
                                                  });
                                                } else if (monthlyincome
                                                    .text.isEmpty) {
                                                  // Set error message for monthlyincomeType
                                                  setState(() {
                                                    _monthlyincomeAmountError =
                                                        'Income Amount is required.';
                                                  });
                                                } else {
                                                  insertMonthlyData2();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MonthlyDashboard(
                                                        uid: '',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Fields are not valid, trigger a rebuild to display error messages
                                                setState(() {});
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.teal),
                                            ),
                                            child: Text("Save",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.teal.shade50,
                            );
                          },
                        );
                      },
                    );
                    // Add your logic for the monthly button tap here
                    debugPrint('Monthly button tapped');
                  },
                ),
              ],
            )
          : null,
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                  visible: trips.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Your Budget',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                for (var trip in monthlyData)
                  buildTripContainer(context, trip),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return buildTripContainer(context, trips[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Set<String> displayedIncomeIds = Set();

  Widget buildTripContainer(BuildContext context, Map<String, dynamic> trip) {
    DateTime currentDate = DateTime.now();
    DateTime toDate = DateTime.parse(trip['toDate'])
        .toLocal(); // Convert 'toDate' to DateTime
    String fromdateString = trip['fromDate'];
    DateTime fromdateTime = DateFormat('yyyy-MM-dd').parse(fromdateString);
    String todateString = trip['toDate'];
    DateTime todateTime = DateFormat('yyyy-MM-dd').parse(todateString);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyBudget2(
              uid: trip['uid'],
              incomeId: trip['incomeId'],
              fromDate: trip['fromDate'],
              toDate: trip['toDate'],
              totalIncomeAmt: trip['totalIncomeAmt'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // width: 350,
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color(0xFF8155BA), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Income ID: ${trip['incomeId']}', style: Theme.of(context).textTheme.labelMedium),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('From: ${DateFormat('dd-MM-yyyy').format(fromdateTime)}',
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('To: ${DateFormat('dd-MM-yyyy').format(todateTime)}',
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        child: Text("Edit"),
                        value: "edit",
                      ),
                      const PopupMenuItem(
                        child: Text("Delete"),
                        value: "delete",
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController editFrom =
                                TextEditingController(text: trip['fromDate']);
                            TextEditingController editTo =
                                TextEditingController(text: trip['toDate']);
                            TextEditingController editIncomeAmt =
                                TextEditingController(
                                    text: trip['totalIncomeAmt']);
                            TextEditingController editIncomeType =
                                TextEditingController(text: trip['incomeType']);
                            //DateTime _dialogSelectedDate = _selectedDate;
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(trip['incomeId'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                  insetPadding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.deepPurple),
                                  ),
                                  shadowColor: Colors.deepPurple,
                                  content: SizedBox(
                                    width: 250, // Set your desired width
                                    height: 220,
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                width: 120,
                                                child: TextFormField(
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                  readOnly: true,
                                                  onTap: () async {
                                                    DateTime? pickDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2300),
                                                      builder:
                                                          (BuildContext context,
                                                              Widget? child) {
                                                        return Theme(
                                                          data:
                                                              ThemeData.light()
                                                                  .copyWith(
                                                            colorScheme:
                                                                ColorScheme
                                                                    .light(
                                                              primary: Color(
                                                                  0xFF8155BA),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (pickDate == null)
                                                      return;
                                                    {
                                                      setState(() {
                                                        editFrom
                                                            .text = DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(pickDate);
                                                      });
                                                    }
                                                  },
                                                  controller:
                                                      editFrom, // Set the initial value of the field to the selected date
                                                  decoration: InputDecoration(
                                                    suffixIcon: Icon(
                                                      Icons.date_range,
                                                      color: Colors.teal,
                                                      size: 14,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "From",
                                                    labelStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .labelMedium,
                                                    border: OutlineInputBorder(
                                                        //  borderRadius: BorderRadius.circular(8),
                                                        ),
                                                  ),
                                                  validator: (value) =>
                                                      _validateFormField(
                                                          value, 'From'),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 40,
                                                width: 120,
                                                child: TextFormField(
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                  readOnly: true,
                                                  onTap: () async {
                                                    DateTime? pickDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2300),
                                                      builder:
                                                          (BuildContext context,
                                                              Widget? child) {
                                                        return Theme(
                                                          data:
                                                              ThemeData.light()
                                                                  .copyWith(
                                                            colorScheme:
                                                                ColorScheme
                                                                    .light(
                                                              primary: Color(
                                                                  0xFF8155BA),
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (pickDate == null)
                                                      return;
                                                    {
                                                      setState(() {
                                                        editTo
                                                            .text = DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(pickDate);
                                                      });
                                                    }
                                                  },
                                                  controller:
                                                      editTo, // Set the initial value of the field to the selected date
                                                  decoration: InputDecoration(
                                                    suffixIcon: Icon(
                                                      Icons.date_range,
                                                      color: Colors.teal,
                                                      size: 14,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText: "To",
                                                    labelStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .labelMedium,
                                                    border: OutlineInputBorder(
                                                        //  borderRadius: BorderRadius.circular(8),
                                                        ),
                                                  ),
                                                  validator: (value) =>
                                                      _validateFormField(
                                                          value, 'To'),
                                                ),
                                              ),
                                            ],
                                          ),

                                          /// DATE
                                          SizedBox(height: 15),
                                          SizedBox(
                                            height: 70,
                                            width: 250,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  controller: editIncomeType,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    hintText: 'Income Type',
                                                    labelStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 10.0),
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'[a-zA-Z]')), // Allow only alphabets
                                                  ],
                                                  validator: (value) =>
                                                      _validateFormField(
                                                          value, 'Income Type'),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _monthlyincomeTypeError =
                                                          null; // Clear error message when text changes
                                                    });
                                                  },
                                                ),
                                                if (_monthlyincomeTypeError !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      _monthlyincomeTypeError!,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                // Add other form fields and error messages here
                                              ],
                                            ),
                                          ),

                                          ///Income Type
                                          SizedBox(height: 15),
                                          SizedBox(
                                            height: 70,
                                            width: 250,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  controller: editIncomeAmt,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    hintText: 'Income Amount',
                                                    labelStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 10.0),
                                                  ),
                                                  validator: (value) =>
                                                      _validateFormField(value,
                                                          'Income Amount'),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _monthlyincomeAmountError =
                                                          null; // Clear error message when text changes
                                                    });
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                    LengthLimitingTextInputFormatter(
                                                        7)
                                                  ],
                                                ),
                                                if (_monthlyincomeAmountError !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      _monthlyincomeAmountError!,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),

                                          ///Income Amount
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Validate the form
                                        if (_formKey.currentState!.validate()) {
                                          // All fields are valid, proceed with your logic
                                          if (editIncomeType.text.isEmpty) {
                                            // Set error message for monthlyincomeType
                                            setState(() {
                                              _monthlyincomeTypeError =
                                                  'Income Type is required.';
                                            });
                                          } else if (editIncomeAmt
                                              .text.isEmpty) {
                                            // Set error message for monthlyincomeType
                                            setState(() {
                                              _monthlyincomeAmountError =
                                                  'Income Amount is required.';
                                            });
                                          } else {
                                            final DateTime fromparsedDate =
                                                DateFormat('dd-MM-yyyy')
                                                    .parse(editFrom.text);
                                            final fromDate =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(fromparsedDate);
                                            final DateTime toparsedDate =
                                                DateFormat('dd-MM-yyyy')
                                                    .parse(editTo.text);
                                            final toDate =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(toparsedDate);
                                            var response = await http.put(
                                              Uri.parse(
                                                  'http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php?table=monthly_dashboard'), // Replace with your PHP update endpoint

                                              headers: <String, String>{
                                                'Content-Type':
                                                    'application/json; charset=UTF-8',
                                              },

                                              body:
                                                  jsonEncode(<String, dynamic>{
                                                'incomeId': trip['incomeId'],
                                                'incomeType':
                                                    editIncomeType.text,
                                                'fromDate': fromDate,
                                                'toDate': toDate,
                                                'incomeAmt': editIncomeAmt.text,
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MonthlyDashboard(
                                                    uid: '',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Handle error
                                              print('Failed to update data.');
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MonthlyDashboard(
                                                  uid: '',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          // Fields are not valid, trigger a rebuild to display error messages
                                          setState(() {});
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.teal),
                                      ),
                                      child: const Text("Update",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                  backgroundColor: Colors.teal.shade50,
                                );
                              },
                            );
                          },
                        );
                      } else if (value == "delete") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this Budget?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () async {
                                    // Send DELETE request to delete data
                                    var response = await http.delete(
                                      Uri.parse(
                                          'http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php'),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'incomeId': trip['incomeId'],
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MonthlyDashboard(
                                                    uid: '',
                                                  )));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Failed to delete data')));
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('Income Amount: ${trip['totalIncomeAmt']}',
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                  Text('Spent: ${trip['total_spent']}'),
                  Text('Remaining: ${trip['remaining']}'),
                  const SizedBox(
                    width: 30,
                  ),
                  // if((currentDate.year >= toDate.year &&
                  //     currentDate.month >= toDate.month &&
                  //     currentDate.day >= toDate.day))
                  TextButton(
                    child: Text("Close"),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Close"),
                            content: const Text(
                                "Are you sure you want to Close this Budget?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Close"),
                                onPressed: () async {
                                  try {
                                    /*var response = await http.put(
                                      Uri.parse(
                                          'http://localhost/BUDGET/lib/BUDGETAPI/monthEndBalance.php'),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(<String, dynamic>{
                                        'incomeId': trip['incomeId'],
                                        'fromDate': trip[
                                            'fromDate'], // Include fromDate
                                        'toDate':
                                            trip['toDate'], // Include toDate
                                        'monthRemaining': trip['remaining'],
                                      }),
                                    );*/
                                    final response = await http.post(Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/personal_savings.php?table=personal_savings'),
                                      headers: <String, String>{
                                        'Content-Type':
                                        'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode({
                                        'incomeId': trip['incomeId'],
                                        'uid': widget.uid, // Include fromDate
                                        'amount': trip['remaining'],
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      print("FromDate: ${trip['fromDate']}");
                                      print("ToDate: ${trip['toDate']}");
                                      var statusResponse = await http.put(
                                        Uri.parse(
                                            'http://localhost/BUDGET/lib/BUDGETAPI/UpdateStatus.php'), // Replace with your PHP endpoint to update status
                                        headers: <String, String>{
                                          'Content-Type':
                                              'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode({
                                          'incomeId': trip['incomeId'],
                                          'fromDate': trip['fromDate'], // Include fromDate
                                          'toDate': trip['toDate'],
                                          'status': 'closed',
                                        }),
                                      );
                                      if (statusResponse.statusCode == 200) {
                                        print(
                                            "Response Body: ${response.body}");
                                        print(
                                            "Response Status: ${response.statusCode}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MonthlyDashboard(
                                              uid: '',
                                            ),
                                          ),
                                        );
                                      } else {
                                        print('Failed to update status.');
                                      }
                                    } else {
                                      print('Failed to update data.');
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MonthlyDashboard(
                                                  uid: '',
                                                )));
                                  } catch (e) {
                                    print('Error closing month: $e');
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
