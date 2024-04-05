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

      body: Column(
        children: [
          TabBar(
            controller: _tabController,
/*
            indicator: BoxDecoration(
              //borderRadius: BorderRadius.horizontal(),
              color: Colors.blue,
            ),
*/
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,

            tabs: [
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
                Container(
                  child: Center(child: Text('')),
                ),
                // Weekly tab content
                Container(
                  child: Center(child: Text('')),
                ),
                // Custom tab content
                Container(
                  child: Center(child: Text('')),
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


                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MonthlyUi(),)); // Close the dialog
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Customize button color
                                      ),
                                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
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
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MonthlyUi(),)); // Close the dialog

                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Customize button color
                                      ),
                                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
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
                                ), /// fromdate
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
                                ), /// todate

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
                                ), ///incometype
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
                                ), ///incomeamount
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MonthlyUi(),)); // Close the dialog

                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Customize button color
                                      ),
                                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
                                    ), /// cancel
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
                                    ), /// save
                                  ],
                                ),  /// cancel & save
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

              AwesomeDialog(
                context: context,
                dialogType: DialogType.noHeader,
                width: 350,
                body: StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set your Income',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Add your form fields here
                          SizedBox(
                            height: 70,
                            width: 250,
                            child: TextFormField(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
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
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),



                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                            ),
                          ), /// fromdate
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 70,
                            width: 250,
                            child: TextFormField(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                              readOnly: true,
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
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                            ),
                          ), /// todate
                          ///
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
                          ), ///incometype
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
                          ), ///incomeamount

                          // Add more form fields as needed
                        ],
                      ),
                    );
                  },
                ),
                btnOk: ElevatedButton(
                  onPressed: () {
                    // Handle OK button press
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                btnCancel: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )..show();
            },
          ),
        ],
      )
          : null,
    );
  }
}
