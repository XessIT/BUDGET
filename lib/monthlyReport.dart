import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:intl/intl.dart';

class MonthlyReportPage extends StatefulWidget {
  final String uid;
  const MonthlyReportPage({super.key,
    required this.uid
  });
  @override
  _MonthlyReportPageState createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<String> incomeIds = [];

  @override
  void initState() {
    getData();
    super.initState();
   // _loadReportIds();
  }

  List<Map<String, dynamic>> data=[];
  Future<void> getData() async {
    String closed = "closed";
    print('Attempting to make HTTP request...');
    try {
      final url = Uri.parse("http://localhost/BUDGET/lib/BUDGETAPI/monthlyReport.php?table=monthly_credit&uid=${widget.uid}");
         print(url);
      final response = await http.get(url);
       print("ResponseStatus: ${response.statusCode}");
       print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("ResponseData: $responseData");

        if (responseData.isNotEmpty) { // Check if responseData is not empty
          if (responseData is List) {
            // If responseData is a List (multiple records)
            final List<dynamic> itemGroups = responseData;
            List<dynamic> filteredData = itemGroups.where((item) {
              bool satisfiesFilter = item['status'] == "closed";
              print("Item block status: ${item['status']}");
              print('Satisfies Filter: $satisfiesFilter');
              return satisfiesFilter;
            }).toList();
            setState(() {
              data = filteredData.cast<Map<String, dynamic>>();
            });
            print('Data: $data');
          }
          else if (responseData is Map<String, dynamic>) {
            // If responseData is a Map (single record)
            setState(() {
              data = [responseData];
            });
            print('Data: $data');
          }
        }
        else {
          print('No data found in the response');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      print('HTTP request completed. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error making HTTP request: $e');
      throw e; // rethrow the error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    /*print('Building MonthlyReportPage...');
    print('Data length: ${data.length}');

    if (data == null) {
      print('Data is null. Showing CircularProgressIndicator...');
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isNotEmpty && data[0].containsKey('message')) {
      final message = data[0]['message'] as String;
      print('Message received: $message');
      return Center(child: Text(message)); // Display message to the user
    }

    print('Data is not null. Building ListView.builder...');*/
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Budget Reports",
          style: Theme.of(context).textTheme.titleMedium,
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
        iconTheme:  const IconThemeData(
          color: Colors.white, // Set the color for the drawer icon
        ),
      ),
      body: data.isNotEmpty ? ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          // Parse the date strings to DateTime objects
          final fromDate = DateTime.parse(data[i]['fromDate']);
          final toDate = DateTime.parse(data[i]['toDate']);

          // Format the DateTime objects to "day month year" format
          final dateFormatter = DateFormat('dd-MMMM-yyyy');
          final formattedFromDate = fromDate != null ? DateFormat('dd-MMMM-yyyy').format(fromDate) : '';
          final formattedToDate = toDate != null ? DateFormat('dd-MMMM-yyyy').format(toDate) : '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthReport(
                      uid: data[i]['uid'],
                      incomeId: data[i]['incomeId'],
                      fromDate: formattedFromDate,
                      toDate: formattedToDate
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: GlassContainer(
                height: 100,
                width: double.infinity,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8155BA),
                    Colors.lightBlueAccent
                  ], // Example gradient
                ),
                borderRadius: BorderRadius.circular(20),
                blur: 20,
                borderWidth: 0,
                borderColor: Colors.transparent,
                frostedOpacity: 0.1,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                               '${formattedFromDate ?? ''} - ${formattedToDate ?? ''}',
                                style: Theme.of(context).textTheme.labelMedium),
                            SizedBox(height: 10),
                            /*Text('Total Incomes : ₹${(data[i]['total_income'] ?? 0.0).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall)*/
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ) : const Center(child: Text("No Record Found")) ,
    );
  }

  /*Future<Map<String, dynamic>> _getReportData(String incomeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? totalIncome = prefs.getString('$incomeId:totalincome');
    String? incomeType = prefs.getString('$incomeId:incomeType');
    String? fromDate = prefs.getString('$incomeId:selectedFromDate');
    String? toDate = prefs.getString('$incomeId:selectedToDate');
    String? creditAmt = prefs.getString('$incomeId:creditAmt');
    String? incomeTypeMonth = prefs.getString('$incomeId:incomeTypeMonth');
    List<String>? expensesList = prefs.getStringList('$incomeId:expenses');
    List<String>? spentExpensesList = prefs.getStringList('$incomeId:monthlyexpenses');

    // Fetch additional monthly expenses data
    List<Map<String, String>> formattedExpenses = spentExpensesList?.map((expense) {
      var parts = expense.split(':');
      return {
        'monthcategory': parts[0],
        'monthlyamount': parts[1],
        'date': parts[2],
        'remarks': parts[3]
      };
    }).toList() ?? [];

    // Prepare the data
    Map<String, dynamic> reportData = {
      'totalincome': totalIncome,
      'incomeType': incomeType,
      'selectedFromDate': fromDate,
      'selectedToDate': toDate,
      'creditAmt': creditAmt,
      'incomeTypeMonth': incomeTypeMonth,
      'monthlyExpenses': formattedExpenses, // Add the fetched monthly expenses data
    };

    return reportData;
  }*/

 /* Widget _buildReportCard(Map<String, dynamic> data, BuildContext context) {
    String totalIncomes = data['totalincome'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyReport(reportData: data),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: GlassContainer(
          height: 100,
          width: double.infinity,
          gradient: LinearGradient(
            colors: [
              Color(0xFF8155BA),
              Colors.lightBlueAccent
            ], // Example gradient
          ),
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          borderWidth: 0,
          borderColor: Colors.transparent,
          frostedOpacity: 0.1,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${data['selectedFromDate'] ?? ''} - ${data['selectedToDate']??''}',
                          style: Theme.of(context).textTheme.labelMedium),
                      SizedBox(height: 10),
                      Text('Total Incomes : ₹${double.parse(totalIncomes).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }*/
}

