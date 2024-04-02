/*
import 'dart:convert';

import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'TripView.dart';
import 'package:http/http.dart' as http;

class TripDetails extends StatefulWidget {
  const TripDetails({super.key});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _noOfPersonController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController totalBudget = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  List<Map<String, TextEditingController>> expenses = [];
  List<Map<String, TextEditingController>> expenses2 = [];
  List<Map<String, String>> submittedItems = []; // List to hold submitted items
  //double totalBudget = 0.0;
  double totalAmountPerson = 0.00;
  bool istextfield = false;
  bool isTableVisible = false;
  final _formKey = GlobalKey<FormState>();
  String commonErrorMessage = "Please fill in all required fields";
  Set<String> highlightedFields = {};

  ///save to phpmyadmin

  Future<void> AddTrip() async {
    try {
      final url = Uri.parse('http://localhost/mybudget/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate = DateFormat('dd-MM-yyyy').parse(fromDate.text);
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate = DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);

      final response = await http.post(
        url,
        body: jsonEncode({
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date": fromformattedDate,
          "to_date": toformattedDate,
          "budget": totalBudget.text,
          "no_of_members": _noOfPersonController.text,
        }),
      );

      print("ResponseStatus: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }




  List<String> getEmptyFields() {
    List<String> emptyFields = [];
    if (_tripNameController.text.isEmpty) {
      emptyFields.add("_tripNameController");
    }
    if (_sourceController.text.isEmpty) {
      emptyFields.add("_sourceController");
    }
    // Add checks for other fields here

    return emptyFields;
  }

  bool areFieldsEmpty() {
    if (_tripNameController.text.isEmpty ||
        _sourceController.text.isEmpty ||
        fromDate.text.isEmpty ||
        toDate.text.isEmpty ||
        totalBudget.text.isEmpty ||
        _noOfPersonController.text.isEmpty) {
      return true;
    }
    return false;
  }

  void updateAmountPerHead() {
    setState(() {
      // This will trigger a rebuild when either amount or no of persons change.
    });
  }

  String calculateAmountPerHead() {
    double amount = double.tryParse(totalBudget.text) ?? 0.0;
    int noOfPersons = int.tryParse(_noOfPersonController.text) ?? 1;

    // Calculate amount per head
    double amountPerHead = (amount / noOfPersons);

    // Round to the nearest integer
    int roundedAmount = amountPerHead.round();

    // If the decimal part is greater than or equal to 0.5, round up; otherwise, round down
    if ((amountPerHead - roundedAmount).abs() >= 0.5) {
      return (roundedAmount + 1).toString();
    } else {
      return roundedAmount.toStringAsFixed(2);
    }
  }

  void _addCategoryField() {
    setState(() {
      expenses.add({
        'category': TextEditingController(),
        'amount': TextEditingController(),
      });

      //_updateTotalBudget();
    });
  }

  void _addCategoryField2() {
    try {
      int maxRows = int.parse(_noOfPersonController.text);

      // Check if the current number of rows is less than or equal to the specified limit
      if (expenses2.length < maxRows) {
        setState(() {
          expenses2.add({
            'name': TextEditingController(),
            'perAmount': TextEditingController(),
          });

          _updateTotalBudget2();
        });
      } else {
        // Display a message or handle the case where the limit is reached
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text(
                  'Maximum number of members reached.\nif you want to add more members increase \nno of members count !'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child:
                  const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle the FormatException
      print('Error parsing the number of members: $e');
      // You might want to display an error message to the user here
    }
  }

  String _updateTotalBudget2() {
    totalAmountPerson = 0.00;
    for (var expense2 in expenses2) {
      double amount = double.tryParse(expense2['perAmount']!.text) ?? 0.0;
      totalAmountPerson += amount;
    }
    return totalAmountPerson.toStringAsFixed(2);
  }

  ///capital letter starts code
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  ///cookies save
  void _saveDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tripId = DateTime.now().millisecondsSinceEpoch.toString();

    prefs.setString('$tripId:tripName', _tripNameController.text);
    prefs.setString('$tripId:noOfPerson', _noOfPersonController.text);
    prefs.setString('$tripId:source', _sourceController.text);
    prefs.setString('$tripId:fromDate', fromDate.text);
    prefs.setString('$tripId:toDate', toDate.text);
    prefs.setString('$tripId:totalBudget', totalBudget.text);

    prefs.setString('$tripId:totalAmountPerson', totalAmountPerson.toString());

    List<String> expensesListPerson = expenses2.map((expense2) {
      return "${expense2['name']?.text}:${expense2['perAmount']?.text}";
    }).toList();
    prefs.setStringList('$tripId:persons', expensesListPerson);

    List<String> reportIds = prefs.getStringList('reportIds') ?? [];
    reportIds.add(tripId);
    prefs.setStringList('reportIds', reportIds);
  }

  @override
  void initState() {
    super.initState();
    _addCategoryField();
    _addCategoryField2();
    // _updateTotalBudget();
  }

  String? errormsg = '';

  Map<String, String> fieldErrorMessages = {
    "_tripNameController": "Trip Name",
    "_sourceController": "Location",
    "fromDate": "From Date",
    "toDate": "To Date",
    "totalBudget": "Budget Amount",
    "_noOfPersonController": "No of Members",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text(
            "Trip",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before,color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TripDashboard()));
            },
          ),
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.white70,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      errormsg ??
                          "", // Display the error message if it's not null
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _tripNameController,
                        onChanged: (value) {
                          setState(() {
                            errormsg = null;
                          });
                          String capitalizedValue =
                          capitalizeFirstLetter(value);
                          _tripNameController.value =
                              _tripNameController.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                        },
                        decoration: InputDecoration(
                          labelText: 'Trip Name',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          // Highlight empty field with red border
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior
                              .auto, // Hide label text when text is entered
                        ),
                      ),
                    ),

                    /// Trip Name
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _sourceController,
                        decoration: InputDecoration(
                            labelText: 'Location',
                            labelStyle: Theme.of(context).textTheme.labelMedium,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 12.0), // Adjust padding values
                            border: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(
                              //   10,
                              // ),
                            )),
                        onChanged: (value) {
                          setState(() {
                            errormsg = null;
                          });
                          String capitalizedValue =
                          capitalizeFirstLetter(value);
                          _sourceController.value =
                              _sourceController.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                        },
                      ),
                    ),

                    /// Location
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2300),
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
                          if (pickDate == null) return;
                          {
                            setState(() {
                              fromDate.text =
                                  DateFormat('dd-MM-yyyy').format(pickDate);
                              errormsg = null;
                            });
                          }
                        },
                        controller:
                        fromDate, // Set the initial value of the field to the selected date
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.date_range,
                            size: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "From",
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            //  borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    /// From date
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2300),
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
                          if (pickDate == null) return;
                          {
                            setState(() {
                              toDate.text =
                                  DateFormat('dd-MM-yyyy').format(pickDate);
                              errormsg = null;
                            });
                          }
                        },
                        controller: toDate,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.date_range,
                            size: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "To",
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            //  borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    /// To date
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: totalBudget,
                        onChanged: (_) => updateAmountPerHead(),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7)
                        ],
                        decoration: InputDecoration(
                          labelText: 'Budget',
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            size: 15,
                          ),
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    /// No of person
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _noOfPersonController,
                        onChanged: (_) => updateAmountPerHead(),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5)
                        ],
                        decoration: InputDecoration(
                          labelText: 'No of Members',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                if (totalBudget.text.isNotEmpty && _noOfPersonController.text.isNotEmpty)
                  Container(
                    width: 330,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 1.0, // Border width
                      ),
                      // borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Each Member will bear the amount of  ₹${calculateAmountPerHead()}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Total Received Amount: ₹${totalAmountPerson.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  // color: Colors.grey.shade200,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                                boxShadow: const [],
                                gradient: const LinearGradient(
                                  // Gradient background
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white70, Colors.white70],
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (var expense2 in expenses2)

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 8,
                                          right: 8,
                                          bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: expense2['name'],
                                              style:
                                              const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                String capitalizedValue =
                                                capitalizeFirstLetter(
                                                    value);
                                                expense2['name']?.value =
                                                    expense2['name']!
                                                        .value
                                                        .copyWith(
                                                      text:
                                                      capitalizedValue,
                                                      selection: TextSelection
                                                          .collapsed(
                                                          offset:
                                                          capitalizedValue
                                                              .length),
                                                    );
                                                setState(() {
                                                  // _updateTotalBudget();
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  hintText: expense2['name']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Name'
                                                      : null, // Hide label when amount is entered
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium),
                                              // keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: expense2['perAmount'],
                                              style:
                                              const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                setState(() {
                                                  _updateTotalBudget2();
                                                });
                                              },
                                              keyboardType:
                                              TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    5)
                                              ],
                                              decoration: InputDecoration(
                                                  hintText: expense2[
                                                  'perAmount']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Amount'
                                                      : null, // Hide label when amount is entered
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors
                                                    .red), // You can change the icon here
                                            onPressed: () {
                                              setState(() {
                                                expenses2.removeAt(expenses2
                                                    .indexOf(expense2));
                                                _updateTotalBudget2();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(totalBudget.text.isNotEmpty && _noOfPersonController.text.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Add .00 to the entered amount for each expense
                                for (var i = 0; i < expenses2.length; i++) {
                                  var currentAmount =
                                      expenses2[i]['perAmount']!.text;
                                  if (!currentAmount.contains('.')) {
                                    expenses2[i]['perAmount']!.text =
                                    '$currentAmount.00';
                                  }
                                }
                              });

                              _addCategoryField2();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.deepPurple, // Change button color here
                              elevation: 5, // Add elevation
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_tripNameController.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Trip Name";
                                    });
                                  } else if (_sourceController.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Location";
                                    });
                                  } else if (fromDate.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Select a From date";
                                    });
                                  } else if (toDate.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Select a To date";
                                    });
                                  } else if (totalBudget.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Budget";
                                    });
                                  } else if (_noOfPersonController
                                      .text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Number of persons";
                                    });
                                  } else {
                                    _saveDataToSharedPreferences();
                                    AddTrip();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content:
                                          const Text('Saved successfully'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                    const TripDashboard(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              child: const Text(
                                                'Ok',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                elevation: 5,
                              ),
                              child: const Text('Submit',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:http/http.dart' as http;

class TripDetails extends StatefulWidget {
  final String? userId;
  final String? type;
  const TripDetails({super.key, required this.userId, required this.type});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _noOfPersonController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController totalBudget = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  List<Map<String, TextEditingController>> expenses = [];
  List<Map<String, TextEditingController>> expenses2 = [];
  List<Map<String, String>> submittedItems = []; // List to hold submitted items
  //double totalBudget = 0.0;
  double totalAmountPerson = 0.00;
  bool istextfield = false;
  bool isTableVisible = false;
  final _formKey = GlobalKey<FormState>();
  String commonErrorMessage = "Please fill in all required fields";
  Set<String> highlightedFields = {};

  ///save to phpmyadmin starts...

/*
  Future<void> AddTrip() async {
    try {

      String? tripId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate = DateFormat('dd-MM-yyyy').parse(fromDate.text);
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate = DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      print("trip url:$url");
      List<Map<String, String>> membersData = [];
      for (var expense2 in expenses2) {
        String name = expense2['name']!.text;
        String mobile = expense2['mobile']!.text;
        String amount = expense2['perAmount']!.text;

        // Store these values in the desired format, like a map
        membersData.add({
          'name': name,
          'mobile': mobile,
          'amount': amount,
        });
      }
      final response = await http.post(
        url,
        body: jsonEncode({
          "trip_type":widget.type.toString(),
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date": fromformattedDate,
          "to_date": toformattedDate,
          "budget": totalBudget.text,
          "members": _noOfPersonController.text,
          "user_id":"7",
          "trip_id":tripId.toString(),
          // "member_name":"add name ",
          // "mobile":"add mobile",
          // "amount":"add amount",
          "members_data": expenses2.map((expense) => {
            "member_name": expense['name']!.text,
            "mobile": expense['mobile']!.text,
            "amount": expense['perAmount']!.text,
          }).toList(),
          "createdOn":DateTime.now().toString(),
        }),
      );
      print("T Response body: ${response.body}");
      print("T Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("T Response body: ${response.body}");
        print("T Response code: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }
*/

  String? tripId = DateTime.now().millisecondsSinceEpoch.toString();


  Future<void> AddTrip() async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/Trip.php');
      final DateTime fromparsedDate =
      DateFormat('dd-MM-yyyy').parse(fromDate.text);
      final fromformattedDate = DateFormat('yyyy-MM-dd').format(fromparsedDate);
      final DateTime toparsedDate =
      DateFormat('dd-MM-yyyy').parse(toDate.text);
      final toformattedDate = DateFormat('yyyy-MM-dd').format(toparsedDate);
      print("trip url:$url");

      List<Map<String, String>> membersData = [];
      for (var expense2 in expenses2) {
        membersData.add({
          'name': expense2['name']!.text,
          'mobile': expense2['mobile']!.text,
          'amount': expense2['perAmount']!.text,
        });
      }

      final response = await http.post(
        url,
        body: jsonEncode({
          "trip_type": widget.type.toString(),
          "trip_name": _tripNameController.text,
          "location": _sourceController.text,
          "from_date": fromformattedDate,
          "to_date": toformattedDate,
          "budget": totalBudget.text,
          "members": _noOfPersonController.text,
          "uid": "7",
          "trip_id": tripId.toString(),
          "members_data": membersData,
          "createdOn": DateTime.now().toString(),
        }),
      );

      // print("T Response body: ${response.body}");
      // print("T Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Trip added successfully!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip Added Successfully")));
        // print("T Response body: ${response.body}");
        // print("T Response code: ${response.statusCode}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during trip addition: $e");
      // Handle error as needed
    }
  }


  List<String> getEmptyFields() {
    List<String> emptyFields = [];
    if (_tripNameController.text.isEmpty) {
      emptyFields.add("_tripNameController");
    }
    if (_sourceController.text.isEmpty) {
      emptyFields.add("_sourceController");
    }
    // Add checks for other fields here

    return emptyFields;
  }

  bool areFieldsEmpty() {
    if (_tripNameController.text.isEmpty ||
        _sourceController.text.isEmpty ||
        fromDate.text.isEmpty ||
        toDate.text.isEmpty ||
        totalBudget.text.isEmpty ||
        _noOfPersonController.text.isEmpty) {
      return true;
    }
    return false;
  }

  void updateAmountPerHead() {
    setState(() {
      // This will trigger a rebuild when either amount or no of persons change.
    });
  }

  String calculateAmountPerHead() {
    double amount = double.tryParse(totalBudget.text) ?? 0.0;
    int noOfPersons = int.tryParse(_noOfPersonController.text) ?? 1;

    // Calculate amount per head
    double amountPerHead = (amount / noOfPersons);

    // Round to the nearest integer
    int roundedAmount = amountPerHead.round();

    // If the decimal part is greater than or equal to 0.5, round up; otherwise, round down
    if ((amountPerHead - roundedAmount).abs() >= 0.5) {
      return (roundedAmount + 1).toString();
    } else {
      return roundedAmount.toStringAsFixed(2);
    }
  }

  void _addCategoryField() {
    setState(() {
      expenses.add({
        'category': TextEditingController(),
        'amount': TextEditingController(),
      });

      //_updateTotalBudget();
    });
  }

  void _addCategoryField2() {
    try {
      int maxRows = int.parse(_noOfPersonController.text);

      // Check if the current number of rows is less than or equal to the specified limit
      if (expenses2.length < maxRows) {
        setState(() {
          expenses2.add({
            'name': TextEditingController(),
            'mobile': TextEditingController(),
            'perAmount': TextEditingController(),
          });

          _updateTotalBudget2();
        });
      } else {
        // Display a message or handle the case where the limit is reached
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text(
                  'Maximum number of members reached.\nif you want to add more members increase \nno of members count !'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child:
                  const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle the FormatException
      print('Error parsing the number of members: $e');
      // You might want to display an error message to the user here
    }
  }

  String _updateTotalBudget2() {
    totalAmountPerson = 0.00;
    for (var expense2 in expenses2) {
      double amount = double.tryParse(expense2['perAmount']!.text) ?? 0.0;
      totalAmountPerson += amount;
    }
    return totalAmountPerson.toStringAsFixed(2);
  }

  ///capital letter starts code
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  ///cookies save
/*
  void _saveDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tripId = DateTime.now().millisecondsSinceEpoch.toString();

    prefs.setString('$tripId:tripName', _tripNameController.text);
    prefs.setString('$tripId:noOfPerson', _noOfPersonController.text);
    prefs.setString('$tripId:source', _sourceController.text);
    prefs.setString('$tripId:fromDate', fromDate.text);
    prefs.setString('$tripId:toDate', toDate.text);
    prefs.setString('$tripId:totalBudget', totalBudget.text);

    prefs.setString('$tripId:totalAmountPerson', totalAmountPerson.toString());

    List<String> expensesListPerson = expenses2.map((expense2) {
      return "${expense2['name']?.text}:${expense2['perAmount']?.text}";
    }).toList();
    prefs.setStringList('$tripId:persons', expensesListPerson);

    List<String> reportIds = prefs.getStringList('reportIds') ?? [];
    reportIds.add(tripId);
    prefs.setStringList('reportIds', reportIds);
  }
*/

  @override
  void initState() {
    super.initState();
    _addCategoryField();
    _addCategoryField2();
    // _updateTotalBudget();
  }
  String? errormsg = '';

  Map<String, String> fieldErrorMessages = {
    "_tripNameController": "Trip Name",
    "_sourceController": "Location",
    "fromDate": "From Date",
    "toDate": "To Date",
    "totalBudget": "Budget Amount",
    "_noOfPersonController": "No of Members",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text(
            "Trip",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before,color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  TripDashboard()));
            },
          ),
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
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.white70,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      errormsg ??
                          "", // Display the error message if it's not null
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _tripNameController,
                        onChanged: (value) {
                          setState(() {
                            errormsg = null;
                          });
                          String capitalizedValue =
                          capitalizeFirstLetter(value);
                          _tripNameController.value =
                              _tripNameController.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                        },
                        decoration: InputDecoration(
                          labelText: 'Trip Name',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          // Highlight empty field with red border
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior
                              .auto, // Hide label text when text is entered
                        ),
                      ),
                    ),

                    /// Trip Name
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _sourceController,
                        decoration: InputDecoration(
                            labelText: 'Location',
                            labelStyle: Theme.of(context).textTheme.labelMedium,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 12.0), // Adjust padding values
                            border: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(
                              //   10,
                              // ),
                            )),
                        onChanged: (value) {
                          setState(() {
                            errormsg = null;
                          });
                          String capitalizedValue =
                          capitalizeFirstLetter(value);
                          _sourceController.value =
                              _sourceController.value.copyWith(
                                text: capitalizedValue,
                                selection: TextSelection.collapsed(
                                    offset: capitalizedValue.length),
                              );
                        },
                      ),
                    ),

                    /// Location
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2300),
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
                          if (pickDate == null) return;
                          {
                            setState(() {
                              fromDate.text =
                                  DateFormat('dd-MM-yyyy').format(pickDate);
                              errormsg = null;
                            });
                          }
                        },
                        controller:
                        fromDate, // Set the initial value of the field to the selected date
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.date_range,
                            size: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "From",
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            //  borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    /// From date
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2300),
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
                          if (pickDate == null) return;
                          {
                            setState(() {
                              toDate.text =
                                  DateFormat('dd-MM-yyyy').format(pickDate);
                              errormsg = null;
                            });
                          }
                        },
                        controller: toDate,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.date_range,
                            size: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "To",
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(
                            //  borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    /// To date
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: totalBudget,
                        onChanged: (_) => updateAmountPerHead(),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7)
                        ],
                        decoration: InputDecoration(
                          labelText: 'Budget',
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            size: 15,
                          ),
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    /// No of person
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.labelMedium,
                        controller: _noOfPersonController,
                        onChanged: (_) => updateAmountPerHead(),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5)
                        ],
                        decoration: InputDecoration(
                          labelText: 'No of Members',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0), // Adjust padding values
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                if (totalBudget.text.isNotEmpty && _noOfPersonController.text.isNotEmpty)
                  Container(
                    width: 330,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // Border color
                        width: 1.0, // Border width
                      ),
                      // borderRadius: BorderRadius.all(Radius.circular(8.0)), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Each Member will bear the amount of  ₹${calculateAmountPerHead()}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Total Received Amount: ₹${totalAmountPerson.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  // color: Colors.grey.shade200,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                                boxShadow: const [],
                                gradient: const LinearGradient(
                                  // Gradient background
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white70, Colors.white70],
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (var expense2 in expenses2)

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 8,
                                          right: 8,
                                          bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: expense2['name'],
                                              style:
                                              const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                String capitalizedValue =
                                                capitalizeFirstLetter(
                                                    value);
                                                expense2['name']?.value =
                                                    expense2['name']!
                                                        .value
                                                        .copyWith(
                                                      text:
                                                      capitalizedValue,
                                                      selection: TextSelection
                                                          .collapsed(
                                                          offset:
                                                          capitalizedValue
                                                              .length),
                                                    );
                                                setState(() {
                                                  // _updateTotalBudget();
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  hintText: expense2['name']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Name'
                                                      : null, // Hide label when amount is entered
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium),
                                              // keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: expense2['mobile'],
                                              style:
                                              const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                String capitalizedValue =
                                                capitalizeFirstLetter(
                                                    value);
                                                expense2['mobile']?.value =
                                                    expense2['mobile']!
                                                        .value
                                                        .copyWith(
                                                      text:
                                                      capitalizedValue,
                                                      selection: TextSelection
                                                          .collapsed(
                                                          offset:
                                                          capitalizedValue
                                                              .length),
                                                    );
                                                setState(() {
                                                  // _updateTotalBudget();
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  hintText: expense2['mobile']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Mobile'
                                                      : null, // Hide label when amount is entered
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium),
                                              // keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: expense2['perAmount'],
                                              style:
                                              const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                setState(() {
                                                  _updateTotalBudget2();
                                                });
                                              },
                                              keyboardType:
                                              TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    5)
                                              ],
                                              decoration: InputDecoration(
                                                  hintText: expense2[
                                                  'perAmount']!
                                                      .text
                                                      .isEmpty
                                                      ? 'Amount'
                                                      : null, // Hide label when amount is entered
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors
                                                    .red), // You can change the icon here
                                            onPressed: () {
                                              setState(() {
                                                expenses2.removeAt(expenses2
                                                    .indexOf(expense2));
                                                _updateTotalBudget2();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(totalBudget.text.isNotEmpty && _noOfPersonController.text.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // Add .00 to the entered amount for each expense
                                  for (var i = 0; i < expenses2.length; i++) {
                                    var currentAmount =
                                        expenses2[i]['perAmount']!.text;
                                    if (!currentAmount.contains('.')) {
                                      expenses2[i]['perAmount']!.text =
                                      '$currentAmount.00';
                                    }
                                  }
                                });

                                _addCategoryField2();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.deepPurple, // Change button color here
                                elevation: 5, // Add elevation
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_tripNameController.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Trip Name";
                                    });
                                  } else if (_sourceController.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Location";
                                    });
                                  } else if (fromDate.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Select a From date";
                                    });
                                  } else if (toDate.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Select a To date";
                                    });
                                  } else if (totalBudget.text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Budget";
                                    });
                                  } else if (_noOfPersonController
                                      .text.isEmpty) {
                                    setState(() {
                                      errormsg = "* Enter a Number of persons";
                                    });
                                  } else {
                                    // _saveDataToSharedPreferences();
                                    AddTrip();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content:
                                          const Text('Saved successfully'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TripDashboard(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              child: const Text(
                                                'Ok',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                elevation: 5,
                              ),
                              child: const Text('Submit',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
