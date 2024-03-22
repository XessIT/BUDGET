import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DailyExpensiveDashboard.dart';
import 'DashBoard.dart';

class ExpensePage extends StatefulWidget {
  final String incomeId;

  const ExpensePage({Key? key, required this.incomeId}) : super(key: key);
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _isVisible = false;
  final TextEditingController monthlyincome = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();
  final TextEditingController incomeType = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  TextEditingController addNotes = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  TextEditingController _categoryController = TextEditingController();
  int _selectedExpenseIndex = -1; // Initialize selected index here
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _categories = [
    {'name': 'Bus Fair', 'icon': Icons.directions_bus},
    {'name': 'Clothing', 'icon': Icons.shopping_bag},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Entertainment', 'icon': Icons.local_movies},
    {'name': 'Fuel', 'icon': Icons.local_gas_station},
    {'name': 'Gifts', 'icon': Icons.card_giftcard},
    {'name': 'Groceries', 'icon': Icons.shopping_cart},
    {'name': 'Health', 'icon': Icons.local_hospital},
    {'name': 'Restaurant', 'icon': Icons.restaurant},
    {'name': 'Snacks', 'icon': Icons.fastfood},
    {'name': 'Tea', 'icon': Icons.local_drink},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Utilities', 'icon': Icons.settings},
    {'name': 'Other', 'icon': Icons.category},
  ];