/*
class MonthlyReport extends StatefulWidget {
 // final Map<String, dynamic> reportData;
  final String uid;
  final String incomeId;
  final String fromDate;
  final String toDate;
  MonthlyReport({super.key, required this.uid, required this.incomeId, required  this.fromDate, required this.toDate});

  @override
  State<MonthlyReport> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  List<Map<String, dynamic>> data=[];
  Future<void> getData() async {
    print('Attempting to make HTTP request...');
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthlyReport.php?table=monthly_expenses&uid=${widget.uid}&incomeId=${widget.incomeId}');
      print(url);
      final response = await http.get(url);
      print("ResponseStatus: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("ResponseData: $responseData");
        if (responseData is List) {
          // If responseData is a List (multiple records)
          final List<dynamic> itemGroups = responseData;
          setState(() {
            data = itemGroups.cast<Map<String, dynamic>>();
          });
          print('Data: $data');
        } else if (responseData is Map<String, dynamic>) {
          // If responseData is a Map (single record)
          setState(() {
            data = [responseData];
          });
          print('Data: $data');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      print('HTTP request completed. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error making HTTP request: $e');
      throw e; // rethrow the error if needed
    }
  }
  @override
  void initState() {
    getData();
    super.initState();
    // _loadReportIds();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Column(
              children: [
                Text( 'Monthly Report',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${widget.fromDate ?? ''} - ${widget.toDate??''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Income",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 50,),
                    Text(
                      "Spent",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 50,),
                    Text(
                      "Remaining",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Divider(),
                Text(
                  "Spent",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // Display monthly expenses
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final toDate = DateTime.parse(data[i]['date']);

                    // Format the DateTime objects to "day month year" format
                    final dateFormatter = DateFormat('MMM - dd');
                    final formattedFromDate = dateFormatter.format(toDate);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$formattedFromDate'),
                            Text('${data[i]['category']}'),
                            Text('₹${data[i]['amount']}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('${data[i]['remarks']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Divider(),
                      ],
                    );
                  },
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

class MonthReport extends StatefulWidget {
  final String uid;
  final String incomeId;
  final String fromDate;
  final String toDate;
  const MonthReport({super.key, required this.uid, required this.incomeId, required this.fromDate, required this.toDate});

  @override
  State<MonthReport> createState() => _MonthReportState();
}

class _MonthReportState extends State<MonthReport> {

  /*List<dynamic> monthlyData = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        "http://localhost/BUDGET/lib/BUDGETAPI/getMonthReport.php"));

    if (response.statusCode == 200) {
      print("Com Status: ${response.statusCode}");
      print("Com Body: ${response.body}");
      final responseData = json.decode(response.body);

      if (responseData.containsKey("error")) {
        print(responseData["error"]);
        // Handle the error response here
      } else {
        setState(() {
          monthlyData = responseData;
        });
      }
    } else {
      print('Failed to load data');
    }
  }
*/
  List<Map<String, dynamic>> data=[];
  Future<void> getData() async {
    print('Attempting to make HTTP request...');
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthlyReport.php?table=monthly_expenses&uid=${widget.uid}&incomeId=${widget.incomeId}');
      print(url);
      final response = await http.get(url);
      print("ResponseStatus: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("ResponseData: $responseData");
        if (responseData is List) {
          // If responseData is a List (multiple records)
          final List<dynamic> itemGroups = responseData;
          setState(() {
            data = itemGroups.cast<Map<String, dynamic>>();
          });
          print('Data: $data');
        } else if (responseData is Map<String, dynamic>) {
          // If responseData is a Map (single record)
          setState(() {
            data = [responseData];
          });
          print('Data: $data');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      print('HTTP request completed. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error making HTTP request: $e');
      throw e; // rethrow the error if needed
    }
  }
  List<Map<String, dynamic>> budgetdata=[];
  Future<void> getBudgetData() async {
    print('Attempting to make HTTP request...');
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/getMonthReport.php?uid=${widget.uid}&incomeId=${widget.incomeId}');
      print(url);
      final response = await http.get(url);
      print("ResponseStatus: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("ResponseData: $responseData");
        if (responseData is List) {
          // If responseData is a List (multiple records)
          final List<dynamic> itemGroups = responseData;
          setState(() {
            budgetdata = itemGroups.cast<Map<String, dynamic>>();
          });
          print('Budget Data: $budgetdata');
        } else if (responseData is Map<String, dynamic>) {
          // If responseData is a Map (single record)
          setState(() {
            budgetdata = [responseData];
          });
          print('Budget Data: $budgetdata');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      print('HTTP request completed. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error making HTTP request: $e');
      throw e; // rethrow the error if needed
    }
  }
  List<Map<String, dynamic>> totaldata=[];
  double totalIncomeAmount = 0;
  double totalSpentAmount = 0;
  double totalRemainingAmount = 0;
  Future<void> getTotalData() async {
    print('Attempting to make HTTP request...');
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthlyReport.php?table=total_calculation&uid=${widget.uid}&incomeId=${widget.incomeId}');
      print(url);
      final response = await http.get(url);
      print("ResponseStatus: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final totalIncomeAmt = responseData['totalIncomeAmt'] ?? 0;
        final totalAmount = responseData['totalAmount'] ?? 0;
        final remainingAmount = responseData['remainingAmount'] ?? 0;
        print('Total Income Amount: $totalIncomeAmt');
        print('Total Spent Amount: $totalAmount');
        print('Total Remaining Amount: $remainingAmount');

        setState(() {
        //  budgetdata = responseData['budgetData'];
          // You can store these values in state variables if needed
          totalIncomeAmount = totalIncomeAmt;
          totalSpentAmount = double.parse(totalAmount);
          totalRemainingAmount = remainingAmount;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
      print('HTTP request completed. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error making HTTP request: $e');
      throw e; // rethrow the error if needed
    }
  }
  @override
  void initState() {
    super.initState();
    getData();
    getBudgetData();
    getTotalData();
   // fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // Define a variable to store the total sum
    double totalIncomeAmt = 0;

    // Iterate through each item in the 'data' list and accumulate the incomeAmt values
    if (budgetdata.length > 0) {
      final dataList = budgetdata[0]['data'];
      for (final item in dataList) {
        final incomeAmt = double.tryParse(item['incomeAmt'] ?? '0');
        totalIncomeAmt += incomeAmt!;
      }
    }

    // Define a variable to store the total sum of amounts
    double totalAmount = 0;

// Iterate through each item in the 'data' list and accumulate the amounts
    for (final item in data) {
      final amount = double.tryParse(item['amount'] ?? '0');
      totalAmount += amount!;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Budget Reports",
          style: Theme.of(context).textTheme.titleMedium,
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
        backgroundColor: const Color(0xFF8155BA),
        iconTheme:  const IconThemeData(
          color: Colors.white, // Set the color for the drawer icon
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                    elevation: 10,
                    shadowColor: Colors.deepPurple,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("${widget.fromDate} to ${widget.toDate}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total Income"),
                                  Text("₹$totalIncomeAmount"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total Expenses"),
                                  Text("₹$totalSpentAmount"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Remaining Amount"),
                                  Text("₹$totalRemainingAmount"),
                                ],
                              ),
                              const Divider(),
                              const Divider(),
                              const Row(
                                children: [
                                  Text("Income Type", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: budgetdata.length > 0 ? budgetdata[0]['data'].length : 0,
                                itemBuilder: (context, i) {
                                  final item = budgetdata.length > 0 ? budgetdata[0]['data'][i] : null;
                                  if (item == null) {
                                    return const SizedBox(); // Return an empty container if item is null
                                  }
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item['incomeType'] ?? ""), // Use ?? to provide default value if incomeType is null
                                      Text("₹${item['incomeAmt']}" ?? ""), // Use ?? to provide default value if incomeAmt is null
                                    ],
                                  );
                                },
                              ),


                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width:80,child: Divider()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("₹$totalIncomeAmt")
                                  // Text("₹${spenttotal.toStringAsFixed(2)}"),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width:80,child: Divider()),
                                ],
                              ),
                              const Divider(),
                              const Row(
                                children: [
                                  Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, i) {
                                  final toDate = DateTime.parse(data[i]['date']);

                                  // Format the DateTime objects to "day month year" format
                                  final dateFormatter = DateFormat('dd - MMM');
                                  final formattedFromDate = dateFormatter.format(toDate);
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    //  Text(formattedFromDate != null ? formattedFromDate : ""),
                                       Text(data[i]["date"] !=null ? DateFormat('dd-MMM').format(DateTime.parse(data[i]["date"])) : ""),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data[i]['category'] !=null ? '${data[i]['category']}' : ""),
                                          // Container(child: Text("For Rent")),
                                          /*Text("${spentData[i]["categories"]}"),
                              if (spentData[i]["remark"] != null &&
                                  spentData[i]["remark"].isNotEmpty)
                                Container(child: Text("(${spentData[i]["remark"]})")),*/
                                        ],
                                      ),

                                      Text(data[i]['amount'] !=null ? "₹${data[i]['amount']}" : ""),
                                      // Text("₹${double.tryParse(spentData[i]["amount"])!.toStringAsFixed(2)}"),
                                    ],
                                  );
                                },
                              ),

                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width:80,child: Divider()),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("₹$totalAmount")
                                  // Text("₹${spenttotal.toStringAsFixed(2)}"),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width:80,child: Divider()),
                                ],
                              ),
                              const Divider(),
                            ]
                        )
                    )
                )
            ),
            /*ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                // Parse the date strings to DateTime objects
                final fromDate = DateTime.parse(data[i]['fromDate']);
                final toDate = DateTime.parse(data[i]['toDate']);

                // Format the DateTime objects to "day month year" format
                final dateFormatter = DateFormat('dd-MMMM-yyyy');
                final formattedFromDate = dateFormatter.format(fromDate);
                final formattedToDate = dateFormatter.format(toDate);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyReport(
                            uid: data[i]['uid'],
                            incomeId: data[i]['incomeId'],
                            fromDate: formattedFromDate,
                          toDate: formattedToDate
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: GlassContainer(
                      height: 100,
                      width: double.infinity,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8155BA),
                          Colors.lightBlueAccent
                        ], // Example gradient
                      ),
                      borderRadius: BorderRadius.circular(20),
                      blur: 20,
                      borderWidth: 0,
                      borderColor: Colors.transparent,
                      frostedOpacity: 0.1,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     '$formattedFromDate - $formattedToDate',
                                      style: Theme.of(context).textTheme.labelMedium),
                                  SizedBox(height: 10),
                                  Text('Total Incomes : ₹${(data[i]['total_income'] ?? 0.0).toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodySmall)
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
