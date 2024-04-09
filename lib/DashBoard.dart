import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
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
import 'monthlyDahboard.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(223, 250, 92, 1),
      Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(175, 63, 62, 1.0),
      Color.fromRGBO(254, 154, 92, 1),
    ]
  ];

  final colorList = <Color>[
    Colors.greenAccent,
  ];

  double totalBudget = 1000;
  double totalSpent = 500;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController monthlyincome = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();
  TextEditingController _textEditingController =
      TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));

  void _showReportDialog(String selectedMonth) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? totalIncomes = prefs.getStringList('totalIncomes');
    int totalMonthlyIncome = prefs.getInt('totalIncome_$selectedMonth') ?? 0;

    // Filter incomes for the selected month
    List<String> filteredIncomes = totalIncomes!.where((incomeId) {
      String selectedIncomeMonth =
          prefs.getString('$incomeId:selectedMonth') ?? '';
      return selectedIncomeMonth == selectedMonth;
    }).toList();

    // Create a list of DataRow for the DataTable
    List<DataRow> rows = filteredIncomes.map((incomeId) {
      String incomeType = prefs.getString('$incomeId:incomeType') ?? '';
      String incomeAmount = prefs.getString('$incomeId:totalincome') ?? '';
      String selectedDate = prefs.getString('$incomeId:selectedDate') ??
          ''; // Retrieve selected date
      return DataRow(cells: [
        DataCell(Text(selectedDate)), // Display selected date
        DataCell(Text(incomeType)),
        DataCell(Text(incomeAmount)),
      ]);
    }).toList();
    // Show the dialog with the DataTable
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          width: 200,
          child: AlertDialog(
            // title: Text("$selectedMonth Income"), // Modify title to reflect selected month
            content: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Income Type')),
                  DataColumn(label: Text('Income')),
                ],
                rows: rows,
              ),
            ),
            actions: [
              Text("Total Monthly Income: $totalMonthlyIncome"),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String incomeId = DateTime.now().millisecondsSinceEpoch.toString();
    String totalincome = monthlyincome.text;
    String totalincomeType = monthlyincomeType.text;
    String selectedDate = DateFormat.yMMMd().format(_selectedDate);
    String selectedMonth = DateFormat.M().format(_selectedDate);

    // Check if there's any existing income for the selected month
    int totalMonthlyIncome = prefs.getInt('totalIncome_$selectedMonth') ?? 0;
    totalMonthlyIncome += int.parse(totalincome);

    // Update the total income for the selected month
    prefs.setInt('totalIncome_$selectedMonth', totalMonthlyIncome);

    prefs.setString('$incomeId:totalincome', totalincome);
    prefs.setString('$incomeId:incomeType', totalincomeType);
    prefs.setString('$incomeId:selectedDate', selectedDate);
    prefs.setString('$incomeId:selectedMonth', selectedMonth);

    List<String> totalIncomes = prefs.getStringList('totalIncomes') ?? [];
    totalIncomes.add(incomeId);
    prefs.setStringList('totalIncomes', totalIncomes);

    print('Trip ID: $incomeId');
    print('Total income: $totalincome');
    print('Income Type: $totalincomeType');
    print('Selected Date: $selectedDate');

    // Print the total monthly income
    print('Total Monthly Income for $selectedMonth: $totalMonthlyIncome');

    //_showAlert();
  }

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

  @override
  Widget build(BuildContext context) {
    double remainingBudget = totalBudget - totalSpent;

    Map<String, double> dataMap = {
      'Total Spent': totalSpent,
      'Remaining Budget': remainingBudget,
    };
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      bottomNavigationBar: BottomBarBubble(
        color: Color(0xFF8155BA),
        items: [
          BottomBarItem(
            iconData: Icons.home,
            label: 'Home',
          ),
          BottomBarItem(
            iconData: Icons.signal_cellular_alt_sharp,
            label: 'Tracking',
          ),
          BottomBarItem(
            iconData: Icons.add,
            label: 'Spent',
          ),
          BottomBarItem(
            iconData: Icons.note_add,
            label: 'Records',
          ),
          BottomBarItem(
            iconData: Icons.settings,
            label: 'Settings',
          ),
        ],
        onSelect: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Reports(uid: "5"),
              ),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Settings(),
              ),
            );
          }
          // implement your select function here
        },
      ),
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
                            child: Text(
                              'My Budget',
                              style: Theme.of(context).textTheme.displayLarge,
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
                          MaterialPageRoute(builder: (context) =>  MonthlyDashboard(uid: '5',)),
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
    );
  }
}
