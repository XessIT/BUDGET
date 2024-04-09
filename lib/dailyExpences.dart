import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:mybudget/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:intl/intl.dart';

import 'DailyExpensiveDashboard.dart';
import 'DashBoard.dart';
import 'MonthlyBudget2.dart';
import 'duplicate.dart';
import 'monthlyDahboard.dart';

class ExpensePage extends StatefulWidget {
  final String incomeId;
  final String amount;
  final String fromdate;
  final String todate;
  final String uid;

  const ExpensePage({
    Key? key,
    required this.incomeId,
    required this.amount,
    required this.fromdate,
    required this.todate,
    required this.uid,
  }) : super(key: key);
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year;
  }

  bool _isVisible = false;
  bool showRadioButtons = false;
  String? selectedOption;
  final TextEditingController monthlyincome = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();
  final TextEditingController incomeType = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  TextEditingController addNotes = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  String? _selectedId;

  String _selectedExpenseIndex = '-1'; // Initialize selected index here

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
  List<dynamic> _savedDailyExpenses = [];
  bool _showBudgetAlert = false;
  String wallet = '';
  double remainingAmount = 0.0;
  double totalAmount = 0.0;

  String? errormsg = '';
  String url = ('http://localhost/mybudget/lib/BUDGETAPI/dailyexpense.php');
  int? _radioValue;

  Future<void> readRecords(String incomeId) async {
    var url =
        'http://localhost/mybudget/lib/BUDGETAPI/dailyexpense.php'; // Replace with your actual URL
    var modifiedUrl =
        Uri.parse(url).replace(queryParameters: {'incomeId': incomeId});

    var response = await http.get(modifiedUrl);

    if (response.statusCode == 200) {
      setState(() {
        _savedDailyExpenses = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  // Function to send data to PHP endpoint
  Future<void> insertExpense() async {
    try {
      print("Url: $url");
      print("IncomeId: ${widget.incomeId}");
      var response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
            'remarks': addNotes.text,
            'category': _categoryController.text,
            'amount': _amountController.text,
            'incomeId': widget.incomeId,
            'fromDate': widget.fromdate,
            'toDate': widget.todate,
            'uid': widget.uid
          }));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        readRecords(widget.incomeId);
        print('Expense inserted successfully');
      } else {
        // Handle HTTP error
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }

  ///edit
  Future<void> updateRecord(NavigatorState nav) async {
    var headers = {'Content-Type': 'application/json'};

    var response = await http.put(Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'id': _selectedId,
          'category': _selectedCategory,
          'amount': _amountController.text
        }));

    if (response.statusCode == 200) {
      nav.pop();
      readRecords(widget.incomeId);
    } else {
      print('Failed to update record: ${response.body}');
    }
  }

  Future<void> deleteRecord(dynamic expense, NavigatorState nav) async {
    double budgetAmount = double.tryParse(widget.amount) ?? 0.0;
    double totalExpenses = _calculateTotalExpenses();
    double newExpenseAmount = double.tryParse(_amountController.text) ?? 0.0;
    double amountNeeded = (totalExpenses + newExpenseAmount) - budgetAmount;

    if (amountNeeded > 0) {
      try {
        var headers = {'Content-Type': 'application/json'};
        var body = jsonEncode({'id': expense['id']});

        var response =
            await http.delete(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
          nav.pop();
          readRecords(widget.incomeId);
          //returnAmountToWallet(amountNeeded);
        } else {
          print('Failed to delete record: ${response.body}');
        }
      } catch (e) {
        print('Error deleting record: $e');
      }
    } else {
      // Handle case where no amount needs to be returned to the wallet
      try {
        var headers = {'Content-Type': 'application/json'};
        var body = jsonEncode({'id': expense['id']});

        var response =
            await http.delete(Uri.parse(url), headers: headers, body: body);

        if (response.statusCode == 200) {
          nav.pop();
          readRecords(widget.incomeId);
        } else {
          print('Failed to delete record: ${response.body}');
        }
      } catch (e) {
        print('Error deleting record: $e');
      }
    }
  }

  /// Calculation
  Future<void> getwallet(String uid, BuildContext context) async {
    var url =
        'http://localhost/BUDGET/lib/BUDGETAPI/dailyexpensescalculation.php';
    var modifiedUrl = Uri.parse(url).replace(queryParameters: {'uid': uid});

    var response = await http.get(modifiedUrl);

    if (response.statusCode == 200) {
      print(url);
      print('uid : $uid');

      // Parse the JSON response as a map directly
      var responseBody = jsonDecode(response.body);

      if (responseBody.containsKey('total_wallet')) {
        String totalWallet = responseBody['total_wallet'];
        print('Total Wallet Amount: $totalWallet');
        showWalletAmountAlert(context, totalWallet);
      } else {
        print('Total wallet amount not found in the response');
      }
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

// Import material.dart for Flutter's alert dialog

  Future<void> showWalletAmountAlert(
      BuildContext context, String totalWallet) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wallet Amount'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Your current wallet amount is: $totalWallet'), // Display wallet amount in the alert dialog
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  /// wallet update

  // void checkExpensesAndSave() async {
  //   String category = _categoryController.text;
  //   String amount = _amountController.text;
  //   double budgetAmount = double.parse(widget.amount);
  //   double totalExpenses = _calculateTotalExpenses();
  //   double newExpenseAmount = double.parse(_amountController.text);
  //   double remainingBudget = budgetAmount - (totalExpenses + newExpenseAmount);
  //
  //   if (remainingBudget >= 0) {
  //     insertExpense();
  //
  //     /// ithu akoum
  //     // Sufficient balance, navigate to monthly expenses
  //   } else {
  //     double amountNeeded = (totalExpenses + newExpenseAmount) - budgetAmount;
  //     String category = _categoryController.text;
  //     String amount = _amountController.text;
  //
  //     print('Category dilog up dialog: $category');
  //     print('Amount dilog up dialog: $amount');
  //
  //     AwesomeDialog(
  //       context: context,
  //       dialogType: DialogType.infoReverse,
  //       headerAnimationLoop: true,
  //       animType: AnimType.bottomSlide,
  //       title: 'Inufficient Balance',
  //       reverseBtnOrder: true,
  //       btnOkOnPress: () async {
  //         print('Category inside dialog: $category');
  //         print('Amount inside dialog: $amount');
  //
  //         // Close the dialog
  //         // Navigate to monthly expenses screen
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => MonthlyDashboard()),
  //         );
  //
  //         // await insertExpense(category, amount); // Insert expense with category and amount
  //       },
  //       btnCancelOnPress: () {
  //         AwesomeDialog(
  //           context: context,
  //           dialogType: DialogType.infoReverse,
  //           title: 'Do you Want Take Your Amount From Wallet',
  //           reverseBtnOrder: true,
  //           btnOkText: 'Yes',
  //           btnCancelText: 'No',
  //           btnOkOnPress: () async {
  //             /*  String category = _categoryController.text;
  //       String amount = _amountController.text;*/
  //
  //             print('Category inside dialog: $category');
  //             print('Amount inside dialog: $amount');
  //             insertExpense();
  //
  //             await updateWalletAmount(widget.uid, amountNeeded);
  //           },
  //           btnCancelOnPress: () {
  //             Navigator.of(context).pop();
  //           },
  //         ).show();
  //       },
  //       desc:
  //           'Do you want to spend this amount from your monthly expenses? Remaining amount needed: $amountNeeded',
  //     ).show();
  //   }
  // }
  //
  // void returnAmountToWallet(double amountReturned) {
  //   updateWalletAmount(
  //       widget.uid, -amountReturned); // Negative amount to return
  // }

  Future<void> updateWalletAmount(String uid, double amountNeeded) async {
    try {
      var url =
          'http://localhost/mybudget/lib/BUDGETAPI/dailyexpensescalculation.php';
      var response = await http.put(
        Uri.parse(url),
        body: jsonEncode({
          'action': 'update_wallet',
          'uid': uid,
          'amount_needed': amountNeeded.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Wallet amount updated successfully');
      } else {
        print('Failed to update wallet amount: ${response.body}');
      }
    } catch (e) {
      print('Error updating wallet amount: $e');
    }
  }

  ///update wallet

  Future<void> updateWallet(String uid, String incomeId, double remainingAmount,
      String todate) async {
    try {
      var url = 'http://localhost/BUDGET/lib/BUDGETAPI/walletupdate.php';
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'uid': uid,
          'incomeId': incomeId,
          'remainingAmount': remainingAmount.toStringAsFixed(
              2), // Format remainingAmount to fixed decimal places
          'todate': todate,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print("uid: $uid");
        print("incomeId: $incomeId");
        print("remainingAmount: $remainingAmount");
        print("todate: $todate");
        print("URL: $url");
        print('Daily Wallet amount updated successfully');
      } else {
        print('Failed to update wallet amount: ${response.body}');
      }
    } catch (e) {
      print('Error updating wallet amount: $e');
    }
  }

  Future<void> loadDataAndCalculateExpenses() async {
    await readRecords(widget.incomeId); // Load data

    // Calculate total expenses
    _calculateTotalExpenses();

    // Convert the 'amount' string to double
    double budgetAmount = double.tryParse(widget.amount) ?? 0.0;
    print('Budget Amount: $budgetAmount');

    // Update remaining amount based on totalAmount and budget
    remainingAmount = budgetAmount - totalAmount;
    print('Remaining Amount: $remainingAmount');

    // Update the wallet with the correct remainingAmount if totalAmount is calculated
    if (totalAmount != 0) {
      updateWallet(widget.uid, widget.incomeId, remainingAmount, widget.todate);
    }
  }

  double _calculateTotalExpenses() {
    double budget = double.parse(widget.amount);
    double totalExpenses = 0;
    for (var expense in _savedDailyExpenses) {
      try {
        if (expense['amount'] != null && expense['amount'].isNotEmpty) {
          totalExpenses += double.parse(expense['amount']);
        }
      } catch (e) {
        print("Error parsing amount: ${expense['amount']}");
        // Handle the error, such as skipping this expense or logging the issue
      }
    }
    setState(() {
      totalAmount = totalExpenses;
      remainingAmount = budget - totalAmount;
      print("remaining : $remainingAmount");
      print("total spent: $totalAmount");
      if (_totalBudget != 0) {
        _showBudgetAlert = totalAmount >= budget * 0.8;
      } else {
        // Handle the case where _totalBudget is zero
        // For example, set _showBudgetAlert to false or display a message
      }
    });
    return totalExpenses;
  }

  @override
  void initState() {
    super.initState();
    readRecords(widget.incomeId);
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
    //_fetchExpenseData();

    // Load data and calculate total expenses
    loadDataAndCalculateExpenses();
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
    _amountController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> trips = [];

  double _totalBudget = 0.0;

  // Convert widget.amount to a numeric type (e.g., double)

  @override
  Widget build(BuildContext context) {
    _calculateTotalExpenses();
    double totalExpenses = totalAmount;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Center(
            child: Text(
              "Daily Expenses",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.navigate_before,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyDashboard(
                    remainingAmount: remainingAmount.toString(),
                  ),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                getwallet(widget.uid, context); // Pass your income ID here
              },
              icon: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
              ),
            ),
          ],
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
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.only(left: 20.0, bottom: 16.0),
            title: Row(
              children: [
                /*  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget\n',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextSpan(
                              text: widget.amount.toString(),
                              style: TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),  /// Budget
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
                              style: TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ), /// Spent
                    if (remainingAmount > 0)
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
                                style: TextStyle(fontSize: 16, color: Colors.orange),
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
                              text: '${widget.fromdate} \n ${widget.todate}',
                              style: TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),*/
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (remainingAmount <= 0)
                        TextButton(
                            onPressed: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.question,
                                animType: AnimType.rightSlide,
                                title: 'Get Amount',
                                desc:
                                    'Choose where you want to get amount from:',
                                body: Column(
                                  children: [
                                    RadioListTile(
                                      title: const Text('Monthly expenses'),
                                      value: 0,
                                      groupValue: _radioValue,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _radioValue = value!;
                                          Navigator.of(context)
                                              .pop(); // Close dialog
                                          // Navigate to a new screen based on the selected option
                                          // Replace '/monthly_expenses' with your desired route
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                MonthlyDashboard(
                                              uid: '',
                                            ),
                                          )); // Close the dialog
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      title: Text('Wallet'),
                                      value: 1,
                                      groupValue: _radioValue,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _radioValue = value!;
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.infoReverse,
                                            title: 'Reverse Amount',
                                            desc:
                                                'Do you want to reverse this amount from next month?',
                                            btnOkText: 'Yes',
                                            btnCancelText: 'No',
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () {
                                              // Perform actions when OK is pressed
                                            },
                                          ).show();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                btnCancelOnPress: () {},
                                btnCancelText: 'Cancel',
                              ).show();
                            },
                            child: Text("Get Amount ",
                                style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),

                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20), // Set border radius to 20
                      border: Border.all(
                        color: Colors.grey, // Border color (grey)
                        width: 1, // Border width
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                  8.0), // Add padding as needed
                              child: Text(
                                '${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.fromdate))} / '
                                '${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.todate))}',
                              ),
                            ),
                          ],
                        ),

                        /// Budget

                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(SimpleIcons.bitcomet,
                                      color: Colors
                                          .white), // Set the background color of the circle avatar
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Align the text widgets in the center
                                    children: [
                                      Text(
                                        'Budget',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      SizedBox(
                                        width: 70,
                                      ),
                                      Text(
                                        '₹${double.parse(widget.amount).toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height:
                                          2), // Add space between the row and the text widgets
                                  const SizedBox(
                                    width: 200, // Set the desired width
                                    child: LinearProgressIndicator(
                                      value: 1.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                  )
                                ],
                              ), // Adjust the space between the icon and progress bar
                            ],
                          ),
                        ),

                        ///Budget

                        /// Spent
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start, // Align the text widgets in the center

                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: totalExpenses >
                                          double.parse(widget.amount)
                                      ? Colors
                                          .red // Orange color when spent exceeds received amount
                                      : Colors.red,
                                  child: const Icon(SimpleIcons.affine,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Spent',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      SizedBox(width: 70),
                                      Text(
                                        '₹${totalExpenses.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height:
                                          2), // Add space between the row and the text widgets
                                  Container(
                                    width: 200, // Set the desired width
                                    child: LinearProgressIndicator(
                                      value: totalExpenses /
                                          double.parse(widget.amount),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        totalExpenses >
                                                double.parse(widget.amount)
                                            ? Colors
                                                .teal // Orange color when spent exceeds received amount
                                            : Colors.red, // Red color for debit
                                      ),
                                    ),
                                  )
                                ],
                              ), // Adjust the space between the icon and progress bar
                            ],
                          ),
                        ),

                        ///Spent ///

                        /// Remaining
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  child: Icon(SimpleIcons.adobeaftereffects,
                                      color: Colors.white),
                                  backgroundColor: remainingAmount >= 0
                                      ? Colors
                                          .green // Green color when remaining amount is positive or zero
                                      : Colors
                                          .red, // Red color when remaining amount is negative
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Remaining',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                      SizedBox(width: 50),
                                      Text(
                                        '₹${remainingAmount < 0 ? "0.00" : remainingAmount.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          2), // Add space between the row and the text widgets
                                  Container(
                                    width: 200, // Set the desired width
                                    child: LinearProgressIndicator(
                                      value: remainingAmount >= 0
                                          ? 1.0 -
                                              (remainingAmount /
                                                  double.parse(widget.amount))
                                          : 0.0, // Prevent negative values from affecting the progress bar
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        remainingAmount >= 0
                                            ? Colors
                                                .green // Green color when remaining amount is positive or zero
                                            : Colors
                                                .red, // Red color when remaining amount is negative
                                      ),
                                    ),
                                  ),
                                ],
                              ), // Adjust the space between the icon and progress bar
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// my bar

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
                                initialDate: DateTime.now(),
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
                          const SizedBox(height: 20),
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
                              const SizedBox(
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
                                            ;
                                        });
                                      },
                                      child: const Icon(
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
                                        title: const Text(
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
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .black), // Change text size and color
                                              ),
                                              Text(
                                                "Amount: ${_amountController.text}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors
                                                        .black), // Change text size and color
                                              ),
                                              TextField(
                                                controller: addNotes,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors
                                                        .black), // Change input text size and color
                                                decoration:
                                                    const InputDecoration(
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
                                            child: const Text(
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
                                            child: const Text(
                                              "OK",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors
                                                      .green), // Change button text size and color
                                            ),
                                          ),
                                        ],
                                        shape: const RoundedRectangleBorder(
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  // Retrieve category and amount values using setState
                                  setState(() {
                                    String category = _categoryController.text;
                                    String amount = _amountController.text;
                                    insertExpense();

                                    // Call checkExpensesAndSave() passing the context, category, and amount
                                    // checkExpensesAndSave();
                                  });

                                  setState(() {
                                    _isVisible =
                                        !_isVisible; // Toggle visibility
                                  });

                                  // Clear selected date and set to current date
                                  _selectedDate = DateTime.now();
                                  _dateController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(_selectedDate);

                                  _selectedCategory = null;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor: Color(0xFF8155BA),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          /// Save button
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

  //Modify _buildExpenseList method to remove expenses when they are deleted
  List<Widget> _buildExpenseList() {
    Map<String, dynamic> groupedExpenses = {};

    for (var expense in _savedDailyExpenses) {
      String date = expense['date']!;
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add({...expense, 'show': false});
    }
    List<Widget> expenseWidgets = [];

    groupedExpenses.forEach((date, expenses) {
      String formattedDate =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

      List<Widget> expensesList = [];
      for (var expense in expenses) {
        IconData iconData = Icons.category;
        for (var category in _categories) {
          if (category['name'] == expense['category']) {
            iconData = category['icon'];
            break;
          }
        }

        expensesList.add(
          GestureDetector(
            onTap: () {
              var id = expense['id'];
              setState(() {
                _selectedExpenseIndex = id;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 40, top: 5, bottom: 5, left: 10),
              child: Column(
                children: [
                  Row(
                    children: [
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
                                      ' ${expense['category']}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '₹${double.parse(expense['amount']!).toStringAsFixed(2)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
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
                        if (_selectedExpenseIndex == expense['id'])
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFF8155BA),
                            ),
                            onPressed: () {
                              _deleteExpense(expense);
                            },
                          ),
                        if (_selectedExpenseIndex == expense['id'])
                          IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFF8155BA)),
                            onPressed: () async {
                              _selectedId = expense['id'];
                              _selectedCategory = expense['category'];
                              _amountController.text = expense['amount']!;
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Edit Expense'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonFormField(
                                        value: _selectedCategory,
                                        items: _categories.map((category) {
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
                                                      ?.copyWith(
                                                          color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategory =
                                                value.toString();
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
                                      TextField(
                                        controller: _amountController,
                                        decoration: const InputDecoration(
                                            labelText: 'Amount'),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await updateRecord(
                                            Navigator.of(context));
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              );
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '$formattedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
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
            margin:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            padding: const EdgeInsets.all(10.0),
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

  void _deleteExpense(dynamic expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteRecord(
                    expense, Navigator.of(context)); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Modify _saveExpense method to update SharedPreferences
  bool _isAddButtonClicked = false;
}