  List<Map<String, String>> _savedDetails = [];
  bool _showBudgetAlert = false;
  String? errormsg = '';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
    _fetchExpenseData();
    fetchDataFromSharedPreferences();
    //_loadDataForMonthly();
    _loadDataFromSharedPreferences(widget.incomeId);
  }

  ///capital letter starts code
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  // Dispose the controller when no longer needed
  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }


  void fetchDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? incomeIds = prefs.getStringList('totalIncomes');
   // List<String>? incomeIds = prefs.getStringList('totalIncomes');
    if (incomeIds != null) {
      for (String incomeId in incomeIds) {
        String? totalIncome = prefs.getString('$incomeId:totalincome');
        String? incomeType = prefs.getString('$incomeId:incomeType');
        String? selectedFromDate =
        prefs.getString('$incomeId:selectedFromDate');
        String? selectedToDate = prefs.getString('$incomeId:selectedToDate');
        if (totalIncome != null &&
            incomeType != null &&
            selectedFromDate != null &&
            selectedToDate != null) {
          setState(() {
            trips.add({
              'incomeId': incomeId,
              'totalIncome': totalIncome,
              'incomeType': incomeType,
              'selectedFromDate': selectedFromDate,
              'selectedToDate': selectedToDate,
            });
            fromDate.text = selectedFromDate;
            toDate.text = selectedToDate;
          });

          // Print statements for debugging
          print('Income ID: $incomeId');
          print('Total Income: $totalIncome');
          print('Income Type: $incomeType');
          print('Selected From Date: $selectedFromDate');
          print('Selected To Date: $selectedToDate');
        }
      }
    }
  }

  Future<void> _fetchExpenseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedDetailsJson = prefs.getStringList('savedDetails');
    if (savedDetailsJson != null) {
      setState(() {
        _savedDetails = savedDetailsJson
            .map((jsonString) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(jsonString);
            if (decoded is Map<String, dynamic>) {
              // Check if the decoded JSON is of the expected structure
              return Map<String, String>.from(decoded);
            } else {
              throw FormatException("Invalid JSON structure");
            }
          } catch (e) {
            // Handle JSON decoding error
            print("Error decoding JSON: $e");
            return null;
          }
        })
            .whereType<Map<String, String>>() // Filter out nulls
            .toList();
      });
    }
  }

  List<Map<String, dynamic>> trips = [];

  double _totalBudget = 0.0;

  Future<void> _loadDataFromSharedPreferences(String incomeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> loadedTrips = [];

    List<String> monthlyExpenses =
        prefs.getStringList('$incomeId:monthlyexpenses') ?? [];
    List<String>? notes = prefs.getStringList('$incomeId:notes') ?? [];

    List<Map<String, dynamic>> expenses = monthlyExpenses.map((expense) {
      var parts = expense.split(':');
      return {
        'monthcategory': parts[0],
        'monthlyamount': double.parse(parts[1]),
        'date': parts[2],
        'remarks': parts[3],
      };
    }).toList();

    loadedTrips.add({'expenses': expenses, 'notes': notes});

    // Calculate total monthly amount for Daily Expenses
    double totalDailyExpenses = 0;
    for (var trip in loadedTrips) {
      for (var expense in trip['expenses']) {
        if (expense['monthcategory'] == 'Daily Expenses') {
          _totalBudget += expense['monthlyamount'];
        }
      }
    }

    print('Total Monthly Amount for Daily Expenses: $_totalBudget');

    setState(() {
      trips = loadedTrips;
    });
  }



  @override
  Widget build(BuildContext context) {
    double totalExpenses = _calculateTotalExpenses();
    double remainingAmount = _totalBudget - totalExpenses;
    double debitAmount = totalExpenses - _totalBudget;
    if (_totalBudget != 0) {
      _showBudgetAlert = totalExpenses >= _totalBudget * 0.8;
    } else {
      // Handle the case where _totalBudget is zero
      // For example, set _showBudgetAlert to false or display a message
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          title: Center(
            child: Text(
              "Daily Expense",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before, color: Colors.white,),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const DailyDashboard()));
            },
          ),
          titleSpacing: 00.0,
          centerTitle: false,
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
            titlePadding: EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget\n',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextSpan(
                              text: "$_totalBudget",
                              style:
                              TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 8, left: 8, right: 8),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Spent\n ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextSpan(
                              text: "$totalExpenses",
                              style:
                              TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    if (remainingAmount > 0 && debitAmount <= 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remaining\n',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextSpan(
                                text: '$remainingAmount',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.orange),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    if (debitAmount > 0 && remainingAmount <= 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Debit\n',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextSpan(
                                text: '$debitAmount',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.orange),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget Date\n',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextSpan(
                              text: '${fromDate.text} to ${toDate.text}',
                              style:
                              TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     _showReportDialog();
                    //   },
                    //   child: CircleAvatar(
                    //     backgroundColor: Color(0xFF8155BA),
                    //     radius: 20,
                    //     child: Image.asset(
                    //       'assets/wallet.png',
                    //       width: 30,
                    //       height: 30,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                      elevation: 4, // Adjust elevation as needed
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            colors: [Color(0xFF8155BA), Color(0xFFB667DF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        width: double.infinity,
                        height: _showBudgetAlert
                            ? 200.0
                            : 150.0, // Adjust height based on condition
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListView(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "$_totalBudget",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  if (remainingAmount > 0 && debitAmount <= 0)
                                    Column(
                                      children: [
                                        Text(
                                          "Remaining",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "$remainingAmount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  if (debitAmount > 0 && remainingAmount <= 0)
                                    Column(
                                      children: [
                                        Text(
                                          "Debit",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "$debitAmount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  Column(
                                    children: [
                                      Text(
                                        "Spent",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "$totalExpenses",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(
                                        10.0), // Adjust the radius as needed
                                    right: Radius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  child: SizedBox(
                                    height: 10,
                                    child: LinearProgressIndicator(
                                      value: _totalBudget != 0
                                          ? totalExpenses / _totalBudget
                                          : 0,
                                      backgroundColor:
                                      Colors.white.withOpacity(0.5),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        totalExpenses <= _totalBudget * 0.8
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: _showBudgetAlert ? 1.0 : 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'You have spent more than 80% of your budget.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Column(
                                children: _buildExpenseList(),
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 16, // Adjust bottom margin as needed
                          right: 16, // Adjust right margin as needed
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF8155BA),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(
                                    0,
                                    2,
                                  ), // changes position of shadow
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible; // Toggle visibility
                                });
                              },
                              child: Icon(Icons.add),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isVisible)
                Positioned(
                  top: 200.0,
                  left: 50.0,
                  right: 50.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.navigate_before,
                                color: Color(0xFF8155BA),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                initialDatePickerMode: DatePickerMode.day,
                              );
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                  _dateController.text =
                                      DateFormat('dd-MM-yyyy').format(picked);
                                  _isAddButtonClicked =
                                  true; // Set flag when date is picked
                                });
                              }
                            },
                            style: Theme.of(context).textTheme.bodySmall,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          SizedBox(height: 20),
                          TypeAheadFormField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _categoryController,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black),
                              onChanged: (value) {
                                String capitalizedValue =
                                capitalizeFirstLetter(value);
                                _categoryController?.value =
                                    _categoryController!.value.copyWith(
                                      text: capitalizedValue,
                                      selection: TextSelection.collapsed(
                                          offset: capitalizedValue.length),
                                    );
                                setState(() {
                                  errormsg = null;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black),
                              ),
                            ),
                            suggestionsCallback: (String pattern) async {
                              // Filter categories based on the pattern
                              final List<String> filteredCategories =
                              _categories
                                  .where((category) => category['name']
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                                  .map((category) =>
                              category['name'] as String)
                                  .toList();
                              // Return the filtered categories as suggestions
                              return Future.value(filteredCategories);
                            },
                            itemBuilder: (context, String suggestion) {
                              // Find the category based on the suggestion
                              final category = _categories.firstWhere(
                                      (category) => category['name'] == suggestion);
                              // Build and return the list tile
                              return ListTile(
                                // leading: Icon(
                                //   category['icon'],
                                //   color: Color(0xFF8155BA),
                                // ),
                                title: Text(suggestion,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.black)),
                              );
                            },
                            onSuggestionSelected: (String suggestion) {
                              setState(() {
                                _categoryController.text =
                                    suggestion; // Update controller text
                                _selectedCategory = suggestion;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: TextFormField(
                                  controller: _amountController,
                                  onChanged: (value) {
                                    setState(() {
                                      errormsg = null;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please Enter a Amount';
                                    }
                                    return null;
                                  },
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.black),
                                  decoration: InputDecoration(
                                      labelText: 'Amount',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF8155BA),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: const Offset(
                                        0,
                                        2,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_formKey.currentState!.validate())
                                            _saveExpense(remainingAmount);
                                        });
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.note_alt_sharp,
                                    color: Colors.green),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Notes",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors
                                                  .blue), // Change text size and color
                                        ),
                                        content: Container(
                                          width: double.maxFinite,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Category: ${_categoryController.text}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .black), // Change text size and color
                                              ),
                                              Text(
                                                "Amount: ${_amountController.text}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .black), // Change text size and color
                                              ),
                                              TextField(
                                                controller: addNotes,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors
                                                        .black), // Change input text size and color
                                                decoration: InputDecoration(
                                                  labelText: "Add",
                                                  labelStyle: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .blue), // Change label text size and color
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors
                                                      .red), // Change button text size and color
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                ///  String category = monthlyexpenses[i]['monthcategory']!.text;
                                                ///  String amount = monthlyexpenses[i]['monthlyamount']!.text;
                                              });
                                            },
                                            child: Text(
                                              "OK",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors
                                                      .green), // Change button text size and color
                                            ),
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(
                                                  0xFF8155BA)), // Set border color here
                                          borderRadius: BorderRadius.zero,

                                          // Remove border radius
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveExpense(remainingAmount);

                                  setState(() {
                                    _isVisible =
                                    !_isVisible; // Toggle visibility
                                  });

                                  // Clear selected date and set to current date
                                  _selectedDate = DateTime.now();
                                  _dateController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(_selectedDate);

                                  _amountController.clear();
                                  _categoryController.clear();
                                  _selectedCategory = null;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor: Color(0xFF8155BA),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Modify _buildExpenseList method to remove expenses when they are deleted
  List<Widget> _buildExpenseList() {
    Map<String, List<Map<String, String>>> groupedExpenses = {};

    for (var expense in _savedDetails) {
      String date = expense['Date']!;
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    List<Widget> expenseWidgets = [];

    groupedExpenses.forEach((date, expenses) {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      String dayName = DateFormat('EEEE').format(parsedDate);

      List<Widget> expensesList = [];
      for (var expense in expenses) {
        IconData iconData = Icons.category;
        for (var category in _categories) {
          if (category['name'] == expense['Category']) {
            iconData = category['icon'];
            break;
          }
        }

        expensesList.add(
          GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedExpenseIndex == expenses.indexOf(expense)) {
                  _selectedExpenseIndex = -1; // Deselect if tapped again
                } else {
                  _selectedExpenseIndex = expenses.indexOf(expense);
                }
              });
            },
            child: Padding(
              padding:
              const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Color(0xFF8155BA),
                      //   child: Icon(
                      //     iconData,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFF8155BA)),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${expense['Category']}',
                                      style:
                                      Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${double.parse(expense['Amount']!).toStringAsFixed(2)}',
                                      style:
                                      Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Visibility(
                                  visible: expense['remarks'] != null &&
                                      expense['remarks']!.isNotEmpty,
                                  child: Text(
                                    "Remarks: ${expense['remarks'] ?? ''}",
                                    style:
                                    Theme.of(context).textTheme.bodySmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_selectedExpenseIndex == expenses.indexOf(expense))
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Color(0xFF8155BA),
                            ),
                            onPressed: () {
                              _deleteExpense(expense);
                            },
                          ),
                        if (_selectedExpenseIndex == expenses.indexOf(expense))
                          IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFF8155BA)),
                            onPressed: () {
                              _editExpense(expense);
                              setState(() {
                                if (_selectedExpenseIndex ==
                                    expenses.indexOf(expense)) {
                                  _selectedExpenseIndex =
                                  -1; // Deselect if tapped again
                                } else {
                                  _selectedExpenseIndex =
                                      expenses.indexOf(expense);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }

      expenseWidgets.add(
        Padding(
          padding:
          const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dayName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Text(
                '$date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
      );

      expenseWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: expensesList,
            ),
          ),
        ),
      );
    });

    return expenseWidgets;
  }

  void _deleteExpense(Map<String, String> expense) {
    setState(() {
      _savedDetails.remove(expense);
      _updateSavedDetailsInSharedPreferences();
      _selectedExpenseIndex = -1; // Deselect after deletion
    });
  }

  void _editExpense(Map<String, String> expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditExpenseScreen(expense: expense, categories: _categories),
      ),
    ).then((value) {
      if (value != null && value is Map<String, String>) {
        setState(() {
          // Find the index of the edited expense in _savedDetails
          int index = _savedDetails.indexWhere((element) =>
          element['Category'] == expense['Category'] &&
              element['Amount'] == expense['Amount']);
          if (index != -1) {
            // Update the expense details
            _savedDetails[index]['Category'] = value['Category']!;
            _savedDetails[index]['Amount'] = value['Amount']!;
            _updateSavedDetailsInSharedPreferences();
          }
        });
      }
    });
  }

  Future<void> _updateSavedDetailsInSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDetailsJson =
    _savedDetails.map((expense) => jsonEncode(expense)).toList();
    await prefs.setStringList('savedDetails', savedDetailsJson);
    await prefs.setDouble('totalBudget', _totalBudget); // Setting total budget
  }

  // Modify _saveExpense method to update SharedPreferences
  bool _isAddButtonClicked = false;

  void _saveExpense(double remainingAmount) async {
    String date = _dateController.text;
    String category = _categoryController.text;
    String amount = _amountController.text;
    String notes = addNotes.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDetailsJson = prefs.getStringList('savedDetails') ?? [];

    double totalExpenses = _calculateTotalExpenses();
    double debitAmount = totalExpenses - _totalBudget;

    savedDetailsJson.add(jsonEncode({
      'Date': date,
      'Category': category,
      'Amount': amount,
      'Remarks': notes,
    }));

    await prefs.setStringList('savedDetails', savedDetailsJson);
    // Recalculate remaining amount and update it in SharedPreferences
    remainingAmount = _totalBudget - totalExpenses;
    await prefs.setDouble('remainingAmount', remainingAmount);

    // Print the updated remaining amount
    print('Updated Remaining Amount: $remainingAmount');

    setState(() {
      _savedDetails.add({
        'Date': date,
        'Category': category,
        'Amount': amount,
        'Remarks': notes,
      });

      if (!_isAddButtonClicked) {
        _selectedDate = DateTime.now();
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      } else {
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      }

      _amountController.clear();
      _categoryController.clear();
      addNotes.clear();
      _selectedCategory = null;
    });

    if (!_isAddButtonClicked) {
      setState(() {
        _isAddButtonClicked = false; // Reset flag only for the save button
      });
    }
  }

  double _calculateTotalExpenses() {
    double totalExpenses = 0;
    for (var expense in _savedDetails) {
      totalExpenses += double.parse(expense['Amount'] ?? '0');
    }
    return totalExpenses;
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Map<String, String> expense;
  final List<Map<String, dynamic>> categories;

  const EditExpenseScreen(
      {Key? key, required this.expense, required this.categories})
      : super(key: key);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late String _selectedCategory;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.expense['Category']!;
    _amountController = TextEditingController(text: widget.expense['Amount']);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Expenses Edit",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
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
      body: Padding(
        padding:
        const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
              border: Border.all(color: Color(0xFF8155BA)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButtonFormField(
                      value: _selectedCategory,
                      items: widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category['name'],
                          child: Row(
                            children: [
                              Icon(
                                category['icon'],
                                color: Color(0xFF8155BA),
                              ),
                              SizedBox(width: 10),
                              Text(
                                category['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value.toString();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _amountController,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _updateExpense();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: Color(0xFF8155BA),
                      ),
                      child: Text(
                        'Update',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateExpense() {
    final updatedExpense = {
      'Category': _selectedCategory,
      'Amount': _amountController.text,
    };

    // Update the expense details
    Navigator.pop(context, updatedExpense);
  }
}
