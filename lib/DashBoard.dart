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






/// Language start
  @override
  void initState() {
    super.initState();
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
/// language end


  @override
  Widget build(BuildContext context) {

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
                builder: (context) => Reports(uid: "1"),
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
      appBar: AppBar(
        title: Text(''),
        iconTheme: IconThemeData(color: Colors.white), // Set icon color here

        backgroundColor: Color(0xFF8155BA),

      ),
      drawer: Drawer(

        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Implement action for item 1
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Implement action for item 2
              },
            ),
            // Add more ListTile widgets for additional menu items
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: 500,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Container(
                        height: 200,
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
                                '',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                            SizedBox(
                              width: 170,
                            ),
        
                            /// Expanision Tile
        
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
                          ),  /// personal budget
        
        
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
                          )   /// Daily Expensive
        
        
                        ],
                      ),
                    ],
                  ),
                ), ///personal daily
                Positioned(
                  left: 0,
                  right: 0,
                  top: 110,
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
                ), /// family trip
              ],
            ),
          ),
        ),
      ),
    );
  }
}
