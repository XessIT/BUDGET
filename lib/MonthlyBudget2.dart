import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mybudget/monthlyDahboard.dart';
import 'package:mybudget/spent.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'DashBoard.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MonthlyBudget2 extends StatefulWidget {

  final String uid;
  final String incomeId;
  final String fromDate;
  final String toDate;
  final String totalIncomeAmt;

  const MonthlyBudget2({super.key,
    required this.incomeId,
    required this.fromDate,
    required this.toDate,
    required this.totalIncomeAmt,
    required this.uid,

  });


  @override
  State<MonthlyBudget2> createState() => _MonthlyBudget2State();
}

class _MonthlyBudget2State extends State<MonthlyBudget2> {

  final TextEditingController monthlyincome = TextEditingController();
  final TextEditingController income = TextEditingController();
  final TextEditingController monthlyincomeType = TextEditingController();
  final TextEditingController incomeType = TextEditingController();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  List<Map<String, TextEditingController>> monthlyexpenses = [];
  List<Map<String, dynamic>> trips = [];
  List<String> notesList = [];
  double totalMonthlyExpenses = 0;
  String? errormsg = '';

  DateTime _selectedDate = DateTime.now();


  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  double totalspentBudget = 0.0;
  double totalspentbudget2 = 0.0;

  double totalExpenses = 0.0;
  double totalIncome = 0.0;

