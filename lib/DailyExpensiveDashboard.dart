import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'DashBoard.dart';
import 'dailyExpences.dart';

class DailyDashboard extends StatefulWidget {
  final String remainingAmount;

  DailyDashboard({
    Key? key,
    required this.remainingAmount,
  }) : super(key: key);

  @override
  State<DailyDashboard> createState() => _DailyDashboardState();
}

class _DailyDashboardState extends State<DailyDashboard> {
  List<Map<String, dynamic>> trips = [];
  List<dynamic> _savedDailyExpenses = [];
  List<dynamic> expenses = [];
  List<dynamic> data = [];
  double remainingAmount = 0;
  String wallet = '';

  String url =
      'http://localhost/BUDGET/lib/BUDGETAPI/dailyexpensesdashboard.php';

  /// fetchh monthly budget based on content
  Future<void> fetchExpenses() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        expenses = json.decode(response.body);
        print("Expenses Body: $expenses");
        // readRecords(expenses["incomeId"]);
      });
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  ///remaining fetch

  Future<void> readRecords() async {
    var url =
        'http://localhost/BUDGET/lib/BUDGETAPI/dailyexpensesdashboard.php';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Records: $data');
      // Assign fetched remaining amount to state variable
      setState(() {
        remainingAmount = data['sum_remaining'] ?? 0;
      });
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  Future<void> updateRecord2(String incomeId) async {
    String url2 =
        'http://localhost/BUDGET/lib/BUDGETAPI/dailyexpensesdashboard.php';
    print(url2);

    var headers = {'Content-Type': 'application/json'};

    // Update backend
    var response = await http.put(
      Uri.parse(url2),
      headers: headers,
      body: jsonEncode({
        'incomeId': incomeId,
        'remaining': widget.remainingAmount,
        // Include other fields you want to update
      }),
    );
    if (response.statusCode == 200) {
      print("ResponseStatus: ${response.statusCode}");
      print("Response: ${response.body}");
    } else {
      print('Failed to update record: ${response.body}');
    }
  }

  Future<void> createRecord(String uid) async {
    String url2 =
        'http://localhost/BUDGET/lib/BUDGETAPI/dailyexpensescalculation.php';
    print(url2);

    var headers = {'Content-Type': 'application/json'};

    try {
      var response = await http.post(
        Uri.parse(url2),
        headers: headers,
        body: jsonEncode({
          'uid': uid,
          'wallet': widget.remainingAmount,
          // Include other fields you want to update
        }),
      );
      if (response.statusCode == 200) {
        print(url2);
        print("ResponseStatus: ${response.statusCode}");
        print("Response: ${response.body}");
      } else {
        print('Failed to update record: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  ///wallet fetch

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

      if (responseBody is List && responseBody.isNotEmpty) {
        // Assuming the response is a list of wallet data
        var firstRecord = responseBody.first;
        if (firstRecord.containsKey('wallet')) {
          String walletAmount = firstRecord['wallet'];
          setState(() {
            wallet = walletAmount;
          });

          // Show the alert with wallet amount
          showWalletAmountAlert(context, walletAmount);
        } else {
          print('Wallet data not found in the response');
        }
      } else {
        print('Invalid or empty response format');
      }
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  Future<void> showWalletAmountAlert(
      BuildContext context, String walletAmount) async {
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
                    'Your current wallet amount is: $walletAmount'), // Display wallet amount in the alert dialog
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

  //remaining update

  // Function to update remaining field in database for a specific incomeId

  ///wallet_log fetch

  Future<void> walletLogFetch(String uid) async {
    var url =
        'http://localhost/BUDGET/lib/BUDGETAPI/walletdeduction.php?uid=$uid';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Wallet_Log: $data');
      // Assign fetched remaining amount to state variable
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  /// Based on Insert

  @override
  void initState() {
    super.initState();
    fetchExpenses();
    //readRecords();
    // readRecords(incomeId)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple.shade50,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: AppBar(
            title: Text(
              "Daily Expenses",
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
                onPressed: () {
                  if (expenses.isNotEmpty) {
                    // Check if expenses list is not empty
                    getwallet(expenses[0]['uid'],
                        context); // Assuming you want to use the first expense's UID
                  }
                },
                icon: const Icon(
                  Icons.wallet_rounded,
                  color: Colors.white,
                ),
              ),
            ],
            titleSpacing: 0.0,
            centerTitle: true,
            toolbarHeight: 60.2,
            toolbarOpacity: 0.8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            elevation: 0.0,
            backgroundColor: Color(0xFF8155BA),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (BuildContext context, int index) {
                return buildDashboard(context, expenses[index]);
              },
            ),
          ),
        ));
  }

  Widget buildDashboard(BuildContext context, Map<String, dynamic> expenses) {
    bool remainingAmountGreaterThanZero = false; // Default value
    // Extract toDate and incomeId from expenses
    String toDate = expenses['toDate'];
    String incomeId = expenses['incomeId'];

    // Get current date
    DateTime currentDate = DateTime.now();
    String formattedCurrentDate = currentDate.toString().split(' ')[0];
    bool isToDatePastOrCurrent =
        toDate.compareTo(formattedCurrentDate) <= 0; // Format: YYYY-MM-DD

    // Check if toDate is equal to current date

    try {
      double remainingAmountValue = double.parse(widget.remainingAmount);
      remainingAmountGreaterThanZero = remainingAmountValue > 0;
    } catch (e) {
      print('Error parsing remaining amount: $e');
    }

    return GestureDetector(
      onTap: isToDatePastOrCurrent
          ? null // Disable onTap if toDate is current date
          : () {
              String incomeId = expenses['incomeId'];
              // Extract incomeId from expenses
              String uid = expenses['uid'];
              // readRecords(incomeId); // Pass incomeId to readRecords function
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpensePage(
                            incomeId: expenses['incomeId'],
                            amount: expenses['totalAmount'],
                            fromdate: expenses['fromDate'],
                            todate: expenses['toDate'],
                            uid: expenses['uid'],
                          )));
              walletLogFetch(uid);
            },
      child: Card(
        child: ListTile(
          title: Text('Category: ${expenses['category']}'),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${expenses['totalAmount']}'),
                  Text('From Date: ${expenses['fromDate']}'),
                  Text('To Date: ${expenses['toDate']}'),
                  // Text('UID: ${expenses['uid']}'),
                  // Text('IncomeID:${expenses['incomeId']}')
                ],
              ),
              isToDatePastOrCurrent
                  ? PopupMenuButton(
                      itemBuilder: (BuildContext context) {
                        // Format: YYYY-MM-DD
                        // Conditionally build PopupMenuItem based on remaining amount
                        if (isToDatePastOrCurrent) {
                          return [
                            const PopupMenuItem(
                              child: Text("Edit"),
                              value: "Edit",
                            ),
                            const PopupMenuItem(
                              child: Text("Close Month"),
                              value: "MonthClose",
                            ),
                          ];
                        } else {
                          return [
                            const PopupMenuItem(
                              child: Text("Close Month"),
                              value: "MonthClose",
                            ),
                          ];
                        }
                      },
                      onSelected: (value) async {
                        updateRecord2(expenses['incomeId']);
                        //createRecord(expenses['uid']);
                        // Update remaining field in database for this incomeI
                        if (value == "Edit") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExpensePage(
                                        incomeId: expenses['incomeId'],
                                        amount: expenses['totalAmount'],
                                        fromdate: expenses['fromDate'],
                                        todate: expenses['toDate'],
                                        uid: expenses['uid'],
                                      )));
                        } else if (value == "MonthClose") {
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
                                        var response = await http.put(
                                          Uri.parse(
                                              'http://localhost/BUDGET/lib/BUDGETAPI/updatestatus.php'),
                                          headers: <String, String>{
                                            'Content-Type':
                                                'application/json; charset=UTF-8',
                                          },
                                          body: jsonEncode(<String, dynamic>{
                                            'incomeId': expenses['incomeId'],
                                            'fromDate': expenses[
                                                'fromDate'], // Include fromDate
                                            'toDate': expenses[
                                                'toDate'], // Include toDate
                                          }),
                                        );
                                        if (response.statusCode == 200) {
                                          var statusResponse = await http.put(
                                            Uri.parse(
                                                'http://localhost/BUDGET/lib/BUDGETAPI/updatestatus.php'), // Replace with your PHP endpoint to update status
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json; charset=UTF-8',
                                            },
                                            body: jsonEncode({
                                              'incomeId': expenses['incomeId'],
                                              'fromDate': expenses[
                                                  'fromDate'], // Include fromDate
                                              'toDate': expenses['toDate'],
                                              'status': 'closed',
                                            }),
                                          );
                                          if (statusResponse.statusCode ==
                                              200) {
                                            print(
                                                "Response Body: ${response.body}");
                                            print(
                                                "Response Status: ${response.statusCode}");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DailyDashboard(
                                                        remainingAmount: ''),
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
                                                    DailyDashboard(
                                                        remainingAmount: '')));
                                      } catch (e) {
                                        print('Error closing month: $e');
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          // Handle MonthClose action if needed
                        }
                      },
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
