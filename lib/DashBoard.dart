import 'dart:developer';

import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mybudget/balance.dart';
import 'package:mybudget/reports.dart';
import 'package:mybudget/settings.dart';
import 'package:mybudget/tripdashboard.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DailyExpensiveDashboard.dart';
import 'dailyExpences.dart';
import 'duplicate.dart';
import 'monthlyDahboard.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextEditingController _textEditingController =
      TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));

  @override
  void initState() {
    super.initState();
    fetchAllMonthEndRemaining();
    _loadLanguageFromStorage();
  }

  bool _languageSelectionDialogShown = false;
  bool _languageSelected =
      false; // Add a state variable to track language selection

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLanguageSelectionDialogStatus();
  }

  _checkLanguageSelectionDialogStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dialogShown = prefs.getBool('languageSelectionDialogShown') ?? false;
    if (!dialogShown) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showLanguageSelectionDialog(prefs); // Pass the prefs instance
      });
    }
  }

// Default language code
  void _showLanguageSelectionDialog(SharedPreferences prefs) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showLanguageDialog().then((selectedLanguage) {
                        Navigator.of(context).pop();
                        _languageSelectionDialogShown = true;
                        prefs.setBool('languageSelectionDialogShown', true);

                        // Set language selected state to true
                        setState(() {
                          _languageSelected = true;
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Color(0xFF8155BA),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.language, color: Colors.white),
                        Text(
                          'Choose Language',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.navigate_next, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLanguageDialog() async {
    String? newLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Change background color
          title: Text(
            "Select Language",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ), // Update title style
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageTile("English", "en_US"),
              _buildLanguageTile("Hindi", "hi_IN"),
              _buildLanguageTile("Tamil", "ta_IN"),
              _buildLanguageTile("Malayalam", "ml_IN"),
              _buildLanguageTile("Telugu", "te_IN"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red), // Change button text color
              ),
            ),
          ],
        );
      },
    );

    if (newLanguage != null) {
      setState(() {
        selectedLanguage = newLanguage;
      });
      Get.updateLocale(
          Locale(newLanguage.split('_')[0], newLanguage.split('_')[1]));
      GetStorage()
          .write('language', newLanguage); // Persist the selected language
    }
  }

  Widget _buildLanguageTile(String language, String languageCode) {
    return ListTile(
      title: Text(language),
      onTap: () {
        Navigator.pop(context, languageCode);
      },
    );
  }

  late String selectedLanguage = 'en_US';

  ///Load the saved language
  Future<void> _loadLanguageFromStorage() async {
    final storedLanguage = GetStorage().read('language');
    setState(() {
      selectedLanguage =
          storedLanguage ?? 'en_US'; // Default to English if not found
    });
    if (storedLanguage == null) {
      Get.updateLocale(Locale('en', 'US')); // Update locale to English
    } else {
      Get.updateLocale(Locale(
          selectedLanguage.split('_')[0], selectedLanguage.split('_')[1]));
    }
  }

  List<Map<String, dynamic>> trips = [];

  ///fetch balance
  Future<void> fetchAllMonthEndRemaining() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> fetchedTrips = [];
    double totalRemainingValue = 0; // Initialize total to 0

    for (String key in keys) {
      if (key.endsWith(':monthendRemaining')) {
        String monthId = key.split(':')[0];
        String? remainingValue = prefs.getString(key);
        String? fromDate = prefs.getString('$monthId:fromDate');
        String? toDate = prefs.getString('$monthId:toDate');
        if (remainingValue != null && fromDate != null && toDate != null) {
          // Extract numeric part of the string using regular expression
          RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
          Iterable<Match> matches = regExp.allMatches(remainingValue);
          double value = double.parse(matches.first.group(0)!);
          fetchedTrips.add({
            'monthId': monthId,
            'remainingValue': remainingValue,
            'fromDate': fromDate,
            'toDate': toDate,
          });
          // Add the remaining value to the total
          totalRemainingValue += value;
        }
      }
    }
    // Update state with fetched data
    setState(() {
      trips = fetchedTrips;
      print(
          'Total Remaining Value: ₹${totalRemainingValue.toStringAsFixed(2)}'); // Print the total remaining value
    });
  }

  /// for spped dial
  int _selectedIndex = 0;
  bool _isSpeedDialOpen = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        // Assuming index 2 is for the 'Spent' BottomBarItem
        _isSpeedDialOpen = true;
      } else {
        _isSpeedDialOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1000,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF8155BA),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.elliptical(100, 100),
                          bottomRight: Radius.elliptical(100, 100),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: IconButton(
                              icon: const Icon(Icons.navigate_before),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigatorExample()));
                              },
                            ),
                          ),
                          SizedBox(
                            width: 170,
                          ),

                          /// Expanision Tile

                          /*  GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Declare _dialogSelectedDate and initialize it with _selectedDate
                                      DateTime _dialogSelectedDate = _selectedDate;

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text("Set Your Income", style: Theme.of(context).textTheme.bodyLarge),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.deepPurple)
                                            ),
                                            shadowColor: Colors.deepPurple,
                                            content: SizedBox(
                                              height: 200,
                                              width: 190,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.arrow_left),
                                                        onPressed: () {
                                                          setState(() {
                                                            _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
                                                            _textEditingController.text = DateFormat.yMMMd().format(_dialogSelectedDate);

                                                          });
                                                        },
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                          onTap: () {
                                                            showDatePicker(
                                                              context: context,
                                                              initialDate: _selectedDate,
                                                              firstDate: DateTime(_selectedDate.year - 1),
                                                              lastDate: DateTime(_selectedDate.year + 1),
                                                              builder: (BuildContext context, Widget? child) {
                                                                return Theme(
                                                                  data: ThemeData.light().copyWith(
                                                                    colorScheme: ColorScheme.light().copyWith(
                                                                      primary: Colors.deepPurple, // Head color
                                                                    ),
                                                                  ),
                                                                  child: child!,
                                                                );
                                                              },
                                                            ).then((pickedDate) {
                                                              if (pickedDate != null) {
                                                                setState(() {
                                                                  _selectedDate = pickedDate;
                                                                });
                                                              }
                                                            });
                                                          },
                                                          controller: TextEditingController(text: DateFormat.yMMMd().format(_selectedDate)),
                                                          readOnly: true,
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none, // Remove the border
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.arrow_right),
                                                        onPressed: () {
                                                          setState(() {
                                                            _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  TextFormField(
                                                    controller: monthlyincomeType,
                                                    decoration: InputDecoration(
                                                        labelText: 'Income Type',
                                                        labelStyle: Theme.of(context).textTheme.bodySmall,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),

                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        )
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  TextFormField(
                                                    controller: monthlyincome,
                                                    decoration: InputDecoration(
                                                        labelText: 'Income Amount',
                                                        labelStyle: Theme.of(context).textTheme.bodySmall,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),

                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),

                                                        )
                                                    ),

                                                  ),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [

                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _saveDataToSharedPreferences();
                                                          // Save data here
                                                          // Close the AlertDialog
                                                          //Navigator.of(context).pop();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => DashBoard()),
                                                          );
                                                        },
                                                        child: Text("Save"),
                                                      ),

                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: Color(0xFF8155BA),
                                  radius: 20,
                                  child: Image.asset(
                                    'assets/wallet.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5,),
                              IconButton(
                                icon: Icon(Icons.expand_circle_down,color: Colors.white,),
                                onPressed: () async {
                                  // Show month picker
                                  DateTime? pickedMonth = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(_selectedDate.year - 1),
                                    lastDate: DateTime(_selectedDate.year + 1),
                                    initialDatePickerMode: DatePickerMode.year,
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light().copyWith(
                                            primary: Colors.deepPurple, // Head color
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedMonth != null) {
                                    // Show report dialog for the selected month
                                    String selectedMonth = DateFormat.M().format(pickedMonth);
                                    _showReportDialog(selectedMonth);
                                  }
                                },
                              ),*/
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to another page when the card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Balance()),
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80, // Adjust this size as needed
                                        height:
                                            80, // Adjust this size as needed
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white, // Shadow color
                                              spreadRadius: 5, // Spread radius
                                              blurRadius: 7, // Blur radius
                                              offset:
                                                  Offset(0, 3), // Shadow offset
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.account_box,
                                            color: Colors.yellowAccent,
                                            size:
                                                40, // Adjust the size of the icon as needed
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Personal Budget".tr,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    //  Text('Total Remaining Value: ₹${totalRemainingValue.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// personal budget
                        GestureDetector(
                          onTap: () {
                            // Navigate to another page when the card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DailyDashboard(
                                        remainingAmount: '',
                                      )),
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.data_exploration,
                                            color: Colors.green,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text("Daily Expenses".tr,
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )

                        /// Daily Expensive
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to another page when the card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MonthlyDashboard(
                                    uid: '5',
                                  )),
                        );
                      },
                      child: Container(
                        width: 170,
                        height: 170,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: 80, // Adjust this size as needed
                                    height: 80, // Adjust this size as needed
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white, // Shadow color
                                          spreadRadius: 5, // Spread radius
                                          blurRadius: 7, // Blur radius
                                          offset: Offset(0, 3), // Shadow offset
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.people,
                                        color: Colors.orange,
                                        size:
                                            40, // Adjust the size of the icon as needed
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Monthly Budget".tr,
                                  style: TextStyle(fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Family Budget
                    GestureDetector(
                      onTap: () {
                        // Navigate to another page when the card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TripDashboard()),
                        );
                      },
                      child: Container(
                        width: 170,
                        height: 170,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: 80, // Adjust this size as needed
                                    height: 80, // Adjust this size as needed
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white, // Shadow color
                                          spreadRadius: 5, // Spread radius
                                          blurRadius: 7, // Blur radius
                                          offset: Offset(0, 3), // Shadow offset
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.travel_explore,
                                        color: Colors.green,
                                        size:
                                            40, // Adjust the size of the icon as needed
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Trip Budget".tr,
                                  style: TextStyle(fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      ///_isSpeedDialOpen
    );
  }
}