  void _loadDataForMonthly() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/getMonthlyData.php?incomeId=${widget.incomeId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Income Amount: ${data['incomeAmt']}');
        print('Income Type: ${data['incomeType']}');
        print('From Date: ${data['fromDate']}');
        print('To Date: ${data['toDate']}');
        setState(() {
          monthlyincome.text = data['incomeAmt'] ?? '';
          monthlyincomeType.text = data['incomeType'] ?? '';
          fromDate.text = data['fromDate'] ?? '';
          toDate.text = data['toDate'] ?? '';
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> insertMonthlyData()async {
    try{
      final url=Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/getMonthlyData.php');
      final response = await http.post(
        url,
        body: jsonEncode({
          "incomeId":widget.incomeId,
          "incomeType": incomeType.text,
          "incomeAmt": income.text,
        }),
      );

      if (response.statusCode == 200) {
        print("Trip added successfully!");
        print("Response body: ${response.body}");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    }
    catch (e){
      print("Error during trip addition: $e");
    }
  }



  double _calculateTotalBudget(List monthly) {
    double totalBudgetAmount = 0.0;
    for (var month in monthly) {
      if (month.containsKey('expenses') && month['expenses'] is List) {
        for (var expense in month['expenses']) {
          totalBudgetAmount += (expense['monthlyamount'] ?? 0).toDouble();
        }
      }
    }

    return totalBudgetAmount;
  }
  double totalAmountPerson = 0.00;

  String _updateTotalBudget2() {
    totalAmountPerson = 0.00;
    for (var expense2 in monthlyexpenses) {
      double amount = double.tryParse(expense2['monthlyamount']!.text) ?? 0.0;
      totalAmountPerson += amount;
    }
    return totalAmountPerson.toStringAsFixed(2);
  }

  void updatetotalspent() {
    totalspentBudget = 0.0;
    double totalmonthlyamount = 0.0;
    for (var trip in trips) {
      for (var expense in trip['expenses']) {
        // Convert the string to double before adding to totalmonthlyamount
        totalspentBudget += double.parse(expense['monthlyamount']);
      }
    }
    for (var expense in monthlyexpenses) {
      double amount = double.tryParse(expense['monthlyamount']!.text) ?? 0.0;
      totalspentBudget += amount;
    }
    totalspentbudget2 = totalspentBudget + totalspentBudget;
    //double remainingBudget = double.parse(widget.budget) - totalspentBudget;
    //String remainingBudgetString = remainingBudget.toStringAsFixed(2);
  }
  String formattedFromDate = "";
  void _addmonthcategoryField() {
    setState(() {
      monthlyexpenses.add({
        'date': TextEditingController(text: formattedFromDate), // Add TextEditingController for date
        'monthcategory': TextEditingController(),
        'monthlyamount': TextEditingController(),
        'remarks': TextEditingController(),
      });
      updatetotalspent();
    });
  }



  late DateTime fromdateTime;
  late DateTime todateTime;
  @override
  void initState() {
    super.initState();
    fetchWalletData();
    _addmonthcategoryField();
    updatetotalspent();
    getTotalData();
    // _loadDataFromSharedPreferences();
    // _getTotalIncomeForSelectedMonth();
    _loadDataForMonthly();
    fetchTotalSpent(widget.incomeId);
    futureData = fetchData(widget.uid);
    getData();
    String fromdateString = widget.fromDate;
    fromdateTime = DateFormat('yyyy-MM-dd').parse(fromdateString);
    formattedFromDate = DateFormat('MMM-dd').format(fromdateTime); // Format fromdateTime
    String todateString = widget.toDate;
    todateTime = DateFormat('yyyy-MM-dd').parse(todateString);
  }
  void sendDataToServer(List<dynamic> monthlyExpenses) async {
    final url=Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthly_spent.php');
    // Extract data from TextEditingController objects and create a new list of Map
    List<Map<String, dynamic>> expenseDataList = [];
    for (var expense in monthlyExpenses) {
      Map<String, dynamic> expenseData = {
        'date': expense['date'] is TextEditingController ? expense['date'].text : expense['date'],
        'category': expense['monthcategory'] is TextEditingController ? expense['monthcategory'].text : expense['monthcategory'],
        'amount': expense['monthlyamount'] is TextEditingController ? expense['monthlyamount'].text : expense['monthlyamount'],
        'remarks': expense['remarks'] is TextEditingController ? expense['remarks'].text : expense['remarks'],
        // Include other fields as needed
      };
      expenseDataList.add(expenseData);
    }
    // Print the original monthlyExpenses list
    print('Original Monthly Expenses:');
    print(monthlyExpenses);
    // Print the extracted data
    print('Extracted Data:');
    for (var expenseData in expenseDataList) {
      print('Date: ${expenseData['date']}');
      print('Category: ${expenseData['category']}');
      print('Amount: ${expenseData['amount']}');
      print('---');
    }
    print("url $url");
    print("monthly income $monthlyincome");
    // Make POST request
    // Convert data to JSON string
    String jsonData = jsonEncode({
      'monthlyexpenses': expenseDataList,
      'fromDate': widget.fromDate,
      'toDate': widget.toDate,
      'uid': widget.uid,
      'incomeId': widget.incomeId,
      'totalIncomeAmt': monthlyincome.text,
    });
    final response = await http.post(
      url,
      body: jsonData,
      headers: {
        'Content-Type': 'application/json', // Specify the content type as JSON
      },
    );

    // Check if request was successful
    if (response.statusCode == 200) {
      print("Response Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      print('Data sent successfully!');
    } else {
      print('Failed to send data. Error: ${response.statusCode}');
    }
  }
  String totalSpent = ''; // State variable to hold the total spent amount
  String remaining = ''; // State variable to hold the remaining amount
  double amountToDeduct = 0;
  TextEditingController dateRangeController = TextEditingController(); // Add controller for TypeAheadFormField
  void fetchTotalSpent(String incomeId) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthly_spent.php?table=monthly_expenses&incomeId=$incomeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double monthlyIncomeAmount = double.parse(monthlyincome.text);
      double totalSpentAmount = double.parse(data['totalSpent']);
      double remainingAmount = monthlyIncomeAmount - totalSpentAmount;

      setState(() {
        totalSpent = totalSpentAmount.toStringAsFixed(2);
        remaining = remainingAmount.toStringAsFixed(2);
      });
    } else {
      print('Failed to fetch total spent. Error: ${response.statusCode}');
    }
  }
  late Future<List<Map<String, dynamic>>> futureData;
  TextEditingController monthRemainingController = TextEditingController();
  TextEditingController amountToAddController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchData(String uid) async {
    final url =
    Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthEndBalance.php?uid=$uid');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Map<String, dynamic>> data =
      jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
  double walletAmount = 0;
  Future<void> fetchWalletData() async {
    final url =
    Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/personal_savings.php?table=wallet&uid=${widget.uid}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print(url);
      print('uid : $widget.uid');

      // Parse the JSON response as a map directly
      var responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('totalWalletAmount')) {
        // Access the value directly without treating it as a string
        walletAmount = (responseBody['totalWalletAmount'] as num).toDouble();
        print('Total Wallet Amount: $walletAmount');
      } else {
        print('Total wallet amount not found in the response');
      }
    } else {
      print('Failed to fetch records: ${response.body}');
    }
  }

  Future<void> updateMonthRemaining(String uid, String fromDate, String toDate, String newMonthRemaining, String enteredAmount) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthEndBalance.php');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uid': uid,
        'fromDate': fromDate,
        'toDate': toDate,
        'monthRemaining': newMonthRemaining,
        'enteredAmount': enteredAmount,
      }),
    );
    if (response.statusCode == 200) {
      // Handle successful update
      print('Month Remaining and enteredAmount updated successfully');
    } else {
      // Handle failed update
      throw Exception('Failed to update monthRemaining and enteredAmount');
    }
  }

  List<Map<String, dynamic>> spent_data=[];
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
            spent_data = itemGroups.cast<Map<String, dynamic>>();
          });
          print('Data: $spent_data');
        } else if (responseData is Map<String, dynamic>) {
          // If responseData is a Map (single record)
          setState(() {
            spent_data = [responseData];
          });
          print('Data: $spent_data');
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
  TextEditingController editdate = TextEditingController();
  TextEditingController editcategory = TextEditingController();
  TextEditingController editamount = TextEditingController();
  TextEditingController editremarks = TextEditingController();
  TextEditingController walletamountcontroller = TextEditingController();
  Future<void> delete(String id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthly_spent.php?id=$id');
      final response = await http.delete(url);
      print("Delete Url: $url");
      if (response.statusCode == 200) {
        // Success handling, e.g., show a success message
        // Navigator.pop(context);
      }
      else {
        // Error handling, e.g., show an error message
        print('Error: ${response.statusCode}');
      }
    }
    catch (e) {
      // Handle network or server errors
      print('Error making HTTP request: $e');
    }
  }

  Future<void> editExpense(int id) async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthly_spent.php');
      print(url);
      final response = await http.put(
        url,
        body: jsonEncode({
          "date": editdate.text,
          "category": editcategory.text,
          "amount": editamount.text,
          "remarks": editremarks.text,
          "id": id,
        }),
      );
      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMemberApproval()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Edited")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Edit")));
      }
    } catch (e) {
      print("Error during signup: $e");
      // Handle error as needed
    }
  }
  bool notesVisible = false;
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
  Future<void> walletAmountToIncome() async {
    try {
      final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/MonthlyDashBoard.php?table=add_wallet_amount');
      print(url);
      final response = await http.put(
        url,
        body: jsonEncode({
          "incomeAmt": amountToDeduct,
          "incomeId": widget.incomeId,
        }),
      );
      if (response.statusCode == 200) {
        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMemberApproval()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Added Amount from Wallet")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to Edit")));
      }
    } catch (e) {
      print("Error during signup: $e");
      // Handle error as needed
    }
  }
  Future<void> deductAmountFromWallet() async {
    try {
      var url = 'http://localhost/BUDGET/lib/BUDGETAPI/personal_savings.php?table=savings_credit';
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "uid": widget.uid,
          "incomeId": widget.incomeId,
          "amount": amountToDeduct,
        }),
      );
      if (response.statusCode == 200) {
        walletAmountToIncome();
        // loadDataAndCalculateExpenses();
        print("Response Status: $response.statusCode");
        print("Response Body: $response.body");
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  MonthlyBudget2(uid: widget.uid, incomeId: widget.incomeId, fromDate: widget.fromDate, toDate: widget.toDate, totalIncomeAmt: widget.totalIncomeAmt,)));
      } else {
        print('Failed to update wallet amount: ${response.body}');
      }
    } catch (e) {
      print('Error updating wallet amount: $e');
    }
  }
  @override
  Widget build(BuildContext context) {


    double totalBudgetAmount = _calculateTotalBudget(trips);
    double remainingOrDebit = (double.tryParse(monthlyincome.text.toString()) ?? 0.0) - totalBudgetAmount;

    ///totalremaining
    double total = (totalAmountPerson - remainingOrDebit.abs()).abs();
    List<Widget> monthlyAmounts = [];
    for (var i = 0; i < trips.length; i++) {
      for (var j = 0; j < trips[i]['expenses'].length; j++) {
        monthlyAmounts.add(
          Text(
            'Amount : ₹ ${trips[i]['expenses'][j]['monthlyamount']}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }
    Map<String, double> aggregatedData = {};

    for (var i = 0; i < trips.length; i++) {
      for (var j = 0; j < trips[i]['expenses'].length; j++) {
        String category = trips[i]['expenses'][j]['monthcategory'];
        double amount = double.parse(trips[i]['expenses'][j]['monthlyamount'].toString());
        // Ensure that the aggregatedData map contains the category
        aggregatedData[category] = (aggregatedData[category] ?? 0) + amount;
      }
    }

    List<SalesData> chartData = [];
    aggregatedData.forEach((category, amount) {
      chartData.add(SalesData(category, amount));
    });
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Column(
            children: [
              Text(
                "Monthly Budget",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                "${DateFormat('MMM-dd').format(fromdateTime)} to ${DateFormat('MMM-dd').format(todateTime)}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  MonthlyDashboard(uid: '',)));
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // User must tap button to close the dialog
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Wallet Amount'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'Your current wallet amount is: ${walletAmount.toString()}'), // Display wallet amount in the alert dialog
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
                ); // You can pass '0' as a placeholder for wallet amount
              },
              icon: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
              ),
            ),
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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              /*  Text(
                '${remainingOrDebit.abs()}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              Text(
                'Total: ₹${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),*/


              /* Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      List<Map<String, dynamic>> data = await futureData;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Center(child: Text('Personal Saving',style: TextStyle(fontSize: 16,fontStyle: FontStyle.italic, color: Colors.green),)),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                // Date and Balance Table
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10), // Set border radius to 20
                                  ),// Set your desired height here
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Table(
                                      //  border: TableBorder.all(),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(1),
                                      },
                                      children: [
                                        const TableRow(
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text(
                                                    'Budget Date',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Balance',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Data Rows
                                        for (var item in data)
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${item['fromDate']} - ${item['toDate']}',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${item['monthRemaining']}',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                // TypeAheadFormField for selecting Date Range
                                TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                      controller: dateRangeController, // Assign controller
                                      decoration: InputDecoration(labelText: 'Select Date Range',labelStyle: TextStyle(fontSize: 14)),
                                      style: TextStyle(fontSize: 14)
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    // You can implement suggestion logic here
                                    List<String> suggestions = [];
                                    for (var item in data) {
                                      suggestions.add('${item['fromDate']} - ${item['toDate']}');
                                    }
                                    return suggestions;
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.toString()),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    // Fetch monthRemaining based on selected suggestion and update TextFormField
                                    for (var item in data) {
                                      if ('${item['fromDate']} - ${item['toDate']}' == suggestion.toString()) {
                                        monthRemainingController.text = '${item['monthRemaining']}';
                                        dateRangeController.text = suggestion.toString(); // Update TypeAheadFormField text
                                        break;
                                      }
                                    }
                                  },
                                ),
                                TextFormField(
                                  controller: amountToAddController,
                                  decoration: InputDecoration(labelText: 'Add Amount', labelStyle: TextStyle(fontSize: 14)),
                                  style: TextStyle(fontSize: 14),
                                  //readOnly: true,
                                ),
                                SizedBox(height: 10),



                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Set your desired color here
                                  minimumSize: MaterialStateProperty.all<Size>(Size(70, 30)), // Set your desired size here
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(8)), // Adjust padding as needed
                                ),
                                child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  final String fromDate = dateRangeController.text.split(' - ')[0];
                                  final String toDate = dateRangeController.text.split(' - ')[1];
                                  final int enteredAmount = int.parse(amountToAddController.text);
                                  final int availableBalance = int.parse(monthRemainingController.text);
                                  final String newMonthRemaining = (availableBalance - enteredAmount).toString();

                                  // Update monthRemaining and enteredAmount
                                  updateMonthRemaining(
                                    widget.uid,
                                    fromDate,
                                    toDate,
                                    newMonthRemaining,
                                    enteredAmount.toString(), // Convert enteredAmount to String
                                  );

                                  // Navigate to MonthlyBudget2 screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MonthlyBudget2(
                                        incomeId: widget.incomeId,
                                        fromDate: widget.fromDate,
                                        toDate: widget.toDate,
                                        totalIncomeAmt: widget.totalIncomeAmt,
                                        uid: widget.uid,
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Set your desired color here
                                  minimumSize: MaterialStateProperty.all<Size>(Size(70, 30)), // Set your desired size here
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(8)), // Adjust padding as needed
                                ),
                                child: Text('Add',style: TextStyle(color: Colors.white),),
                              ),
                              const SizedBox(width: 10),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Get Remaining"),
                  ),
                  *//*RichText(
                    text: TextSpan(
                      children: [

                        TextSpan(
                          text: '${fromDate.text} / ${toDate.text}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),*//*
                ],

              ), */ ///  Text Field
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (totalRemainingAmount <= 0)
                    TextButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.infoReverse,
                          title: 'Get Amount',
                          desc:
                          'Do you want to Get Amount from Wallet?',
                          btnOkText: 'Yes',
                          btnCancelText: 'No',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            // Show the text field when user clicks "Yes"
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Enter Amount'),
                                content: TextField(
                                  controller: walletamountcontroller,
                                  keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                      decimal: true),
                                  decoration:
                                  const InputDecoration(
                                    labelText: 'Enter Amount',
                                    hintText:
                                    'Enter the amount here',
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                       amountToDeduct =
                                          double.tryParse(
                                              walletamountcontroller
                                                  .text) ??
                                              0.0;
                                      if (amountToDeduct <= walletAmount) {
                                         deductAmountFromWallet();
                                        /*if (success) {
                                          setState(() {
                                            walletAmount -= amountToDeduct;
                                          });
                                          Navigator.of(context).pop(); // Close dialog
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Amount deducted successfully')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to deduct amount')),
                                          );
                                        }*/
                                      } else {
                                        ScaffoldMessenger.of(
                                            context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Insufficient wallet balance')),
                                        );
                                      }
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            // Perform actions when OK is pressed
                          },
                        ).show();
                      },
                      child: Text("Get Amount ",
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                ],
              ),

              SizedBox(height: 10,),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  //width: 320,
                  // padding: EdgeInsets.all(10.0),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Set border radius to 20
                  ),
                  child: Column(
                    children: [

                      /// receivedamnt

                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(SimpleIcons.bitcomet, color: Colors.white),
                              backgroundColor: Colors.blue, // Set the background color of the circle avatar
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(

                                mainAxisAlignment: MainAxisAlignment.start, // Align the text widgets in the center
                                children: [

                                  Text('Income',style: Theme.of(context).textTheme.labelMedium),
                                  SizedBox(width: 70,),
                                  Text('₹${monthlyincome.text}.00' ,style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  IconButton(onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: Text("Add Your Credit", style: Theme.of(context).textTheme.bodyLarge),
                                              insetPadding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.deepPurple),
                                              ),
                                              shadowColor: Colors.deepPurple,
                                              content: SizedBox(
                                                height: 100,
                                                width: 250,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 40,
                                                      width: 250,
                                                      child: TextFormField(
                                                        controller: incomeType,
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: 'Income Type',
                                                          labelStyle: Theme.of(context).textTheme.bodySmall,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                          /* border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),*/
                                                        ),
                                                      ),
                                                    ), ///Income Type
                                                    SizedBox(height: 15),
                                                    SizedBox(
                                                      height: 40,
                                                      width: 250,
                                                      child: TextFormField(
                                                        controller: income,
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: 'Income Amount',
                                                          labelStyle: Theme.of(context).textTheme.bodySmall,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                          /*border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),*/
                                                        ),
                                                      ),
                                                    ), /// Income Amount
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    //_saveDataToSharedPreferencesCredit();
                                                    fetchTotalSpent(widget.incomeId);
                                                    insertMonthlyData();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) =>  MonthlyBudget2(
                                                        incomeId: widget.incomeId,
                                                        fromDate: widget.fromDate,
                                                        toDate: widget.toDate,
                                                        totalIncomeAmt:widget.totalIncomeAmt,
                                                        uid: widget.uid,
                                                      )),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal), // Set your desired color here
                                                  ),

                                                  child: const Text("Ok",style: TextStyle(color: Colors.white),),
                                                ),
                                              ],
                                              backgroundColor: Colors.teal.shade50,

                                            );
                                          },
                                        );
                                      },
                                    );
                                  }, icon: Icon(Icons.add_circle_rounded,color: Colors.green,))

                                ],
                              ),
                              SizedBox(height: 2), // Add space between the row and the text widgets
                              Container(
                                width: 200, // Set the desired width
                                child: LinearProgressIndicator(
                                  value: monthlyincome != 0 ? 1.0 : 0.0,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              )
                            ],
                          ),// Adjust the space between the icon and progress bar
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(SimpleIcons.affine, color: Colors.white),
                              /*backgroundColor: totalBudgetAmount > double.parse(monthlyincome.text)
                                  ? Colors.red // Orange color when spent exceeds received amount
                                  : Colors.teal,*/
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Expense', style: Theme.of(context).textTheme.labelMedium),
                                  SizedBox(width: 70),
                                  Text('₹${totalSpent.isNotEmpty ? totalSpent : '0.00'}', style: Theme.of(context).textTheme.labelMedium),
                                ],
                              ),
                              SizedBox(height: 2), // Add space between the row and the text widgets
                              Container(
                                width: 200, // Set the desired width
                                child: LinearProgressIndicator(
                                  value: totalSpent.isNotEmpty
                                      ? double.parse(totalSpent) / double.parse(monthlyincome.text) // Calculate progress ratio if totalSpent is not empty
                                      : 0.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    totalSpent.isNotEmpty && double.parse(totalSpent) > double.parse(monthlyincome.text)
                                        ? Colors.red // Red color for spent exceeding income
                                        : Colors.teal, // Teal color for remaining budget or default color if totalSpent is empty
                                  ),
                                ),
                              )
                            ],
                          ),// Adjust the space between the icon and progress bar
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(SimpleIcons.affine, color: Colors.white),
                              /*backgroundColor: totalBudgetAmount > double.parse(monthlyincome.text)
                                  ? Colors.red // Orange color when spent exceeds received amount
                                  : Colors.teal,*/
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Remaining', style: Theme.of(context).textTheme.labelMedium),
                                  SizedBox(width: 70),
                                  Text('₹${remaining.isNotEmpty ? remaining : '0.00'}', style: Theme.of(context).textTheme.labelMedium),
                                ],
                              ),
                              SizedBox(height: 2), // Add space between the row and the text widgets
                              Container(
                                width: 200, // Set the desired width
                                child: LinearProgressIndicator(
                                  value: remaining.isNotEmpty
                                      ? double.parse(remaining) / double.parse(monthlyincome.text) // Calculate progress ratio if totalSpent is not empty
                                      : 0.0, // Default value if totalSpent is empty
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    remaining.isNotEmpty && double.parse(remaining) > double.parse(monthlyincome.text)
                                        ? Colors.red // Red color for spent exceeding income
                                        : Colors.teal, // Teal color for remaining budget or default color if totalSpent is empty
                                  ),
                                ),
                              )
                            ],
                          ),// Adjust the space between the icon and progress bar
                        ],
                      ),




                    ],
                  ),
                ),
              ),

              SizedBox(height: 10,),


              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  //  width: 350,
                  // padding: EdgeInsets.all(10.0),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,

                  ),
                  child: ExpansionTile(
                    title: Text('Chart',
                      style: TextStyle(
                        fontSize: 18, // Increase font size for the title
                        fontWeight: FontWeight.bold, // Add bold font weight
                        //   color: Colors.blue, // Change text color
                      ),),
                    backgroundColor: Colors.white70,// Title of the ExpansionTile
                    children: [
                      Container(
                        height: 200,
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10), // Set border radius to 20
                        ),
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: double.tryParse(monthlyincome.text.toString()),
                            interval: (double.tryParse(monthlyincome.text.toString()) ?? 0.0) / 4,
                            numberFormat: NumberFormat.compact(),
                          ),
                          series: <CartesianSeries>[
                            /*BarSeries<SalesData, String>(
                              dataSource: chartData,
                              xValueMapper: (SalesData sales, _) => sales.category,
                              yValueMapper: (SalesData sales, _) => sales.amount,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.inside, // Adjust label position
                              ),
                              // Assigning colors directly to each data point
                              pointColorMapper: (SalesData sales, _) => _getColorForCategory(sales.category),
                              width: 0.1,
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ), /// Chart
              totalRemainingAmount > 0 ?
              Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
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
                        ),  /// Error message
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                              boxShadow: [],
                              gradient: const LinearGradient(
                                // Gradient background
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.white70, Colors.white70],
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 0; i < monthlyexpenses.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField
                                              (
                                              readOnly: true,
                                              controller: monthlyexpenses[i][
                                              'date']!, // Assuming expense['date'] is already a TextEditingController
                                              /*style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),*/
                                              onTap: () async {
                                                // Show date picker when the field is tapped
                                                DateTime? pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: fromdateTime,
                                                  firstDate: fromdateTime,
                                                  lastDate: DateTime.now().isBefore(todateTime) ? DateTime.now() : todateTime,
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
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    monthlyexpenses[i]['date']!.text =
                                                        _formatDate(pickedDate);
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: monthlyexpenses[i]['date']!.text.isEmpty
                                                    ? 'Date'
                                                    : null,
                                                hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                            TypeAheadFormField<String>(
                                              textFieldConfiguration: TextFieldConfiguration(
                                                controller: monthlyexpenses[i]['monthcategory']!,
                                                onChanged: (value) {
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: monthlyexpenses[i]['monthcategory']!.text.isEmpty
                                                      ? 'Categories'
                                                      : null,
                                                  hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
                                                ),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              suggestionsCallback: (pattern) {
                                                // List of suggestions
                                                List<String> suggestions = [
                                                  // Headings
                                                  'Daily Expenses',
                                                  'Housing',
                                                  'Transportation',
                                                  'Food',
                                                  'Debt Payments',
                                                  'Insurance',
                                                  'Savings',
                                                  'Personal Expenses',
                                                  'Utilities',
                                                  'Healthcare',
                                                  'Education',
                                                  'Charity/Donations',
                                                  'Miscellaneous',
                                                  // Categories
                                                  'Rent/Mortgage',
                                                  'Utilities',
                                                  'Groceries',
                                                  'Credit Card Payments',
                                                  'Health Insurance',
                                                  'Emergency Fund',
                                                  'Clothing',
                                                  'Electricity',
                                                  'Doctor Visits',
                                                  'Tuition',
                                                  'Regular Donations',
                                                  'Other Expenses',
                                                ];
                                                return suggestions;
                                              },
                                              itemBuilder: (context, String suggestion) {
                                                if (
                                                suggestion == 'Daily Expenses' ||
                                                    suggestion == 'Housing' ||
                                                    suggestion == 'Transportation' ||
                                                    suggestion == 'Food' ||
                                                    suggestion == 'Debt Payments' ||
                                                    suggestion == 'Insurance' ||
                                                    suggestion == 'Savings' ||
                                                    suggestion == 'Personal Expenses' ||
                                                    suggestion == 'Utilities' ||
                                                    suggestion == 'Healthcare' ||
                                                    suggestion == 'Education' ||
                                                    suggestion == 'Charity/Donations' ||
                                                    suggestion == 'Miscellaneous') {
                                                  // If it's a heading, display it differently
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  );
                                                } else {
                                                  // If it's a category, display it normally
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  );
                                                }
                                              },
                                              onSuggestionSelected: (String suggestion) {
                                                monthlyexpenses[i]['monthcategory']!.text = suggestion;
                                                monthlyexpenses[i]['monthcategory']!.selection =
                                                    TextSelection.collapsed(offset: suggestion.length);
                                                monthlyexpenses[i]['monthcategory']!.value = TextEditingValue(
                                                  text: suggestion,
                                                  selection: TextSelection.collapsed(offset: suggestion.length),
                                                );
                                              },
                                            ),
                                          ),

                                          /// Cargories

                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: monthlyexpenses[i]
                                              ['monthlyamount'],
                                              style: const TextStyle(fontSize: 14),
                                              onChanged: (value) {
                                                setState(() {
                                                  //updatetotalspent();
                                                  notesVisible = true;
                                                  // _addmonthcategoryField();
                                                  _updateTotalBudget2();
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: monthlyexpenses[i]
                                                ['monthlyamount']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Rs'
                                                    : null,
                                                hintStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(7),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              controller:
                                              monthlyexpenses[i]
                                              ['remarks'],
                                              onChanged: (value) {
                                                setState(() {
                                                  setState(() {
                                                    errormsg = null;
                                                  });
                                                });
                                              },
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors
                                                      .black), // Change input text size and color
                                              decoration:
                                              InputDecoration(
                                                hintText: monthlyexpenses[i]
                                                ['remarks']!
                                                    .text
                                                    .isEmpty
                                                    ? 'Remarks'
                                                    : null,
                                                hintStyle: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),// Change label text size and color
                                              ),
                                            ),
                                          ),

                                          ///remarks
                                          if (i != 0)
                                            IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors
                                                      .red), // You can change the icon here
                                              onPressed: i == 0 ? null : (){
                                                setState(() {
                                                  monthlyexpenses.removeAt(i);
                                                  //updatetotalspent(); // _updateTotalBudget();
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
                        ), /// date catgories amount
                      ],
                    ), /// date catgories amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Add .00 to the entered amount for each expense
                              for (var i = 0; i < monthlyexpenses.length; i++) {
                                var currentAmount =
                                    monthlyexpenses[i]['monthlyamount']!.text;
                                if (!currentAmount.contains('.')) {
                                  monthlyexpenses[i]['monthlyamount']!.text =
                                  '$currentAmount.00';
                                }
                              }
                            });
                            _addmonthcategoryField();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8155BA)
                                .withOpacity(0.8), // Change button color here
                            elevation: 5, // Add elevation
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 20),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              List<String?> errorMessages = List.filled(
                                  monthlyexpenses.length,
                                  ''); // List to store error messages for each row
                              bool isValid =
                              true; // Flag to track overall form validity
                              for (var i = 0; i < monthlyexpenses.length; i++) {
                                double monthlyAmount = double.tryParse(monthlyexpenses[i]['monthlyamount']!.text) ?? 0.0;
                                totalMonthlyExpenses += monthlyAmount;
                                print("TotalMonthlyExpenses: $totalMonthlyExpenses");
                                if (monthlyexpenses[i]['monthcategory']!
                                    .text
                                    .isEmpty) {
                                  errorMessages[i] = "* Enter a Category Name";
                                  isValid =
                                  false; // Set flag to false if any row has an error
                                } else if (monthlyexpenses[i]['monthlyamount']!
                                    .text
                                    .isEmpty) {
                                  errorMessages[i] = "* Enter an Amount";
                                  isValid =
                                  false; // Set flag to false if any row has an error
                                } else if (monthlyexpenses[i]['remarks']!
                                    .text
                                    .isEmpty) {
                                  errorMessages[i] = "* Enter a Remarks";
                                  isValid =
                                  false;
                                } else {
                                  // No error for this row
                                  errorMessages[i] = null;
                                }
                              }
                              // Check overall form validity
                              if (isValid) {
                                if(totalMonthlyExpenses<=totalRemainingAmount) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Saved Succesfully'),
                                        content: Text(
                                            ''),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              sendDataToServer(monthlyexpenses);
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=> MonthlyBudget2(
                                                incomeId: widget.incomeId,
                                                fromDate: widget.fromDate,
                                                toDate: widget.toDate,
                                                totalIncomeAmt: widget.totalIncomeAmt,
                                                uid: widget.uid,
                                                // totalIncome: widget.totalIncome,
                                                // incomeType: widget.incomeType,
                                                // selectedFromDate: widget.selectedFromDate,
                                                // selectedToDate: widget.selectedToDate,

                                              )));
                                              //  _saveDataToSharedPreferences(remainingOrDebit);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green
                                                  .withOpacity(
                                                  0.8), // Change button color here
                                              elevation: 5, // Add elevation
                                            ),
                                            child: Text('OK',
                                                style:
                                                TextStyle(color: Colors.black)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                else{
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.infoReverse,
                                    title: 'Get Amount',
                                    desc:
                                    'Do you want to Get Amount from Wallet?',
                                    btnOkText: 'Yes',
                                    btnCancelText: 'No',
                                    btnCancelOnPress: () {
                                      for (var i = 0; i < monthlyexpenses.length; i++) {
                                        TextEditingController? controller = monthlyexpenses[i]['monthlyamount'];
                                        if (controller != null) {
                                          controller.clear();
                                        }
                                      }
                                      setState((){
                                        totalMonthlyExpenses = 0;
                                      });
                                     // Navigator.of(context).pop();
                                    },
                                    btnOkOnPress: () {
                                      // Show the text field when user clicks "Yes"
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Enter Amount'),
                                          content: TextField(
                                            controller: walletamountcontroller,
                                            keyboardType:
                                            const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            decoration:
                                            const InputDecoration(
                                              labelText: 'Enter Amount',
                                              hintText:
                                              'Enter the amount here',
                                              border:
                                              OutlineInputBorder(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                amountToDeduct =
                                                    double.tryParse(
                                                        walletamountcontroller
                                                            .text) ??
                                                        0.0;
                                                if (amountToDeduct <= walletAmount) {
                                                  deductAmountFromWallet();
                                                  /*if (success) {
                                          setState(() {
                                            walletAmount -= amountToDeduct;
                                          });
                                          Navigator.of(context).pop(); // Close dialog
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Amount deducted successfully')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to deduct amount')),
                                          );
                                        }*/
                                                } else {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Insufficient wallet balance')),
                                                  );
                                                }
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                      // Perform actions when OK is pressed
                                    },
                                  ).show();
                                  /*showDialog(
                                      context: context,
                                      builder: (BuildContext context)
                                      {
                                        return AlertDialog(
                                          title: Text('Insufficient Balance'),
                                          // content: Text('You have insufficient balance in your wallet.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                      for (var i = 0; i < monthlyexpenses.length; i++) {
                                        TextEditingController? controller = monthlyexpenses[i]['monthlyamount'];
                                        if (controller != null) {
                                          controller.clear();
                                        }
                                      }
                                      setState((){
                                        totalMonthlyExpenses = 0;
                                      });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      }
                                  );*/
                                }
                              }
                              else {
                                // Set error messages for each row
                                StringBuffer errorMessageBuffer =
                                StringBuffer(); // Use StringBuffer to concatenate error messages
                                for (var i = 0; i < monthlyexpenses.length; i++) {
                                  if (errorMessages[i] != null) {
                                    errorMessageBuffer.writeln(errorMessages[
                                    i]); // Append error message for each row
                                  }
                                }
                                setState(() {
                                  errormsg = errorMessageBuffer
                                      .toString(); // Set error message
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8155BA)
                                  .withOpacity(0.8), // Change button color here
                              elevation: 5, // Add elevation
                            ),
                            child: Text('SAVE',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ) : Text("NO BALANCE", style: TextStyle(fontSize: 20, color: Colors.red)),

              /*Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    for (var i = 0; i < trips.length; i++)
                      for (var j = 0; j < trips[i]['expenses'].length; j++)
                        Container(
                          width: 350,
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Color(0xFF8155BA),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          alignment: (i + j) % 2 == 0
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Category: ${trips[i]['expenses'][j]['monthcategory']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${trips[i]['expenses'][j]['date']}',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Text(
                                    'Amount  : ₹ ${trips[i]['expenses'][j]['monthlyamount']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_forever, color: Colors.red),
                                    onPressed: () {
                                      _deleteExpense(i, j);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              if (trips[i]['expenses'][j]['remarks'].isNotEmpty)
                                Text(
                                  'Remarks :  ${trips[i]['expenses'][j]['remarks']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                    // Display the total spent amount after iterating through all expenses
                  ],
                ),
              ),*/
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth:const FixedColumnWidth(90.0),
                      columnWidths: const <int, TableColumnWidth>{
                        0:FixedColumnWidth(50),
                        1:FixedColumnWidth(100),
                        2:FixedColumnWidth(70),
                        4:FixedColumnWidth(50),
                        5:FixedColumnWidth(50),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      // s.no
                      children: [const TableRow(children:[
                        TableCell(child:  Center(child: Text('Date', style: TextStyle(fontSize: 16, color: Colors.black)),),),
                        //Name
                        TableCell(child:Center(child: Text('Category',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                        // company name

                        TableCell(child:Center(child: Text('Amount',style: TextStyle(fontSize: 16, color: Colors.black)),)),

                        TableCell(child:Center(child: Text('Remarks',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                        //Email
                        TableCell(child: Center(child: Text('Edit', style: TextStyle(fontSize: 16, color: Colors.black)),)),

                        TableCell(child:Center(child: Text('Delete', style: TextStyle(fontSize: 16, color: Colors.black)),)),
                        // Chapter
                      ]),

                        for(var i = 0 ;i < spent_data.length; i++) ...[
                          // if (i != 0) ...[
                          TableRow(
                              decoration: BoxDecoration(color: Colors.grey[200]),
                              children:[
                                // 1 Table row contents
                                TableCell(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 8,),
                                        Text(spent_data[i]['date'] != null
                                            ? DateFormat('MMM-dd').format(DateTime.parse(spent_data[i]['date']))
                                            : ' '),
                                        const SizedBox(height: 8,),
                                      ],
                                    ),
                                  ),
                                ),

                                //2 name
                                TableCell(child: Center(child: Text('${spent_data[i]["category"] ?? ''}',),)),
                                // 3 company name
                                TableCell(child:Center(child: Text('${spent_data[i]["amount"]?? ''}',),)),
                                // 4 email
                                TableCell(child:Center(child: Text('${spent_data[i]["remarks"]?? ''}',),)),
                                // 5 chapter
                                TableCell(child:Center(
                                    child: spent_data[i]['date'] != null ?
                                    IconButton(
                                        onPressed: (){
                                          showDialog<void>(
                                            context: context,
                                            builder: (BuildContext dialogContext) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text('Edit',),
                                                content:  SizedBox(width: 400,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField
                                                          (
                                                          readOnly: true,
                                                          controller: editdate = TextEditingController(text: DateFormat('MMM-dd').format(DateTime.parse(spent_data[i]['date']))), // Assuming expense['date'] is already a TextEditingController
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold),
                                                          onTap: () async {
                                                            // Show date picker when the field is tapped
                                                            DateTime? pickedDate =
                                                            await showDatePicker(
                                                              context: context,
                                                              initialDate: fromdateTime,
                                                              firstDate: fromdateTime,
                                                              lastDate: todateTime,
                                                              builder: (BuildContext context,
                                                                  Widget? child) {
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
                                                            if (pickedDate != null) {
                                                              setState(() {
                                                                editdate.text =
                                                                    _formatDate(pickedDate);
                                                              });
                                                            }
                                                          },
                                                          decoration: const InputDecoration(
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        flex: 2,
                                                        child:
                                                        TypeAheadFormField<String>(
                                                          textFieldConfiguration: TextFieldConfiguration(
                                                            controller: editcategory = TextEditingController(text: spent_data[i]['category']),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                errormsg = null;
                                                              });
                                                            },
                                                            /*decoration: InputDecoration(
                                                              hintText: monthlyexpenses.isNotEmpty && i < monthlyexpenses.length
                                                                  ? monthlyexpenses[i]['monthcategory']!.text.isEmpty
                                                                  ? 'Categories'
                                                                  : null
                                                                  : null,
                                                              hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
                                                            ),*/
                                                            style: TextStyle(fontSize: 16),
                                                          ),
                                                          suggestionsCallback: (pattern) {
                                                            // List of suggestions
                                                            List<String> suggestions = [
                                                              // Headings
                                                              'Daily Expenses',
                                                              'Housing',
                                                              'Transportation',
                                                              'Food',
                                                              'Debt Payments',
                                                              'Insurance',
                                                              'Savings',
                                                              'Personal Expenses',
                                                              'Utilities',
                                                              'Healthcare',
                                                              'Education',
                                                              'Charity/Donations',
                                                              'Miscellaneous',
                                                              // Categories
                                                              'Rent/Mortgage',
                                                              'Utilities',
                                                              'Groceries',
                                                              'Credit Card Payments',
                                                              'Health Insurance',
                                                              'Emergency Fund',
                                                              'Clothing',
                                                              'Electricity',
                                                              'Doctor Visits',
                                                              'Tuition',
                                                              'Regular Donations',
                                                              'Other Expenses',
                                                            ];
                                                            return suggestions;
                                                          },
                                                          itemBuilder: (context, String suggestion) {
                                                            if (
                                                            suggestion == 'Daily Expenses' ||
                                                                suggestion == 'Housing' ||
                                                                suggestion == 'Transportation' ||
                                                                suggestion == 'Food' ||
                                                                suggestion == 'Debt Payments' ||
                                                                suggestion == 'Insurance' ||
                                                                suggestion == 'Savings' ||
                                                                suggestion == 'Personal Expenses' ||
                                                                suggestion == 'Utilities' ||
                                                                suggestion == 'Healthcare' ||
                                                                suggestion == 'Education' ||
                                                                suggestion == 'Charity/Donations' ||
                                                                suggestion == 'Miscellaneous') {
                                                              // If it's a heading, display it differently
                                                              return ListTile(
                                                                title: Text(
                                                                  suggestion,
                                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                ),
                                                              );
                                                            } else {
                                                              // If it's a category, display it normally
                                                              return ListTile(
                                                                title: Text(
                                                                  suggestion,
                                                                  style: TextStyle(fontSize: 14),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          onSuggestionSelected: (String suggestion) {
                                                            editcategory.text = suggestion;
                                                            editcategory.selection = TextSelection.collapsed(offset: suggestion.length);
                                                            editcategory.value = TextEditingValue(
                                                              text: suggestion,
                                                              selection: TextSelection.collapsed(offset: suggestion.length),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                      SizedBox(width: 16),
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller: editamount = TextEditingController(text: spent_data[i]['amount']),
                                                          style: const TextStyle(fontSize: 14),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              //updatetotalspent();
                                                              // _updateTotalBudget2();
                                                              setState(() {
                                                                errormsg = null;
                                                              });
                                                            });
                                                          },
                                                          keyboardType: TextInputType.number,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: editremarks = TextEditingController(text: spent_data[i]['remarks']),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black), // Change input text size and color
                                                          decoration:
                                                          InputDecoration(
                                                            labelText: "Remarks",
                                                            labelStyle: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .blue), // Change label text size and color
                                                          ),
                                                        ),)

                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        child: const Text('Ok',),
                                                        onPressed: () {
                                                          double tamount = double.parse(spent_data[i]['amount']) + totalRemainingAmount;
                                                          double amount = double.tryParse(editamount.text) ?? 0.0;
                                                          if (amount <= tamount) {
                                                            editExpense(int.parse(spent_data[i]["id"]));
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => MonthlyBudget2(
                                                                          incomeId: widget.incomeId,
                                                                          fromDate: widget.fromDate,
                                                                          toDate: widget.toDate,
                                                                          totalIncomeAmt: widget.totalIncomeAmt,
                                                                          uid: widget.uid,
                                                                        ))); // Dismiss alert dialog
                                                          }
                                                          else{
                                                            showDialog(
                                                                context: context,
                                                                builder: (BuildContext context)
                                                                {
                                                                  return AlertDialog(
                                                                    title: Text('Insufficient Balance'),
                                                                    // content: Text('You have insufficient balance in your wallet.'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          editamount.clear();
                                                                          setState((){
                                                                            totalMonthlyExpenses = 0;
                                                                          });
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text('OK'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }
                                                            );
                                                          }

                                                        }
                                                      ),
                                                      TextButton(
                                                        child:  const Text('Cancel',),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          // Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                                                        },
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.edit_note,color: Colors.blue,)) :
                                    Icon(Icons.delete,color: Colors.deepPurple.shade50)
                                )),
                                TableCell(child: Center(child:
                                spent_data[i]['date'] != null ?  IconButton(
                                    onPressed: (){
                                      showDialog(
                                          context: context,
                                          builder: (ctx) =>
                                          // Dialog box for register meeting and add guest
                                          AlertDialog(
                                            backgroundColor: Colors.grey[800],
                                            title: const Text('Delete',
                                                style: TextStyle(color: Colors.white)),
                                            content: const Text("Do you want to Delete the Expense?",
                                                style: TextStyle(color: Colors.white)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async{
                                                    delete(spent_data[i]['id']);
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> MonthlyBudget2(
                                                      incomeId: widget.incomeId,
                                                      fromDate: widget.fromDate,
                                                      toDate: widget.toDate,
                                                      totalIncomeAmt: widget.totalIncomeAmt,
                                                      uid: widget.uid,
                                                    )));
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        content: Text("You have Successfully Deleted")));
                                                  },
                                                  child: const Text('Yes')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('No'))
                                            ],
                                          )
                                      );
                                    }, icon: const Icon(Icons.delete,color: Colors.red,)) :
                                Icon(Icons.delete,color: Colors.deepPurple.shade50)
                                )),
                              ]
                          ),
                        ]
                      ]   )
              ),
              const SizedBox(height: 30)

            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Fuel':
        return Colors.blue;
      case 'Tollgate':
        return Colors.pink;
      case 'Tickets':
        return Colors.purple;
      case 'Others':
        return Colors.black;
      default:
      // You can assign default colors for unknown categories here
      // For example, you can cycle through a list of predefined colors
      // Here, I'm using a simple approach by returning a different default color for each unknown category
        List<Color> defaultColors = [Colors.orange, Colors.teal, Colors.deepOrange, Colors.indigo];
        return defaultColors[category.hashCode % defaultColors.length]; // Default color for unknown categories
    }
  }

}
