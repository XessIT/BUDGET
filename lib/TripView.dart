import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class ViewDataPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    //_loadDataFromHive();
    _loadDataFromSharedPreferences();
  }

  void _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve all trip identifiers
    List<String> tripIds = prefs.getStringList('reportIds') ?? [];

    // Create a temporary list to store the trips
    List<Map<String, dynamic>> tempTrips = [];

    // Load data for each trip
    for (String tripId in tripIds) {
      String tripNameKey = '$tripId:tripName';
      String sourceKey = '$tripId:source';
      String fromDateKey = '$tripId:fromDate';
      String toDateKey = '$tripId:toDate';
      String totalBudgetKey = '$tripId:totalBudget';
      String noOfPersonKey = '$tripId:noOfPerson';
      String personKey = '$tripId:persons';
      String expensesKey = '$tripId:expenses';

      // Retrieve data using the consistent key pattern
      String tripName = prefs.getString(tripNameKey) ?? '';
      String source = prefs.getString(sourceKey) ?? '';
      String fromDate = prefs.getString(fromDateKey) ?? '';
      String toDate = prefs.getString(toDateKey) ?? '';
      String noOfPerson = prefs.getString(noOfPersonKey) ?? '';
      double totalBudget = prefs.getDouble(totalBudgetKey) ?? 0.0;

      // Retrieve expenses list as List<String>
      List<String>? expensesListPerson = prefs.getStringList(personKey);
      List<String>? expensesList = prefs.getStringList(expensesKey);

      // Convert String list to List<Map<String, String>>
      List<Map<String, String>> expenses2 = [];
      if (expensesListPerson != null) {
        expenses2 = expensesListPerson.map((expense2) {
          List<String> parts = expense2.split(':');
          return {
            'name': parts[0],
            'perAmount': parts[1],
          };
        }).toList();
      }

      List<Map<String, String>> expenses = [];
      if (expensesList != null) {
        expenses = expensesList.map((expense) {
          List<String> parts = expense.split(':');
          return {
            'category': parts[0],
            'amount': parts[1],
          };
        }).toList();
      }

      // Add the trip data to the temporary list
      tempTrips.add({
        'tripName': tripName,
        'source': source,
        'fromDate': fromDate,
        'toDate': toDate,
        'totalBudget': totalBudget.toString(),
        'noOfPerson': noOfPerson,
        'persons': expenses2,
        'expenses': expenses,
      });

      // Display the data or store it in a list for future use
      print('Trip ID: $tripId');
      print('Trip Name: $tripName');
      print('Source: $source');
      print('From Date: $fromDate');
      print('To Date: $toDate');
      print('Total Budget: $totalBudget');
      print('Expenses: $expenses');
      print('-------------');
    }
    setState(() {
      trips = tempTrips;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Saved Data'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var trip in trips)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Name: ${trip['tripName']}'),
                  Text('Source: ${trip['source']}'),
                  Text('From Date: ${trip['fromDate']}'),
                  Text('To Date: ${trip['toDate']}'),
                  Text('No of persons: ${trip['noOfPerson']}'),
                  Text('Total Budget: ${trip['totalBudget']}'),
                  const Divider(),
                  const Text('Persons:'),
                  for (var expense2 in trip['persons'] as List<Map<String, String>>)
                    Row(
                      children: [
                        Text('Name: ${expense2['name']}'),
                        Text('   Amount: ${expense2['perAmount']}'),
                      ],
                    ),
                  const Divider(),
                  Text('Expenses:'),
                  for (var expense in trip['expenses'] as List<Map<String, String>>)
                    Row(
                      children: [
                        Text('Category: ${expense['category']}'),
                        Text('   Amount: ${expense['amount']}'),
                      ],
                    ),
                  const Divider(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
