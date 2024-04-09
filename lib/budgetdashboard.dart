import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'DashBoard.dart';
import 'MonthlyBudget2.dart';
import 'package:http/http.dart' as http;
import 'duplicate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MonthlyUi extends StatefulWidget {
  const MonthlyUi({super.key});

  @override
  State<MonthlyUi> createState() => _MonthlyUiState();
}

class _MonthlyUiState extends State<MonthlyUi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Use late keyword for non-nullable fields

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
  String? fromDate2;
  String? toDate2;

  bool _speedDialEnabled = true;

  String? _monthlyincomeTypeError;
  String? _monthlyincomeAmountError;

  String? _validateFormField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> insertMonthlyData2()async {
    try{
      final url=Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php');
      final DateTime fromparsedDate = DateFormat('dd-MM-yyyy').parse(Fromdate.text);
      final fromDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate = DateFormat('dd-MM-yyyy').parse(Todate.text);
      final toDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      print("Url: $url");
      final response = await http.post(
        url,
        body: jsonEncode({
          "uid": "5",
          "type": "Monthly",
          "incomeType": monthlyincomeType.text,
          "incomeAmt": monthlyincome.text,
          "fromDate": fromDate,
          "toDate": toDate,
          "status":"open",
        }),
      );

      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
        print("Response Status: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    }
    catch (e){
      print("Error during trip addition: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepPurple.shade50,
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
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Validate the form
                                      if (_formKey.currentState!.validate()) {
/*
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MonthlyDashboard(
                                                uid:
                                                    ''), // Pass UID to the dashboard if needed
                                          ),
                                        );
*/
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

      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(
                child: Text(
                  'Monthly',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Weekly',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Custom',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Monthly tab content
                Month(),
                // Weekly tab content
                Container(
                  child: Center(child: Text('Weekly Tab Content')),
                ),
                // Custom tab content
                Container(
                  child: Center(child: Text('Custom Tab Content')),
                ),
              ],
            ),
          ),

        ],
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
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         MonthlyDashboard(
                                            //       uid: '',
                                            //     ),
                                            //   ),
                                            // );
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
            backgroundColor: Colors.purpleAccent,
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
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         MonthlyDashboard(
                                            //       uid: '',
                                            //     ),
                                            //   ),
                                            // );
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
                                          Fromdate.text = DateFormat('dd-MM-yyyy').format(pickDate);
                                          print("_date.text updated: ${Fromdate.text}");
                                          int daysToAdd;

                                          switch (pickDate.month) {
                                            case DateTime.february:
                                              bool isLeapYear = pickDate.year % 4 == 0 && (pickDate.year % 100 != 0 || pickDate.year % 400 == 0);
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
                                              DateFormat('dd-MM-yyyy')
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
                                    decoration: const InputDecoration(
                                      hintText: 'From Date',
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
                                    readOnly: true,
                                    controller: Todate,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "*Enter the Validity";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'To Date',
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
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 10.0),
                                        ),
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only alphabets
                                        ],
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "*Enter the Validity";
                                          } else {
                                            return null;
                                          }
                                        },
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
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "*Enter the Validity";
                                          } else {
                                            return null;
                                          }
                                        },
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

                                          insertMonthlyData2();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MonthlyUi(),
                                            ),
                                          );
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
    );
  }
}

class Month extends StatefulWidget {
  const Month({super.key});

  @override
  State<Month> createState() => _MonthState();
}

class _MonthState extends State<Month> {
  List<dynamic> monthlyData = [];
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php'));

    if (response.statusCode == 200) {
      setState(() {
        monthlyData = json.decode(response.body);
      });
    } else {
      print('Failed to load data');
    }
  }
  @override
  void initState() {
    super.initState();
    //fetchDataFromSharedPreferences();
    fetchData();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: monthlyData.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyBudget2(
                    uid: monthlyData[i]['uid'],
                    incomeId: monthlyData[i]['incomeId'],
                    fromDate: monthlyData[i]['fromDate'],
                    toDate: monthlyData[i]['toDate'],
                    totalIncomeAmt: monthlyData[i]['totalIncomeAmt'],
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
                          child: Text('From: ${monthlyData[i]['fromDate']}',
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text('To: ${monthlyData[i]['toDate']}',
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
                                  TextEditingController(text: monthlyData[i]['fromDate']);
                                  TextEditingController editTo =
                                  TextEditingController(text: monthlyData[i]['toDate']);
                                  TextEditingController editIncomeAmt =
                                  TextEditingController(
                                      text: monthlyData[i]['totalIncomeAmt']);
                                  TextEditingController editIncomeType =
                                  TextEditingController(text: monthlyData[i]['incomeType']);
                                  //DateTime _dialogSelectedDate = _selectedDate;
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(monthlyData[i]['incomeId'],
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
                                                        /*validator: (value) =>
                                                            _validateFormField(
                                                                value, 'From'),*/
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
                                                        /*validator: (value) =>
                                                            _validateFormField(
                                                                value, 'To'),*/
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
                                                        /*validator: (value) =>
                                                            _validateFormField(
                                                                value, 'Income Type'),*/
                                                        onChanged: (value) {
                                                          /*setState(() {
                                                            _monthlyincomeTypeError =
                                                            null; // Clear error message when text changes
                                                          });*/
                                                        },
                                                      ),
                                                      /*if (_monthlyincomeTypeError !=
                                                          null)*/
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                          child: Text(" ",
                                                           // _monthlyincomeTypeError!,
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
                                                        /*validator: (value) =>
                                                            _validateFormField(value,
                                                                'Income Amount'),*/
                                                        onChanged: (value) {
                                                          /*setState(() {
                                                            _monthlyincomeAmountError =
                                                            null; // Clear error message when text changes
                                                          });*/
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
                                                      /*if (_monthlyincomeAmountError !=
                                                          null)*/
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                          child: Text("",
                                                            //_monthlyincomeAmountError!,
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
                                            /*onPressed: () async {
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
                                                        'http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php'), // Replace with your PHP update endpoint

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
                                            },*/
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.teal),
                                            ),
                                            onPressed: () {  },
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
                                              'incomeId': monthlyData[i]['incomeId'],
                                            }),
                                          );

                                          if (response.statusCode == 200) {
                                            /*Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MonthlyDashboard(
                                                          uid: '',
                                                        )));*/
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
                     // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text('Income Amount: ${monthlyData[i]['totalIncomeAmt']}',
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        Text('Spent: ${monthlyData[i]['total_spent']}'),
                        Text('Remaining: ${monthlyData[i]['remaining']}'),
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
                                      onPressed: () {  },
                                      child: const Text("Close"),
                                      /*onPressed: () async {
                                        try {
                                          var response = await http.put(
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
                                          );
                                          if (response.statusCode == 200) {
                                            var statusResponse = await http.put(
                                              Uri.parse(
                                                  'http://localhost/BUDGET/lib/BUDGETAPI/UpdateStatus.php'), // Replace with your PHP endpoint to update status
                                              headers: <String, String>{
                                                'Content-Type':
                                                'application/json; charset=UTF-8',
                                              },
                                              body: jsonEncode({
                                                'incomeId': trip['incomeId'],
                                                'fromDate': trip[
                                                'fromDate'], // Include fromDate
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
                                      },*/
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
        },
      ),
    );
  }
}
