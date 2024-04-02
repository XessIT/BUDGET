import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  void _addmonthcategoryField() {
    setState(() {
      monthlyexpenses.add({
        'date': TextEditingController(
            text: _formatDate(
                DateTime.now())), // Add TextEditingController for date
        'monthcategory': TextEditingController(),
        'monthlyamount': TextEditingController(),
        'remarks': TextEditingController(),
      });
      updatetotalspent();
    });
  }




  @override
  void initState() {
    super.initState();
    _addmonthcategoryField();
    updatetotalspent();
   // _loadDataFromSharedPreferences();
   // _getTotalIncomeForSelectedMonth();
    _loadDataForMonthly();
    fetchTotalSpent(widget.incomeId);
    futureData = fetchData(widget.uid);
    getData();
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
      'uid': "1",
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
  TextEditingController dateRangeController = TextEditingController(); // Add controller for TypeAheadFormField
  void fetchTotalSpent(String incomeId) async {
    final url = Uri.parse('http://localhost/BUDGET/lib/BUDGETAPI/monthly_spent.php?incomeId=$incomeId');
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
  TextEditingController editdate = TextEditingController();
  TextEditingController editcategory = TextEditingController();
  TextEditingController editamount = TextEditingController();
  TextEditingController editremarks = TextEditingController();
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
          title: Text(
            "Monthly Budget",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  MonthlyDashboard(uid: '',)));
            },
          ),
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: RoundedRectangleBorder(
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


              Row(
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
                  RichText(
                    text: TextSpan(
                      children: [

                        TextSpan(
                          text: '${fromDate.text} / ${toDate.text}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],

              ),  ///  Text Field


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
                                  Text('₹${double.parse(monthlyincome.text).toStringAsFixed(2)}' ,style: Theme.of(context).textTheme.labelMedium,
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
                              backgroundColor: totalBudgetAmount > double.parse(monthlyincome.text)
                                  ? Colors.red // Orange color when spent exceeds received amount
                                  : Colors.teal,
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Budget', style: Theme.of(context).textTheme.labelMedium),
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
                              backgroundColor: totalBudgetAmount > double.parse(monthlyincome.text)
                                  ? Colors.red // Orange color when spent exceeds received amount
                                  : Colors.teal,
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
                            BarSeries<SalesData, String>(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ), /// Chart


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
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                              onTap: () async {
                                                // Show date picker when the field is tapped
                                                DateTime? pickedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
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
                                            ),
                                          ),

                                          /// Amount
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
                                                        mainAxisSize:
                                                        MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "Category: ${monthlyexpenses[i]['monthcategory']!.text}",
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          Text(
                                                            "Amount: ${monthlyexpenses[i]['monthlyamount']!.text}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black), // Change text size and color
                                                          ),
                                                          TextField(
                                                            controller:
                                                            monthlyexpenses[i]
                                                            ['remarks'],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black), // Change input text size and color
                                                            decoration:
                                                            InputDecoration(
                                                              labelText: "Add",
                                                              labelStyle: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blue), // Change label text size and color
                                                            ),
                                                          ),
                                                          if (notesList.isNotEmpty)
                                                            Container(
                                                              height: 100,
                                                              child:
                                                              ListView.builder(
                                                                itemCount: notesList
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                    index) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                      notesList[
                                                                      index],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          14,
                                                                          color: Colors
                                                                              .black), // Change list item text size and color
                                                                    ),
                                                                  );
                                                                },
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
                                                      borderRadius:
                                                      BorderRadius.zero,

                                                      // Remove border radius
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),

                                          ///remarks

                                          IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors
                                                    .red), // You can change the icon here
                                            onPressed: () {
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
                                } else {
                                  // No error for this row
                                  errorMessages[i] = null;
                                }
                              }
                              // Check overall form validity
                              if (isValid) {
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
              ),

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
              Container(
                  child: SingleChildScrollView(
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
                          children: [TableRow(children:[
                            TableCell(child:  Center(child: Text('Date', style: TextStyle(fontSize: 16, color: Colors.black)),),),
                            //Name
                            TableCell(child:Center(child: Text('Category',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                            // company name

                            TableCell(child:Center(child: Text('Amount',style: TextStyle(fontSize: 16, color: Colors.black)),)),

                            TableCell(child:Center(child: Text('Remarks',style: TextStyle(fontSize: 16, color: Colors.black)),)),
                            //Email
                            TableCell(child:Center(child: Column(children: [SizedBox(height: 8,), Text('Delete', style: TextStyle(fontSize: 16, color: Colors.black)), SizedBox(height: 8,),],),)),
                            // Chapter
                            TableCell(child: Center(child: Text('Edit', style: TextStyle(fontSize: 16, color: Colors.black)),))]),

                            for(var i = 0 ;i < data.length; i++) ...[

                              TableRow(
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  children:[
                                    // 1 Table row contents
                                    TableCell(
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 8,),
                                            Text(data[i]['date'] != null
                                                ? DateFormat('MMM-dd').format(DateTime.parse(data[i]['date']))
                                                : 'No Date Available'),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //2 name
                                    TableCell(child: Center(child: Text('${data[i]["category"] ?? ''}',),)),
                                    // 3 company name
                                    TableCell(child:Center(child: Text('${data[i]["amount"]?? ''}',),)),
                                    // 4 email
                                    TableCell(child:Center(child: Text('${data[i]["remarks"]?? ''}',),)),

                                    TableCell(child: Center(child:
                                    IconButton(
                                        onPressed: (){
                                          showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                              // Dialog box for register meeting and add guest
                                              AlertDialog(
                                                backgroundColor: Colors.grey[800],
                                                title: const Text('Delete',
                                                    style: TextStyle(color: Colors.white)),
                                                content: const Text("Do you want to Delete the Image?",
                                                    style: TextStyle(color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async{
                                                        delete(data[i]['id']);
                                                        Navigator.pop(context);
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
                                        }, icon: const Icon(Icons.delete,color: Colors.red,)))),
                                    // 5 chapter
                                    TableCell(child:Center(
                                        child:IconButton(
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
                                                              controller: editdate = TextEditingController(text: DateFormat('MMM-dd').format(DateTime.parse(data[i]['date']))), // Assuming expense['date'] is already a TextEditingController
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.bold),
                                                              onTap: () async {
                                                                // Show date picker when the field is tapped
                                                                DateTime? pickedDate =
                                                                await showDatePicker(
                                                                  context: context,
                                                                  initialDate: DateTime.now(),
                                                                  firstDate: DateTime(2000),
                                                                  lastDate: DateTime(2101),
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
                                                                    editdate.text =
                                                                        _formatDate(pickedDate);
                                                                  });
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 16),
                                                          Expanded(
                                                            flex: 2,
                                                            child:
                                                            TypeAheadFormField<String>(
                                                              textFieldConfiguration: TextFieldConfiguration(
                                                                controller: editcategory = TextEditingController(text: data[i]['category']),
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
                                                              controller: editamount = TextEditingController(text: data[i]['amount']),
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
                                                              controller: editremarks = TextEditingController(text: data[i]['remarks']),
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black), // Change input text size and color
                                                              decoration:
                                                              InputDecoration(
                                                                labelText: "Add",
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
                                                              editExpense(int.parse(data[i]["id"]));
                                                              Navigator.pop(context); // Dismiss alert dialog
                                                            },
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
                                            icon: Icon(Icons.edit_note,color: Colors.blue,)))),
                                  ]
                              ),
                            ]
                          ]   )
                  )
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
