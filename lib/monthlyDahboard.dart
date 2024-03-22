import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'DashBoard.dart';
import 'MonthlyBudget2.dart';

class MonthlyDashboard extends StatefulWidget {
  final String? user_id;
  const MonthlyDashboard({Key? key, required  this.user_id}) : super(key: key);

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
  final TextEditingController monthlyincomeType = TextEditingController();
  TextEditingController _textEditingControllerFrom = TextEditingController();
  TextEditingController _textEditingControllerTo = TextEditingController();

  String? _monthlyincomeTypeError;
  String? _monthlyincomeAmountError;

  String? _validateFormField2(String? value, String fieldName) {
    // Regular expression to check if the input contains only alphabets
    RegExp alphabetsOnly = RegExp(r'^[a-zA-Z]+$');

    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    } else if (!alphabetsOnly.hasMatch(value)) {
      return '$fieldName should contain only alphabets';
    }
    return null;
  }

  String? _validateFormField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }



  @override
  void initState() {
    super.initState();
    fetchDataFromSharedPreferences();
  }




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

  /*void fetchDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? incomeIds = prefs.getStringList('totalIncomes');
    if (incomeIds != null) {
      for (String incomeId in incomeIds) {
        String? totalIncome = prefs.getString('$incomeId:totalincome');
        String? incomeType = prefs.getString('$incomeId:incomeType');
        String? selectedFromDate = prefs.getString('$incomeId:selectedFromDate');
        String? selectedToDate = prefs.getString('$incomeId:selectedToDate');
        if (totalIncome != null && incomeType != null && selectedFromDate != null && selectedToDate != null) {
          setState(() {
            trips.add({
              'incomeId': incomeId,
              'totalIncome': totalIncome,
              'incomeType': incomeType,
              'selectedFromDate': selectedFromDate,
              'selectedToDate': selectedToDate,
            });
          });
        }
      }
    }
  }*/

  // Other methods remain unchanged
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DashBoard()));
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
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        //DateTime _dialogSelectedDate = _selectedDate;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text("Set Your Date", style: Theme.of(context).textTheme.bodyLarge),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
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
                                                        const ColorScheme.light(
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
                                                    _textEditingControllerFrom.text = DateFormat('dd-MM-yyyy').format(pickDate);
                                                  });
                                                }
                                              },
                                              controller:
                                              _textEditingControllerFrom, // Set the initial value of the field to the selected date
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.date_range,color: Colors.teal,size: 14,),
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelText: "From",
                                                labelStyle: Theme.of(context).textTheme.labelMedium,
                                                border: OutlineInputBorder(
                                                  //  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              validator: (value) => _validateFormField(value, 'From'),

                                            ),
                                          ),

                                          SizedBox(
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
                                          ),
                                        ],
                                      ), /// DATE
                                      SizedBox(height: 15),
                                      SizedBox(
                                        height: 70,
                                        width: 250,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              controller: monthlyincomeType,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: 'Income Type',
                                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only alphabets
                                              ],
                                              validator: (value) => _validateFormField(value, 'Income Type'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeTypeError = null; // Clear error message when text changes
                                                });
                                              },
                                            ),
                                            if (_monthlyincomeTypeError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  _monthlyincomeTypeError!,
                                                  style: TextStyle(color: Colors.red),
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
                                              style: Theme.of(context).textTheme.bodyMedium,

                                              controller: monthlyincome,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: 'Income Amount',
                                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                              ),
                                              validator: (value) => _validateFormField(value, 'Income Amount'),
                                              onChanged: (value) {
                                                setState(() {
                                                  _monthlyincomeAmountError = null; // Clear error message when text changes
                                                });
                                              },
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(7)
                                              ],
                                            ),

                                            if (_monthlyincomeAmountError != null)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(
                                                  _monthlyincomeAmountError!,
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              )
                                          ],
                                        ),



                                      ),  ///Income Amount

                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Validate the form
                                    if (_formKey.currentState!.validate()) {
                                      // All fields are valid, proceed with your logic
                                      if (monthlyincomeType.text.isEmpty) {
                                        // Set error message for monthlyincomeType
                                        setState(() {
                                          _monthlyincomeTypeError = 'Income Type is required.';
                                        });

                                      }
                                      else  if (monthlyincome.text.isEmpty) {
                                        // Set error message for monthlyincomeType
                                        setState(() {
                                          _monthlyincomeAmountError = 'Income Amount is required.';
                                        });

                                      }
                                      else {
                                        // monthlyincomeType is not empty, proceed with saving data and navigating
                                        _saveDataToSharedPreferences();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MonthlyDashboard(user_id: "9"),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Fields are not valid, trigger a rebuild to display error messages
                                      setState(() {});
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                                  ),
                                  child: Text("Ok", style: TextStyle(color: Colors.white)),
                                ),




                              ],
                              backgroundColor: Colors.teal.shade50,
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8155BA), Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TyperAnimatedTextKit(

                              isRepeatingAnimation: true,
                              speed: Duration(milliseconds: 100),
                              text: const ['+ Set Your Budget'],
                              textStyle: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Text(
                //   'Month End Remaining: ${trip['monthEndRemaining'] ?? ''}',
                // ),

// Inside your onPressed callback for closing the month

                SizedBox(height: 5),
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

  Set<String> displayedIncomeIds = Set();

  Widget buildTripContainer(BuildContext context, Map<String, dynamic> trip) {
      if (displayedIncomeIds.contains(trip['incomeId'])) {
      return Container();
    }

    displayedIncomeIds.add(trip['incomeId']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyBudget2(
              incomeId: trip['incomeId'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 350,
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
                    child: Text('From: ${trip['selectedFromDate']}', style: Theme.of(context).textTheme.labelMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text('To: ${trip['selectedToDate']}', style: Theme.of(context).textTheme.labelMedium),
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
                      const PopupMenuItem(
                        child: Text("Close"),
                        value: "monthClose",
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "edit") {

                      }
                      else if (value == "delete") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text("Are you sure you want to delete this Budget?"),
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
                                    // Delete the data from SharedPreferences
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.remove('${trip['incomeId']}:totalincome');
                                    prefs.remove('${trip['incomeId']}:incomeType');
                                    prefs.remove('${trip['incomeId']}:selectedFromDate');
                                    prefs.remove('${trip['incomeId']}:selectedToDate');
                                    prefs.remove('${trip['incomeId']}:selectedMonth');

                                    // Remove incomeId from the list of displayedIncomeIds
                                    displayedIncomeIds.remove(trip['incomeId']);

                                    // Update UI
                                    setState(() {});

                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const MonthlyDashboard(user_id: "9"))); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else if (value == "monthClose") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Close"),
                              content: const Text("Are you sure you want to close this Budget?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Close"),
                                  onPressed: () async {
                                    try {
                                      // Retrieve fromDate and toDate from trip data
                                      String fromDate = trip['selectedFromDate'];
                                      String toDate = trip['selectedToDate'];

                                      // Store totalRemaining value as string
                                      String totalRemaining = trip['totalRemaining'].trim();

                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String monthId = DateTime.now().millisecondsSinceEpoch.toString();

                                      // Save fromDate, toDate, and totalRemaining to SharedPreferences
                                      prefs.setString('$monthId:fromDate', fromDate);
                                      prefs.setString('$monthId:toDate', toDate);
                                      prefs.setString('$monthId:monthendRemaining', totalRemaining);
                                      prefs.setBool('${trip['incomeId']}:monthClose', true);

                                      // Print the remaining value
                                      print('Remaining Value for monthId $monthId: $totalRemaining');

                                      // Close the dialog
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const MonthlyDashboard(user_id: "9")));
                                    } catch (e) {
                                      print('Error closing month: $e');
                                      // Handle the error, e.g., show a message to the user
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
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Income Amount: ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: trip['totalIncome'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      /*RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Income Amount: ',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            TextSpan(
                              text: trip['totalRemaining'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,)
            ],
          ),
        ),
      ),
    );
  }

  void _saveDataToSharedPreferences() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String incomeId = DateTime.now().millisecondsSinceEpoch.toString();

    String totalincome = monthlyincome.text;
    String totalincomeType = monthlyincomeType.text;
    String fromDate = _textEditingControllerFrom.text;
    String toDate = _textEditingControllerTo.text;
    String selectedMonth = DateFormat.M().format(_fromDate);

    int totalMonthlyIncome = prefs.getInt('totalIncome_$selectedMonth') ?? 0;
    totalMonthlyIncome += int.parse(totalincome);

    prefs.setInt('totalIncome_$selectedMonth', totalMonthlyIncome);

    prefs.setString('$incomeId:totalincome', totalincome);
    prefs.setString('$incomeId:incomeType', totalincomeType);
    prefs.setString('$incomeId:selectedFromDate', fromDate);
    prefs.setString('$incomeId:selectedToDate', toDate);
    prefs.setString('$incomeId:selectedMonth', selectedMonth);

    List<String> totalIncomes = prefs.getStringList('totalIncomes') ?? [];
    totalIncomes.add(incomeId);
    prefs.setStringList('totalIncomes', totalIncomes);

    print('Income ID: $incomeId');
    print('Total income: $totalincome');
    print('Income Type: $totalincomeType');
    print('From Date: $fromDate');
    print('To Date: $toDate');

    print('Total Monthly Income for $selectedMonth: $totalMonthlyIncome');
  }
}
